class_name Terrain extends Node2D

@export var crust_texture : Texture2D

@onready var chunk_root : Node2D = $chunk_root
@onready var destructible_root : Node2D = $destructible_root

var chunks : Dictionary
var chunk_grid_size : Vector2i

@onready var crust_image := crust_texture.get_image()

var destructibles : Array[DestructibleSprite]

static var inst : Terrain

func _ready() -> void:
	inst = self

	register_destructibles()
	create_chunks_from_texture()
	
	if self.texture != null :
		self.texture = null

	if Engine.is_editor_hint() : return
	

func create_chunks_from_texture() -> void :
	chunk_grid_size = Vector2i(
		ceili(float(crust_image.get_width()) / CrustChunk.chunk_size.x),
		ceili(float(crust_image.get_height()) / CrustChunk.chunk_size.y))
	for ix in chunk_grid_size.x :
		for iy in chunk_grid_size.y :
			var ip = Vector2i(ix, iy)
			create_chunk(ip)

func create_chunk(coord: Vector2i) :
	var data = PackedByteArray()
	data.resize(CrustChunk.chunk_size.x * CrustChunk.chunk_size.y * 4)
	var subimage := Image.create_from_data(CrustChunk.chunk_size.x, CrustChunk.chunk_size.y, false, crust_image.get_format(), data)
	subimage.blit_rect(crust_image, Rect2i(CrustChunk.chunk_size * coord, CrustChunk.chunk_size), Vector2i.ZERO)

	var node := CrustChunk.new(subimage, coord)
	chunks[coord] = node
	chunk_root.add_child(node)

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
	
	if !value:
		var collectibles : Array[DestructibleSprite] = []
		for i in destructibles :
			if rect.intersects(i.global_rect) :
				if affect_destructibles :
					i.set_pixels_rect(rect, value)
				collectibles.append(i)
		check_collectibles(collectibles)
	
func set_pixels_circle(origin : Vector2, radius : float, affect_destructibles : bool, value : bool) -> void :
	var rect = DestructibleSprite.rect_from_circle(origin, radius)
	for i in get_intersecting_chunks(rect) :
		i.set_pixels_circle(origin, radius, value)
	
	if !value:
		var collectibles : Array[DestructibleSprite] = []
		for i in destructibles :
			if rect.intersects(i.global_rect) :
				if affect_destructibles :
					i.set_pixels_circle(origin, radius, value)
				collectibles.append(i)
		check_collectibles(collectibles)

func register_destructibles() -> void :
	destructibles.clear()
	for i in destructible_root.find_children("*", "DestructibleSprite") :
		destructibles.append(i)


func get_overlap_chunks_percent(dest: DestructibleSprite) -> float :
	var overlap_pixels : int = 0
	
	var overlaps = get_intersecting_chunks(dest.global_rect)
	for i in overlaps:
		overlap_pixels += dest.overlapping_pixels(i)

	return float(overlap_pixels) / float(dest.original_pixels)
	
func check_collectibles(list: Array[DestructibleSprite]) -> void :
	for i in list :
		if i.is_destroyed :
			destructibles.erase(i)
			continue

		var ic := Utils.find_child(i, "Collectible")
		if ic == null : continue
		var percent := get_overlap_chunks_percent(i)
		if percent > ic.collect_threshold : continue

		FossilDisplaySpawner.inst.register_fossil(i.get_parent())
		ic.collect()
		destructibles.erase(i)
