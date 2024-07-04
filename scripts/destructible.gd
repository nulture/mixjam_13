@tool class_name Destructible extends Node2D
## Destructible sprite on a per-pixel basis.

signal pixels_modified

@export var tough : bool

var _epsilon : float = 2.0
@export_range(0.4, 10) var epsilon : float = 2.0 :
	get: return _epsilon
	set (value):
		if _epsilon == value : return
		_epsilon = value

		if sprite == null : return

		refresh_body()

@onready var body : StaticBody2D = $sprite/body
@onready var bitmap := BitMap.new()
var polygons : Array[PackedVector2Array]

@onready var sprite : Sprite2D = $sprite
var pixels_original : int

var _image : Image
@export var image : Image :
	get: return _image
	set (value) :
		if _image == value : return
		_image = value

		if sprite == null : return

		sprite.texture = ImageTexture.new()
		refresh_all()
		pixels_original = get_pixels_count()

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
	if sprite.texture == null : return

	image = sprite.texture.get_image()
	refresh_body()
	pass

func create_with_image(img: Image, centered: bool = false) -> void :
	sprite.centered = centered
	image = img

func get_pixels_count() -> int :
	var result := 0
	var size = image.get_size()
	for ix in size.x :
		for iy in size.y :
			if bitmap.get_bit(ix, iy):
				result += 1
	return result

func get_pixels_percent_of_original() -> float:
	return float(get_pixels_count()) / float(pixels_original)

func set_pixelv(xy: Vector2i, value: bool) -> void :
	bitmap.set_bitv(xy, value)

	var color := image.get_pixelv(xy)
	color.a = int(value)
	image.set_pixelv(xy, color)

func refresh_all() -> void:
	refresh_sprite()
	refresh_body()

func refresh_body() -> void:
	body.position = sprite_rect.position

	for i in body.get_children() :
		i.queue_free()
	polygons.clear()

	if image == null : return

	bitmap.create_from_image_alpha(image)
	polygons = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, sprite_rect.size), epsilon)
	for i in polygons :
		var node = CollisionPolygon2D.new()
		node.polygon = i
		body.add_child(node)

	pixels_modified.emit()

func refresh_sprite() -> void:
	sprite.texture.set_image(image)
	pass

func get_overlapping_pixels(other: Destructible) -> int :
	var result := 0
	var sect = global_rect.intersection(other.global_rect)
	var local = sect.position - global_rect.position
	var local_other = sect.position - other.global_rect.position

	var ip := Vector2i.ZERO
	var op := Vector2i.ZERO
	for ix in sect.size.x :
		ip.x = local.x + ix
		op.x = local_other.x + ix
		for iy in sect.size.y :
			ip.y = local.y + iy
			op.y = local_other.y + iy
			if bitmap.get_bitv(ip) && other.bitmap.get_bitv(op) :
				result += 1
	return result
