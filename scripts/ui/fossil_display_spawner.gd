class_name FossilDisplaySpawner extends Node2D

signal finished_all_displays

@export var fossil_display_scene : PackedScene

static var inst : FossilDisplaySpawner
var index : int = 0

var displays : Array[FossilDisplay] = []

func _ready() -> void:
	inst = self

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("p1_secondary") :
		do_next()

func register_fossil(fossil: Fossil) -> void:
	var skeleton : FossilSkeleton = fossil.get_parent().get_parent()
	var display := get_display(skeleton)
	display.collected_fossils.append(fossil.name)
	pass

func get_display(skeleton: FossilSkeleton) -> FossilDisplay :
	for i in displays :
		if i.skeleton_template == skeleton :
			return i
	var result : FossilDisplay = fossil_display_scene.instantiate()
	result.skeleton_template = skeleton
	displays.append(result)
	add_child(result)
	return result

func do_next() -> void:
	if index >= get_child_count() : 
		finished_all_displays.emit()
		return
	var display : FossilDisplay = get_child(index)
	display.make_real()
	index += 1
