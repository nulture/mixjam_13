extends Camera2D

@export var speed : float

func _ready() -> void:
	if !OS.is_debug_build() : queue_free()

func _process(delta: float) -> void:
	position += Input.get_vector("debug_camera_left", "debug_camera_right", "debug_camera_up", "debug_camera_down") * speed * delta

func _input(event: InputEvent) -> void:
	if !OS.is_debug_build() : return
	if Input.is_action_just_pressed("debug_camera_left") || Input.is_action_just_pressed("debug_camera_right") || Input.is_action_just_pressed("debug_camera_up") || Input.is_action_just_pressed("debug_camera_down") :
		reparent(get_tree().root)
		make_current()

