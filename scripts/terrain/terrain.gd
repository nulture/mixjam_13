class_name Terrain extends Sprite2D

@export var refresh_button : bool :
	get: return false
	set (value):
		# refresh_crust()
		pass

@export var chunk_size : Vector2i = Vector2i.ONE * 256
@export var chunk_epsilon : float = 2.0

@export var crust_texture : Texture2D
@export var crust_bitmap : BitMap
@export var fossil_root : Node2D

var chunks : Dictionary
var chunk_grid_size : Vector2i

@onready var crust_image := crust_texture.get_image()

var destructibles : Array[DestructibleSprite]

static var inst : Terrain

func _ready() -> void:
	inst = self
	# crust_image = texture.get_image()
	create_chunks_from_texture()
	
	if Engine.is_editor_hint() : return
	
	register_fossils()

func create_chunks_from_texture() -> void :
	chunk_grid_size = Vector2i(
		ceili(float(crust_image.get_width()) / chunk_size.x),
		ceili(float(crust_image.get_height()) / chunk_size.y))
	for ix in chunk_grid_size.x :
		for iy in chunk_grid_size.y :
			var ip = Vector2i(ix, iy)
			create_chunk(ip)
	texture = null

func create_chunk(coord: Vector2i) :
	var bitmap = BitMap.new()
	bitmap.resize(chunk_size)

	var data = PackedByteArray()
	data.resize(chunk_size.x * chunk_size.y * 4)
	var subimage := Image.create_from_data(chunk_size.x, chunk_size.y, false, crust_image.get_format(), data)
	subimage.blit_rect(crust_image, Rect2i(chunk_size * coord, chunk_size), Vector2i.ZERO)
	
	var ip := Vector2i.ZERO
	for ix in chunk_size.x :
		ip.x = coord.x * chunk_size.x + ix
		for iy in chunk_size.y :
			ip.y = coord.y * chunk_size.y + iy
			if ip.x >= crust_image.get_width() || ip.y >= crust_image.get_height() : continue
			bitmap.set_bit(ix, iy, crust_image.get_pixelv(ip).a > 0.1)

	var node := CrustChunk.new()
	chunks[coord] = node
	
	node.init(self, coord, bitmap, subimage)
	add_child(node)

# func refresh_image() -> void :
# 	crust_image = crust_bitmap.convert_to_image()
# 	crust_image.convert(Image.FORMAT_RGBA8)

# 	refresh_image_area(Rect2i(Vector2i.ZERO, crust_image.get_size()))
	
func refresh_image_area(rect : Rect2i) -> void :
	var pos := Vector2i.ZERO
	for ix in rect.size.x :
		pos.x = rect.position.x + ix
		if pos.x < 0 || pos.x >= crust_image.get_width() : continue
		for iy in rect.size.y :
			pos.y = rect.position.y + iy
			if pos.y < 0 || pos.y >= crust_image.get_height() : continue
			
			if crust_bitmap.get_bitv(pos) : continue
			crust_image.set_pixelv(pos, Color(0, 0, 0, 0))
	# texture.set_image(crust_image)

func register_fossils() -> void :
	destructibles.clear()
	for i in fossil_root.find_children("*", "DestructibleSprite") :
		destructibles.append(i)
		
static func set_pixels_sprite(bitmap : BitMap, sprite : Sprite2D, value : bool) -> void :
	var local_rect_position = Vector2i(sprite.get_rect().position)
	var rect = Rect2i(Vector2i(sprite.global_position) + local_rect_position, sprite.get_rect().size)
	var pos := Vector2i.ZERO
	for ix in rect.size.x :
		pos.x = rect.position.x + ix
		if pos.x < 0 || pos.x >= bitmap.get_size().x : continue
		for iy in rect.size.y :
			pos.y = rect.position.y + iy
			if pos.y < 0 || pos.y >= bitmap.get_size().y : continue
			var local = local_rect_position + Vector2i(ix, iy)
			
			bitmap.set_bitv(pos, sprite.is_pixel_opaque(local))
	pass
	
static func is_sprite_overlapping_bitmap(bitmap: BitMap, sprite: Sprite2D) -> bool :
	return get_sprite_overlap_percentage(bitmap, sprite) > 0.0
	
