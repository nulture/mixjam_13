extends Pawn

const HALF_PI := PI * 0.5

@export var speed : Vector2 = Vector2.ONE
@export var speed_down_add = 1.0
@export var friction : Vector2 = Vector2.ONE

@export var aim_speed : float = 1.0
@export var laser_pushback : Vector2

@onready var digger_arm : Node2D = $digger_arm

var in_aiming_mode : bool
var input_vector : Vector2 :
	get : return Vector2(Input.get_axis("p1_move_left", "p1_move_right"), Input.get_axis("p1_move_up", "p1_move_down"))

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	velocity -= velocity * friction
	
	if !in_aiming_mode :
		var vector = input_vector * speed
		if vector.y > 0 :
			vector.y += speed_down_add
		velocity += vector
	
	
	
	super._physics_process(delta)
	

func _process(delta: float) -> void:
	super._process(delta)
	
	if in_aiming_mode && input_vector.length_squared() != 0 :
		digger_arm.rotation = move_toward_angle(digger_arm.rotation, input_vector.angle(), aim_speed * delta)
		pass
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("p1_secondary") :
		in_aiming_mode = !in_aiming_mode

func move_toward_angle(from : float, to: float, delta : float):
	if to >= PI : to = -PI
	var result : float
	if from > to + PI :
		result = move_toward(from, from + 1, delta)
	elif from < to - PI :
		result = move_toward(from, from - 1, delta)
	else :
		result = move_toward(from, to, delta)
	return fmod(result + PI, TAU) - PI
