class_name Collectible extends Node

## If the percentage of current pixels covered is less than this value, the fossil is collected.
@export_range(0.0, 1.0) var collect_threshold = 0.1

@onready var destructible : DestructibleSprite = $".."
@onready var fossil : Fossil = $"../.."

func collect() -> void :
	print("Collected! (%2.0f percent of pixels remaining)" % (destructible.get_remaining_percent() * 100))
	destructible.destruction_enabled = false
	fossil.collect()
	

