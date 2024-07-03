class_name Fossil extends Node2D

@onready var sprite : DestructibleSprite = $sprite
@onready var anim_player : AnimationPlayer = $anim_player

func collect() -> void :
	sprite.destruction_enabled = false
	anim_player.play("collect")
