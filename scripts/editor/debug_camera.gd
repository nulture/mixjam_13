extends Camera2D

@export var speed : float

func _process(delta: float) -> void:
	position += Input.get_vector("debug_camera_left", "debug_camera_right", "debug_camera_up", "debug_camera_down") * speed * delta
