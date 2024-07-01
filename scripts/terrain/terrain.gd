@tool class_name Terrain extends Node2D

@export var refresh_button : bool :
	get : return false
	set (value) : 
		refresh_crust()
		
@export var crust_bitmap : BitMap
@export var fossil_root : Node2D

@onready var crust_body : CrustBody = $crust_body
@onready var crust_map : Sprite2D = $crust_map
@onready var texture := ImageTexture.new()

var crust_image : Image

var destructibles : Array[DestructibleSprite]

static var inst : Terrain

func _ready() -> void:
	crust_map.texture = texture
	inst = self
	refresh_crust()
	
	if Engine.is_editor_hint() : return
	
	register_fossils()
	
func refresh_crust() -> void :
	crust_body.refresh()
	refresh_image()

func refresh_image() -> void :
	crust_image = crust_bitmap.convert_to_image()
	crust_image.convert(Image.FORMAT_RGBA8)

	refresh_image_area(Rect2i(Vector2i.ZERO, crust_image.get_size()))
	
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
	texture.set_image(crust_image)
	
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
	
func set_pixels_rect(rect : Rect2i, affect_destructibles : bool, value : bool) -> void :
	crust_bitmap.set_bit_rect(rect, value)
	
	if !value && affect_destructibles :
		for i in destructibles :
			if rect.intersects(i.global_rect) : 
				i.destroy_rect(rect)
	
	crust_body.refresh()
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
	
	crust_body.refresh()
	refresh_image_area(rect)
	collect_destructibles(rect)
	pass
