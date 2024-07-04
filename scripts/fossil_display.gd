class_name FossilDisplay extends Node2D

const FOSSIL_INFO_TEXT := "%0/%1 recovered"
const PIXEL_INFO_TEXT := "%0% pristine"

@onready var anim_player : AnimationPlayer = $animation_player

var skeleton_template: FossilSkeleton
var collected_fossils: Array[StringName]

var skeleton : FossilSkeleton

func _ready() -> void:
	pass

func make_real() -> void:
	skeleton = skeleton_template.copy_fresh_inclusive(collected_fossils)
	add_child(skeleton)
	skeleton.finished_reassemble.connect(exit)
	skeleton.disable_collision()
	skeleton.disassemble()

	if skeleton.can_be_reassembled:
		skeleton.begin_reassemble()



	anim_player.play("enter")

func exit() -> void:
	anim_player.play("exit")
