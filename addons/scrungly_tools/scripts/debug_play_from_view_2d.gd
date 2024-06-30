
## Moves a node (i.e. the player) to match the editor's view on game start.
@tool extends Node2D

## If set, this node will move to the editor view position on [method _ready]. Set this to your pawn's base node.
@export var position_node : Node2D

static var activated : bool = false
static var editor_view_node : Camera2D :
	get : return EditorInterface.get_editor_viewport_2d().get_camera_2d()

func _ready() -> void :
	if !activated && visible && !Engine.is_editor_hint():
		if position_node != null :
			position_node.global_position = global_position
	activated = true
	queue_free()

func _process(_delta: float) -> void :
	if Engine.is_editor_hint() :
		global_position = editor_view_node.global_position
		global_rotation = editor_view_node.global_rotation
