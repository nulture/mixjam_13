class_name PawnBrusher extends Pawn

@export var speed_x : float = 1.0
@export var friction_x : float = 1.0

@export var jump_count : int = 1
@export var jump_y : float = 1.0

@onready var brusher_area : Area2D = $brush_area

static var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _grounded : bool
var grounded : bool :
	get : return _grounded
	set (value) :
		if _grounded == value : return
		_grounded = value
		
		if _grounded :
			jumps_left = jump_count
		else :
			pass

var jumps_left : int

func _ready() -> void:
	super._ready()
	
	jumps_left = jump_count

func _physics_process(delta: float) -> void :
	grounded = is_on_floor()
	
	if not grounded :
		velocity.y += gravity * delta
	velocity.x -= velocity.x * friction_x
	if not brusher_area.charging :
		velocity.x += Input.get_axis("p2_move_left", "p2_move_right") * speed_x
	
	super._physics_process(delta)

func _process(delta: float) -> void:
	super._process(delta)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("p2_move_up") :
		jump()
		
func jump() -> void :
	if jumps_left <= 0 || brusher_area.charging : return
	jumps_left -= 1
	
	velocity.y = -jump_y


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
