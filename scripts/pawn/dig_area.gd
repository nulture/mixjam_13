extends Area2D

@export var dig_delay : float = 1.0

@export var safe_colliders : Array[CollisionShape2D]
@export var unsafe_colliders : Array[CollisionShape2D]

@onready var safe_rect : CollisionShape2D = $safe_shape
@onready var unsafe_rect : CollisionShape2D = $unsafe_shape

@onready var safe_rect_left : CollisionShape2D = $safe_rect_left
@onready var safe_rect_right : CollisionShape2D = $safe_rect_right
@onready var safe_rect_down : CollisionShape2D = $safe_rect_down

@onready var unsafe_rect_left : CollisionShape2D = $unsafe_rect_left
@onready var unsafe_rect_right : CollisionShape2D = $unsafe_rect_right
@onready var unsafe_rect_down : CollisionShape2D = $unsafe_rect_down

var safe_rects : Array[RectangleShape2D]
var unsafe_rects : Array[RectangleShape2D]

var timer : Timer

var _charging: bool
var charging: bool:
	get: return _charging
	set (value):
		if _charging == value : return
		_charging = value

		if _charging :
			timer.start()
			# destroy_stuff()
		else :
			timer.stop()

func get_rect_world(rect: CollisionShape2D) -> Rect2 :
	return Rect2(rect.global_position + rect.shape.get_rect().position, rect.shape.get_rect().size)

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = dig_delay
	timer.one_shot = false
	timer.timeout.connect(destroy_stuff)
	add_child(timer)

	for i in safe_colliders :
		safe_rects.append(i.shape)
	for i in unsafe_colliders :
		unsafe_rects.append(i.shape)

func _process(delta: float) -> void:
	if charging :
		destroy_stuff()
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("p1_primary") :
		charging = true
	elif Input.is_action_just_released("p1_primary") :
		charging = false

func destroy_stuff() -> void :
	
	Terrain.inst.set_pixels_rect(get_rect_world(safe_rect), false, false)
	Terrain.inst.set_pixels_rect(get_rect_world(unsafe_rect), true, false)

	# var input_vector = Input.get_vector("p1_move_left", "p1_move_right", "p1_move_up", "p1_move_down")

	# if input_vector.length_squared() == 0 : return
	# if abs(input_vector.x) >= abs(input_vector.y) :
	# 	if input_vector.x > 0 :
	# 		destroy_direction(safe_rect_right, unsafe_rect_right)
	# 	else :
	# 		destroy_direction(safe_rect_left, unsafe_rect_left)
	# else :
	# 	if input_vector.y > 0 :
	# 		destroy_direction(safe_rect_down, unsafe_rect_down)
	# 	else :
	# 		pass

func destroy_direction(safe: CollisionShape2D, unsafe: CollisionShape2D) :
	# for i in unsafe_rects :
	# 	Terrain.inst.set_pixels_rect(get_rect_world(i), true, false)
	# for i in safe_rects :
	# 	Terrain.inst.set_pixels_rect(get_rect_world(i), false, false)

	# Terrain.inst.set_pixels_rect(get_rect_world(unsafe_rect), true, false)
	Terrain.inst.set_pixels_rect(get_rect_world(unsafe), true, false)
	Terrain.inst.set_pixels_rect(get_rect_world(safe), false, false)