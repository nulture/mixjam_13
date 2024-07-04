class_name DestructArea extends Area2D

@export var gentle : bool

var overlaps: Array[Destructible] = []

func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func on_body_entered(body: Node2D) -> void:
	if body.get_parent() is Destructible:
		overlaps.append(body.get_parent() as Destructible)

func on_body_exited(body: Node2D) -> void:
	if body.get_parent() is Destructible:
		overlaps.erase(body.get_parent())

func destruct_overlaps() -> void:
	for i in overlaps:
		if gentle && i.tough : continue
		_destruct_single(i)

func _destruct_single(destruct: Destructible) -> void:
	print("Destructed ", destruct)
	pass