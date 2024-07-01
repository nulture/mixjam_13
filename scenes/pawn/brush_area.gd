extends Area2D

@onready var rectangle_shape := $shape.shape as RectangleShape2D

var rect_world : Rect2i :
	get : return Rect2i($shape.global_position + rectangle_shape.get_rect().position, rectangle_shape.get_rect().size)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("p2_primary") :
		brush()
		
func brush() -> void :
	Terrain.inst.set_pixels(rect_world, false)
	pass
