class_name Fossil extends Node2D

@onready var sprite : DestructibleSprite = $sprite
@onready var collectible : Collectible = $sprite/collectible
@onready var anim_player : AnimationPlayer = $anim_player

var is_collected = false

func _ready() -> void:
	sprite.destroyed.connect(destroy)

func collect() -> void :
	sprite.destruction_enabled = false
	is_collected = true
	anim_player.play("collect")

func destroy() -> void:
	anim_player.play("destroy")