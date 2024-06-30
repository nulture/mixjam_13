
## Moves a node (i.e. the player) to match the editor's view on game start.
@tool extends Node3D

## If set, this node will move to the editor view position on [method _ready]. Set this to your pawn's base node.
@export var position_node : Node3D

## If set, this node will have its yaw set to match the editor view.
@export var yaw_node : Node3D

## If set, this node will have its pitch set to match the editor view.
@export var pitch_node : Node3D

## If set, [member position_node] will be offset relative to this node. Set this to your pawn's camera node.
@export var offset_node : Node3D

static var activated : bool = false
static var editor_view_node : Camera3D :
	get : return EditorInterface.get_editor_viewport_3d().get_camera_3d()

func _ready() -> void :
	if !activated && visible && !Engine.is_editor_hint():
		if position_node != null :
			if offset_node != null :
				position_node.global_position = global_position + (position_node.global_position - offset_node.global_position)
			else :
				position_node.global_position = global_position
		if yaw_node != null :
			yaw_node.global_rotation = Vector3(yaw_node.global_rotation.x, global_rotation.y, yaw_node.global_rotation.z)
		if pitch_node != null :
			pitch_node.global_rotation = Vector3(global_rotation.x, pitch_node.global_rotation.y, pitch_node.global_rotation.z)
	activated = true
	queue_free()

func _process(_delta: float) -> void :
	if Engine.is_editor_hint() :
		global_position = editor_view_node.global_position
		global_rotation = editor_view_node.global_rotation
