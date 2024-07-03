class_name FossilDisplay extends Node2D

@onready var anim_player : AnimationPlayer = $animation_player

var skeleton_template: FossilSkeleton
var collected_fossils: Array[Fossil]

var skeleton : FossilSkeleton

func _ready() -> void:
	pass

func make_real() -> void:
	skeleton = skeleton_template.copy_fresh()
	add_child(skeleton)
	skeleton.finished_reassemble.connect(exit)
	skeleton.disable_collision()
	skeleton.disassemble()
	skeleton.begin_reassemble()
	anim_player.play("enter")

func exit() -> void:
	anim_player.play("exit")
