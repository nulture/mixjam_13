@tool class_name Destructible extends Node2D
## Destructible sprite on a per-pixel basis.

@export var tough : bool

var _epsilon : float = 2.0
@export_range(0.4, 10) var epsilon : float = 2.0 :
	get: return _epsilon
	set (value):
		if _epsilon == value : return
		_epsilon = value

		refresh_collision()

@onready var body : StaticBody2D = $sprite/body
@onready var _bitmap := BitMap.new()
var _polygons : Array[PackedVector2Array]

@onready var sprite : Sprite2D = $sprite

var _collision_enabled : bool = true
@export var collision_enabled : bool = true :
	get: return _collision_enabled
	set (value):
		if _collision_enabled == value: return
		_collision_enabled = value

		body.visible = _collision_enabled
		
		if Engine.is_editor_hint() : return
		if _collision_enabled :
			add_child(body)
		else :
			remove_child(body)


var rect : Rect2i :
	get: return sprite.get_rect()
var global_rect : Rect2i :
	get: return Rect2i(Vector2i(global_position) + rect.position, rect.size)
var image_rect : Rect2i :
	get: return Rect2i(Vector2i.ZERO, rect.size)

func _ready() -> void:
	refresh_collision()
	pass

func refresh_collision() -> void:
	body.position = rect.position
	_bitmap.create_from_image_alpha(sprite.texture.get_image())
	for i in body.get_children() :
		i.queue_free()

	_polygons = _bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, rect.size), epsilon)
	for i in _polygons :
		var node = CollisionPolygon2D.new()
		node.polygon = i
		body.add_child(node)

