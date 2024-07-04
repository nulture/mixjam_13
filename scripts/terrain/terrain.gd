@tool class_name Terrain extends Node2D

const CHUNK_SIZE : int = 256

@export var chunk_prefab : PackedScene

var chunk_grid_size : Vector2i

var _image : Image
var _texture : Texture2D
@export var texture : Texture2D :
	get: return _texture
	set (value):
		if _texture == value : return
		_texture = value

		if _texture != null :
			_image = _texture.get_image()
		else :
			_image = null
		
		reload_chunks()

func _ready() -> void:
	reload_chunks()

func reload_chunks() -> void:
	for i in get_children() :
		i.queue_free()
	if _texture == null : return
	chunk_grid_size = Vector2i(
		ceili(float(texture.get_width()) / float(CHUNK_SIZE)),
		ceili(float(texture.get_height()) / float(CHUNK_SIZE)))
	for ix in chunk_grid_size.x :
		for iy in chunk_grid_size.y :
			create_chunk(Vector2i(ix, iy))

func create_chunk(coord: Vector2i) -> void:
	var data = PackedByteArray()
	data.resize(CHUNK_SIZE * CHUNK_SIZE * 4)
	var subimage := Image.create_from_data(CHUNK_SIZE, CHUNK_SIZE, false, _image.get_format(), data)
	subimage.blit_rect(_image, Rect2i(coord * CHUNK_SIZE, Vector2i(CHUNK_SIZE, CHUNK_SIZE)), Vector2i.ZERO)

	var node : Destructible = chunk_prefab.instantiate()
	node.position = coord * CHUNK_SIZE
	add_child(node)
	init_chunk.call_deferred(node, subimage)

func init_chunk(node: Destructible, subimage: Image) -> void :
	node.create_with_image(subimage)
