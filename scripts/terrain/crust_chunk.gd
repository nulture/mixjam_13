class_name CrustChunk extends StaticBody2D

@export var epsilon : float = 2.0

var host : Terrain
var coord : Vector2i
var bitmap : BitMap
var sprite : Sprite2D
var image : Image

var polys : Array[PackedVector2Array]
var ready_to_update_polygons : bool
@onready var thread := Thread.new()

var rect : Rect2i :
	get: return Rect2i(position, host.chunk_size)

var local_rect : Rect2i :
	get: return Rect2i(Vector2i.ZERO, host.chunk_size)

func init(_host: Terrain, _coord: Vector2i, _bitmap: BitMap, _subimage: Image) -> void :
	self.host = _host
	self.coord = _coord
	self.bitmap = _bitmap
	self.image = _subimage
	
	# image = bitmap.convert_to_image()
	var texture = ImageTexture.new()
	texture.set_image(image)

	sprite = Sprite2D.new()
	sprite.centered = false
	sprite.texture = texture
	add_child(sprite)
	
	position = coord * host.chunk_size
	calculate_polygons()
	refresh()

func _exit_tree() -> void:
	thread.wait_to_finish()

func _process(delta: float) -> void:
	if thread.is_started():
		thread.wait_to_finish()
	if ready_to_update_polygons :
		print("ready to update polygons")
		refresh()
		ready_to_update_polygons = false
	pass

func start_refresh_thread():
	if thread.is_started() : return
	thread.start(calculate_polygons)

func refresh() -> void :
	for i in get_children() :
		if i == sprite : continue
		i.queue_free()

	for i in polys :
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = i
		add_child(collision_polygon)

	# image = bitmap.convert_to_image()
	(sprite.texture as ImageTexture).set_image(image)

func calculate_polygons() -> void :
	polys = bitmap.opaque_to_polygons(local_rect, host.chunk_epsilon)
	ready_to_update_polygons = true

func set_pixels_rect(_rect: Rect2i, value: bool) :
	var sect = rect.intersection(_rect)
	var local = sect.position % host.chunk_size
	var ip := Vector2i.ZERO
	for ix in sect.size.x :
		ip.x = local.x + ix
		for iy in sect.size.y :
			ip.y = local.y + iy
			bitmap.set_bitv(ip, value)
			if !value : image.set_pixelv(ip, image.get_pixelv(ip) * Color(1, 1, 1, 0))

	start_refresh_thread()
