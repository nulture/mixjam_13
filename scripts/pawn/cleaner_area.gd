extends DestructArea

@onready var character : CharacterBody2D = $".."
@onready var shape := $shape.shape as CircleShape2D
@onready var anim_sprite := $shape/sprite as AnimatedSprite2D


var _charging: bool
var charging: bool:
	get: return _charging
	set (value):
		if _charging == value : return
		_charging = value

		anim_sprite.visible = _charging
		if _charging :
			anim_sprite.play("default")
		else :
			destruct_overlaps()
			anim_sprite.stop()

var radius_percent : float :
	get : return float(anim_sprite.frame) / float(anim_sprite.sprite_frames.get_frame_count("default"))

func _ready() -> void:
	super._ready()
	anim_sprite.visible = false
	pass

func _process(delta: float) -> void:
	var input_vector = Input.get_vector("p2_move_left", "p2_move_right", "p2_move_up", "p2_move_down")
	if input_vector.length_squared() != 0:
		look_at(global_position + input_vector)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("p2_primary") :
		charging = true
	elif Input.is_action_just_released("p2_primary") :
		charging = false

var temp_origin_local : Vector2i
var temp_radius : float

func _get_global_rect() -> Rect2i :
	var origin := Vector2i($shape.global_position)
	temp_origin_local = origin - temp_destructible.global_rect.position
	temp_radius = shape.radius * radius_percent
	return Rect2i(origin - Vector2i.ONE * ceili(temp_radius), Vector2i.ONE * ceili(temp_radius) * 2)

func _pixel_lambda(xy: Vector2i) -> bool:
	var dist = (xy - temp_origin_local).length()
	if dist > temp_radius : return false
	return true

func charge_anim_finished() -> void:
	charging = false
	

