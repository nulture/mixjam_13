@tool class_name MoveWithCast3D extends Node3D

#@export var rest_at_target : bool = true

var is_raycast_parent : bool
var is_shapecast_parent : bool
var raycast_parent : RayCast3D
var shapecast_parent : ShapeCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() is RayCast3D :
		raycast_parent = get_parent()
		is_raycast_parent = true
	elif get_parent() is ShapeCast3D :
		shapecast_parent = get_parent()
		is_shapecast_parent = true
	else :
		push_error("MoveWithCast3D must have a raycast or shapecast as its parent.")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void :
	if is_raycast_parent :
		if raycast_parent.is_colliding() :
			global_position = raycast_parent.get_collision_point()
		else :
			position = raycast_parent.target_position
	elif is_shapecast_parent :
		if shapecast_parent.is_colliding() :
			position = lerp(Vector3.ZERO, shapecast_parent.target_position, shapecast_parent.get_closest_collision_safe_fraction())
