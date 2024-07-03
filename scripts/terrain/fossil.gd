class_name Fossil extends Node2D

@onready var sprite : DestructibleSprite = $sprite
@onready var collectible : Collectible = $sprite/collectible
@onready var anim_player : AnimationPlayer = $anim_player

func _ready() -> void:
	sprite.destroyed.connect(destroy)

func collect() -> void :
	sprite.destruction_enabled = false
	anim_player.play("collect")

func destroy() -> void:
	anim_player.play("destroy")