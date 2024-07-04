class_name Level extends Node2D

static var inst : Level

@onready var fossil_collected_hook : Node2D = $fossil_collected_hook

func _ready() -> void :
	inst = self