static func get_sprite_overlap_percentage(bitmap: BitMap, sprite: Sprite2D) -> float :
	var overlap_pixels : float = 0.0
	var total_pixels : float = 0.0
	
	var local_rect_position = Vector2i(sprite.get_rect().position)
	var rect = Rect2i(Vector2i(sprite.global_position) + local_rect_position, sprite.get_rect().size)
	var pos := Vector2i.ZERO
	for ix in rect.size.x :
		pos.x = rect.position.x + ix
		if pos.x < 0 || pos.x >= bitmap.get_size().x : continue
		for iy in rect.size.y :
			pos.y = rect.position.y + iy
			if pos.y < 0 || pos.y >= bitmap.get_size().y : continue
			var local = local_rect_position + Vector2i(ix, iy)
			if !sprite.is_pixel_opaque(local) : continue
			total_pixels += 1.0
			if !bitmap.get_bitv(pos) : continue
			overlap_pixels += 1.0
	return overlap_pixels / total_pixels
	
func collect_destructibles(rect: Rect2i) -> void :
	for i in destructibles :
		if !rect.intersects(i.global_rect) : continue
		if Terrain.get_sprite_overlap_percentage(crust_bitmap, i) > i.collect_threshold : continue
		
		i.collect()

func position_to_coord(vector: Vector2) -> Vector2i :
	return floor(vector / Vector2(chunk_size))

func coord_inside_grid(coord: Vector2i) -> bool:
	return coord.x >= 0 && coord.x < chunk_grid_size.x && coord.y >= 0 && coord.y < chunk_grid_size.y

func get_intersecting_chunks(rect: Rect2i) -> Array[CrustChunk] :
	var result : Array[CrustChunk] = []
	
	var ul = position_to_coord(rect.position)
	var ur = position_to_coord(rect.position + Vector2i.RIGHT * rect.size.x)
	var dl = position_to_coord(rect.position + Vector2i.DOWN * rect.size.y)
	var dr = position_to_coord(rect.position + rect.size)

	if coord_inside_grid(ul) :
		result.append(chunks[ul])
	if coord_inside_grid(ur) && !result.has(chunks[ur]) :
		result.append(chunks[ur])
	if coord_inside_grid(dl) && !result.has(chunks[dl])  :
		result.append(chunks[dl])
	if coord_inside_grid(dr) && !result.has(chunks[dr]) :
		result.append(chunks[dr])

	return result
	
func set_pixels_rect(rect : Rect2i, affect_destructibles : bool, value : bool) -> void :
	for i in get_intersecting_chunks(rect) :
		i.set_pixels_rect(rect, value)

	# var size = Vector2i(crust_bitmap.get_size().x, crust_bitmap.get_size().y)
	# var ip := Vector2i.ZERO
	# for ix in rect.size.x :
	# 	ip.x = rect.position.x + ix
	# 	if ip.x < 0 || ip.x >= size.x : continue
	# 	for iy in rect.size.y :
	# 		ip.y = rect.position.y + iy
	# 		if ip.y < 0 || ip.y >= size.y : continue
	# 		crust_bitmap.set_bitv(ip, value)
	
	if !value && affect_destructibles :
		for i in destructibles :
			if rect.intersects(i.global_rect) : 
				i.destroy_rect(rect)
	
	# crust_body.refresh()
	refresh_image_area(rect)
	collect_destructibles(rect)
	
func set_pixels_circle(origin : Vector2, radius : float, affect_destructibles : bool, value : bool) -> void :
	var rect = DestructibleSprite.rect_from_circle(origin, radius)
	var ip := Vector2i.ZERO
	for ix in rect.size.x :
		ip.x = rect.position.x + ix
		if ip.x < 0 || ip.x >= crust_image.get_width() : continue
		for iy in rect.size.y :
			ip.y = rect.position.y + iy
			if ip.y < 0 || ip.y >= crust_image.get_height() : continue
			
			var dist = (Vector2(ip) - origin).length()
			if dist > radius : continue
			
			crust_bitmap.set_bitv(ip, value)
			
	if !value && affect_destructibles :
		for i in destructibles :
			if rect.intersects(i.global_rect) :
				i.destroy_circle(origin, radius)
	
	# crust_body.refresh()
	refresh_image_area(rect)
	collect_destructibles(rect)
	pass
