class_name Terrain extends Sprite2D

@export var crust_texture : Texture2D
@export var fossil_root : Node2D

var chunks : Dictionary
var chunk_grid_size : Vector2i

@onready var crust_image := crust_texture.get_image()

var destructibles : Array[DestructibleSprite]

static var inst : Terrain

func _ready() -> void:
	inst = self
	create_chunks_from_texture()
	
	if Engine.is_editor_hint() : return
	
	# register_fossils()

func create_chunks_from_texture() -> void :
	chunk_grid_size = Vector2i(
		ceili(float(crust_image.get_width()) / CrustChunk.chunk_size.x),
		ceili(float(crust_image.get_height()) / CrustChunk.chunk_size.y))
	for ix in chunk_grid_size.x :
		for iy in chunk_grid_size.y :
			var ip = Vector2i(ix, iy)
			create_chunk(ip)
	texture = null

func create_chunk(coord: Vector2i) :
	var data = PackedByteArray()
	data.resize(CrustChunk.chunk_size.x * CrustChunk.chunk_size.y * 4)
	var subimage := Image.create_from_data(CrustChunk.chunk_size.x, CrustChunk.chunk_size.y, false, crust_image.get_format(), data)
	subimage.blit_rect(crust_image, Rect2i(CrustChunk.chunk_size * coord, CrustChunk.chunk_size), Vector2i.ZERO)

	var node := CrustChunk.new(subimage, coord)
	chunks[coord] = node
	add_child(node)

func position_to_coord(vector: Vector2) -> Vector2i :
	return floor(vector / Vector2(CrustChunk.chunk_size))

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
	
	# if !value && affect_destructibles :
	# 	for i in destructibles :
	# 		if rect.intersects(i.global_rect) : 
	# 			i.destroy_rect(rect)
	
	# crust_body.refresh()
	# refresh_image_area(rect)
	# collect_destructibles(rect)
	
# func set_pixels_circle(origin : Vector2, radius : float, affect_destructibles : bool, value : bool) -> void :
# 	var rect = DestructibleSprite.rect_from_circle(origin, radius)
# 	var ip := Vector2i.ZERO
# 	for ix in rect.size.x :
# 		ip.x = rect.position.x + ix
# 		if ip.x < 0 || ip.x >= crust_image.get_width() : continue
# 		for iy in rect.size.y :
# 			ip.y = rect.position.y + iy
# 			if ip.y < 0 || ip.y >= crust_image.get_height() : continue
			
# 			var dist = (Vector2(ip) - origin).length()
# 			if dist > radius : continue
			
# 			crust_bitmap.set_bitv(ip, value)
			
# 	if !value && affect_destructibles :
# 		for i in destructibles :
# 			if rect.intersects(i.global_rect) :
# 				i.destroy_circle(origin, radius)
	
# 	# crust_body.refresh()
# 	refresh_image_area(rect)
# 	collect_destructibles(rect)
# 	pass




# func register_fossils() -> void :
# 	destructibles.clear()
# 	for i in fossil_root.find_children("*", "DestructibleSprite") :
# 		destructibles.append(i)
		
# static func set_pixels_sprite(bitmap : BitMap, sprite : Sprite2D, value : bool) -> void :
# 	var local_rect_position = Vector2i(sprite.get_rect().position)
# 	var rect = Rect2i(Vector2i(sprite.global_position) + local_rect_position, sprite.get_rect().size)
# 	var pos := Vector2i.ZERO
# 	for ix in rect.size.x :
# 		pos.x = rect.position.x + ix
# 		if pos.x < 0 || pos.x >= bitmap.get_size().x : continue
# 		for iy in rect.size.y :
# 			pos.y = rect.position.y + iy
# 			if pos.y < 0 || pos.y >= bitmap.get_size().y : continue
# 			var local = local_rect_position + Vector2i(ix, iy)
			
# 			bitmap.set_bitv(pos, sprite.is_pixel_opaque(local))
# 	pass
	
# static func is_sprite_overlapping_bitmap(bitmap: BitMap, sprite: Sprite2D) -> bool :
# 	return get_sprite_overlap_percentage(bitmap, sprite) > 0.0
	
# static func get_sprite_overlap_percentage(bitmap: BitMap, sprite: Sprite2D) -> float :
# 	var overlap_pixels : float = 0.0
# 	var total_pixels : float = 0.0
	
# 	var local_rect_position = Vector2i(sprite.get_rect().position)
# 	var rect = Rect2i(Vector2i(sprite.global_position) + local_rect_position, sprite.get_rect().size)
# 	var pos := Vector2i.ZERO
# 	for ix in rect.size.x :
# 		pos.x = rect.position.x + ix
# 		if pos.x < 0 || pos.x >= bitmap.get_size().x : continue
# 		for iy in rect.size.y :
# 			pos.y = rect.position.y + iy
# 			if pos.y < 0 || pos.y >= bitmap.get_size().y : continue
# 			var local = local_rect_position + Vector2i(ix, iy)
# 			if !sprite.is_pixel_opaque(local) : continue
# 			total_pixels += 1.0
# 			if !bitmap.get_bitv(pos) : continue
# 			overlap_pixels += 1.0
# 	return overlap_pixels / total_pixels
	
# func collect_destructibles(rect: Rect2i) -> void :
# 	for i in destructibles :
# 		if !rect.intersects(i.global_rect) : continue
# 		if Terrain.get_sprite_overlap_percentage(crust_bitmap, i) > i.collect_threshold : continue
		
# 		i.collect()
