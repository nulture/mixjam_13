@tool class_name Terrain extends Node2D

@export var refresh_button : bool :
	get : return false
	set (value) : 
		refresh_all()
		
@export var bitmap : BitMap

@onready var body : TerrainBody = $terrain_body
@onready var sprite : Sprite2D = $sprite
@onready var texture := ImageTexture.new()

var image : Image

static var inst : Terrain

func _ready() -> void:
	sprite.texture = texture
	inst = self
	refresh_all()
	
func refresh_all() -> void :
	body.refresh()
	refresh_image()

func refresh_image() -> void :
	image = bitmap.convert_to_image()
	image.convert(Image.FORMAT_RGBA8)

	refresh_image_area(Rect2i(Vector2i.ZERO, image.get_size()))
	
func refresh_image_area(rect : Rect2i) -> void :
	var pos = rect.position
	for ix in rect.size.x :
		if pos.x < 0 || pos.x >= image.get_width() : continue
		for iy in rect.size.y :
			if pos.y < 0 || pos.y >= image.get_height() : continue
			
			if bitmap.get_bitv(pos) : continue
			image.set_pixelv(pos, Color(0, 0, 0, 0))
			
			pos.y += 1
		pos.x += 1
	texture.set_image(image)
	
func set_pixels(rect : Rect2i, value : bool) -> void :
	bitmap.set_bit_rect(rect, value)
	
	body.refresh()
	refresh_image_area(rect)
