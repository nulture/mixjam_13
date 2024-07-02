extends CollisionShape2D

@export var affects_destructibles : bool = true

@onready var circle := shape as CircleShape2D

var _charging : bool
var charging : bool :
	get : return _charging
	set (value) :
		if _charging == value : return
		_charging = value
	
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if charging :
		Terrain.inst.set_pixels_circle(global_position, circle.radius, affects_destructibles, false)
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("p1_primary") :
		charging = true
	elif Input.is_action_just_released("p1_primary") :
		charging = false
