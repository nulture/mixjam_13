class_name DestructibleSpriteWithCollision extends DestructibleSprite

@export var epsilon : float = 2.0
@export_flags_2d_physics var collision_layer : int = 1

var body : StaticBody2D

var bitmap : BitMap
var polys : Array[PackedVector2Array]
var ready_to_update_polygons : bool
var thread : Thread

func _init(_image: Image = null) -> void:
	super._init(_image)
	bitmap = BitMap.new()

	if image == null : return
	bitmap.create_from_image_alpha(_image)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

	thread = Thread.new()
	body = StaticBody2D.new()
	body.collision_layer = collision_layer
	add_child(body)

	calculate_polygons()
	refresh_polygons()

func _exit_tree() -> void:
	thread.wait_to_finish()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if thread.is_started():
		thread.wait_to_finish()
	if ready_to_update_polygons :
		refresh_polygons()
		ready_to_update_polygons = false
	pass

func refresh_texture() -> void:
	if thread.is_started() : return
	thread.start(calculate_polygons)

func refresh_polygons() -> void:
	super.refresh_texture()
	for i in body.get_children() :
		i.queue_free()

	for i in polys :
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = i
		body.add_child(collision_polygon)

func calculate_polygons() -> void:
	polys = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, get_rect().size), epsilon)
	ready_to_update_polygons = true

func set_pixelv(xy: Vector2i, value: bool) -> void:
	bitmap.set_bitv(xy, value)
	super.set_pixelv(xy, value)
