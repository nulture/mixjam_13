@tool class_name TerrainBody extends AnimatableBody2D

@export var epsilon : float = 2.0

@onready var terrain : Terrain = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func refresh() -> void :
	for i in get_children() :
		i.queue_free()
		
	var rect = Rect2(Vector2.ZERO, terrain.bitmap.get_size())
	var polys = terrain.bitmap.opaque_to_polygons(rect, epsilon)
	for i in polys :
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = i
		add_child.call_deferred(collision_polygon)

	print("Finished refresh with ", polys.size(), " polygons")
