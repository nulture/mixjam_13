class_name PawnDigger extends Pawn

@export var speed_normal : float = 1.0
@export var speed_digging : float = 1.0

@export var speed_down_add = 1.0
@export var friction : Vector2 = Vector2.ONE

@onready var area_safe_left : DiggerArea = $area_safe_left
@onready var area_unsafe_left : DiggerArea = $area_unsafe_left
@onready var area_safe_right : DiggerArea = $area_safe_right
@onready var area_unsafe_right : DiggerArea = $area_unsafe_right
@onready var area_safe_down : DiggerArea = $area_safe_down
@onready var area_unsafe_down : DiggerArea = $area_unsafe_down

var _charging: bool
var charging: bool:
	get: return _charging
	set (value):
		if _charging == value : return
		_charging = value

var _active_area_safe : DiggerArea
var _active_area_unsafe : DiggerArea
var _dig_direction_index : int
var dig_direction_index : int :
	get: return _dig_direction_index
	set (value):
		if _dig_direction_index == value : return
		_dig_direction_index = value

		if _active_area_safe != null:
			_active_area_safe.monitoring = false
			_active_area_unsafe.monitoring = false

		match _dig_direction_index :
			0:
				_active_area_safe = null
				_active_area_unsafe = null
			1:
				_active_area_safe = area_safe_left
				_active_area_unsafe = area_unsafe_left
			2:
				_active_area_safe = area_safe_right
				_active_area_unsafe = area_unsafe_right
			3:
				_active_area_safe = area_safe_down
				_active_area_unsafe = area_unsafe_down

		if _active_area_safe != null:
			_active_area_safe.monitoring = true
			_active_area_unsafe.monitoring = true

			

func _ready() -> void:
	super._ready()
	area_safe_left.monitoring = false
	area_unsafe_left.monitoring = false
	area_safe_right.monitoring = false
	area_unsafe_right.monitoring = false
	area_safe_down.monitoring = false
	area_unsafe_down.monitoring = false

func _physics_process(delta: float) -> void:
	# velocity -= velocity * friction
	velocity = Vector2.ZERO

	var input_vector = Vector2(Input.get_axis("p1_move_left", "p1_move_right"), Input.get_axis("p1_move_up", "p1_move_down"))

	if input_vector.length_squared() > 0 :
		if abs(input_vector.x) > abs(input_vector.y) :
			velocity.x += input_vector.x
		else :
			velocity.y += input_vector.y

		if charging :
			velocity *= speed_digging
		else :
			velocity *= speed_normal

		var direction = velocity.normalized()
		if direction.length_squared() == 0 : 
			dig_direction_index = 0
			return

		if abs(direction.x) >= abs(direction.y) :
			if direction.x > 0 :
				dig_direction_index = 2
			else :
				dig_direction_index = 1
		else :
			if direction.y > 0 :
				dig_direction_index = 3
			else :
				dig_direction_index = 0
				pass

	super._physics_process(delta)

func _process(delta: float) -> void:
	super._process(delta)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("p1_primary") :
		charging = true
	elif Input.is_action_just_released("p1_primary") :
		charging = false