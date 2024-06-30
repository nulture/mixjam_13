@tool extends AnimatableBody2D

@export var bitmap : BitMap
@export var epsilon : float = 2.0

@export var refresh_button : bool :
	get : return false
	set (value) : 
		refresh()
		
var sprite : Sprite2D
var texture : ImageTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	recreate()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func recreate() -> void :
	refresh()

func refresh() -> void :
	for i in get_children() :
		i.queue_free()
		
	var rect = Rect2(Vector2.ZERO, bitmap.get_size())
	var polys = bitmap.opaque_to_polygons(rect, epsilon)
	for i in polys :
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = i
		add_child(collision_polygon)
		pass
	
	var image = bitmap.convert_to_image()
	image.convert(Image.FORMAT_RGBA8)
	
	for ix in image.get_width() :
		for iy in image.get_height() :
			if image.get_pixel(ix, iy).r == 0 :
				image.set_pixel(ix, iy, Color(0, 0, 0, 0))
	
	texture = ImageTexture.new()
	texture.set_image(image)
		
	sprite = Sprite2D.new()
	sprite.centered = false
	sprite.texture = texture
	add_child(sprite)
		
	print("Finished refresh with ", polys.size(), " polygons")
	pass
