
class_name SystemAutoload extends Node

static var is_fullscreen : bool :
	get :
		return DisplayServer.window_get_mode()
	set (value) :
		if value :
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else :
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _ready() -> void :
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	pass
	
func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("system_quit") :
		get_tree().quit()
	
	if Input.is_action_just_pressed("system_fullscreen") :
		is_fullscreen = !is_fullscreen
	
