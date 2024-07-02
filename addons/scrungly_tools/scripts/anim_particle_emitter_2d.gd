class_name AnimParticleEmitter extends Node2D

@export var spawn_radius = 1.0

## Sprite frames to draw from. Will play a random animation from here on spawn.
@export var sprite_frames : SpriteFrames
@export var spawn_rate : float = 1.0
@export var lifetime : float = 5.0

@onready var possible_anims = sprite_frames.get_animation_names()
var random = RandomNumberGenerator.new()

var random_animation : String :
	get : return possible_anims[random.randi_range(0, possible_anims.size() - 1)]

var counter : float

func _process(delta: float) -> void:
	counter += delta * spawn_rate
	if counter > 1.0 :
		for i in floori(counter) : spawn()
		counter = fmod(counter, 1.0)
	pass

func spawn() -> void :
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.position = position + Utils.random_point_in_unit_circle() * spawn_radius
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play(random_animation)
	
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.autostart = true
	timer.one_shot = true
	timer.timeout.connect(animated_sprite.queue_free)
	
	animated_sprite.add_child(timer)
	add_child(animated_sprite)
