class_name DestructibleSprite extends Sprite2D

## If the percentage of current pixels covered is less than this value, the fossil is collected.
@export_range(0.0, 1.0) var collect_threshold = 0.1
## If the percentage of original pixels is less below this value, the fossil is unusable.
@export_range(0.0, 1.0) var destroy_threshold = 0.5

@onready var image_texture = texture as ImageTexture
@onready var image = texture.get_image()
@onready var original_pixels = get_opaque_pixels()

var global_rect : Rect2i :
	get : return Rect2i(Vector2i(global_position + get_rect().position), get_rect().size)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_remaining_percent() -> float :
	return float(get_opaque_pixels()) / original_pixels
	

func get_opaque_pixels() -> int :
	var result : int = 0
	for ix in self.get_rect().size.x :
		for iy in self.get_rect().size.y :
			if image.get_pixel(ix, iy).a > 0.5 :
				result += 1
	return result


func refresh_texture() -> void :
	image_texture.set_image(image)


func destroy_rect(rect : Rect2i) -> void :
	var intersection = rect.intersection(global_rect)
	intersection.position -= global_rect.position
	for ix in intersection.size.x :
		for iy in intersection.size.y :
			var ip = Vector2i(ix, iy) + intersection.position
			image.set_pixelv(ip, Color(0,0,0,0))
	refresh_texture()
	check_destroy()


func destroy_circle(origin : Vector2, radius : float) -> void :
	var origin_local = origin - Vector2(global_rect.position)
	var rect = DestructibleSprite.rect_from_circle(origin, radius)
	var intersection = rect.intersection(global_rect)
	intersection.position -= global_rect.position
	for ix in intersection.size.x :
		for iy in intersection.size.y :
			var ip = Vector2i(ix, iy) + intersection.position
			var dist = (Vector2(ip) - origin_local).length()
			if dist > radius : continue
			image.set_pixelv(ip, Color(0,0,0,0))
			
	refresh_texture()
	check_destroy()


func collect() -> void :
	print("Collected! (%2.0f percent remaining)" % (get_remaining_percent() * 100))
	Terrain.inst.destructibles.erase(self)
	queue_free()


func check_destroy() -> bool:
	if get_remaining_percent() < destroy_threshold :
		destroy()
		return true
	return false


func destroy() -> void :
	print("Destroyed!")
	Terrain.inst.destructibles.erase(self)
	queue_free()


static func rect_from_circle(origin : Vector2i, radius : float) -> Rect2i :
	return Rect2i(origin - Vector2i.ONE * ceili(radius), Vector2i.ONE * ceili(radius) * 2)
