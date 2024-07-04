@tool class_name Destructible extends Node2D
## Destructible sprite on a per-pixel basis.

@export var tough : bool

var _epsilon : float = 2.0
@export_range(0.4, 10) var epsilon : float = 2.0 :
	get: return _epsilon
	set (value):
		if _epsilon == value : return
		_epsilon = value

		refresh_body()

@onready var body : StaticBody2D = $sprite/body
@onready var _bitmap := BitMap.new()
var _polygons : Array[PackedVector2Array]

@onready var sprite : Sprite2D = $sprite
var _image : Image

var _collision_enabled : bool = true
@export var collision_enabled : bool = true :
	get: return _collision_enabled
	set (value):
		if _collision_enabled == value: return
		_collision_enabled = value

		body.visible = _collision_enabled
		
		if Engine.is_editor_hint() : return
		if _collision_enabled :
			sprite.add_child(body)
		else :
			sprite.remove_child(body)


var sprite_rect : Rect2i :
	get: return sprite.get_rect()
var global_rect : Rect2i :
	get: return Rect2i(Vector2i(global_position) + sprite_rect.position, sprite_rect.size)
var image_rect : Rect2i :
	get: return Rect2i(Vector2i.ZERO, sprite_rect.size)

func _ready() -> void:
	_image = sprite.texture.get_image()
	refresh_body()
	pass

func set_pixelv(xy: Vector2i, value: bool) -> void:
	_bitmap.set_bitv(xy, value)

	var color := _image.get_pixelv(xy)
	color.a = int(value)
	_image.set_pixelv(xy, color)

func refresh_all() -> void:
	refresh_sprite()
	refresh_body()

func refresh_body() -> void:
	body.position = sprite_rect.position
	_bitmap.create_from_image_alpha(sprite.texture.get_image())
	for i in body.get_children() :
		i.queue_free()

	_polygons = _bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, sprite_rect.size), epsilon)
	for i in _polygons :
		var node = CollisionPolygon2D.new()
		node.polygon = i
		body.add_child(node)

func refresh_sprite() -> void:
	sprite.texture.set_image(_image)
	pass