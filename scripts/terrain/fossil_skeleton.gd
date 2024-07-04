class_name FossilSkeleton extends Node2D

signal finished_reassemble

const MAX_DISASSEMBLE_WIDTH : float = 500

@export var title : String

@onready var fossils : Array[Node2D] = get_sprites()
@onready var self_scene : PackedScene = Utils.get_scene_clean(self)
@onready var anim_player : AnimationPlayer = $animation_player

var assembly_positions : Dictionary

var is_missing_sprites : bool = false
var is_assembling_sprites : bool = false
var assembling_sprite_index : int = 0

var can_be_reassembled: bool:
	get:
		for i in fossils :
			var fossil := i as Fossil
			if !fossil.sprite.is_destroyed :
				return false
		return true

func _ready() -> void:
	# print(fossils)
	pass

func _process(delta: float) -> void:
	if is_assembling_sprites :
		var fossil = fossils[assembling_sprite_index]
		var target = assembly_positions[assembling_sprite_index]
		fossil.position.x = move_toward(fossil.position.x, target.x, 300 * delta)
		fossil.position.y = move_toward(fossil.position.y, target.y, 300 * delta)

		if fossil.position == target:
			assembling_sprite_index += 1
		if assembling_sprite_index == fossils.size():
			is_assembling_sprites = false
			anim_player.play("flourish")
			finished_reassemble.emit()

func get_sprites() -> Array[Node2D]:
	var result : Array[Node2D] = []
	for i in find_children("*", "Fossil"):
		result.append(i)
	return result

func copy_images(other: FossilSkeleton) -> void:
	if fossils.size() != other.fossils.size() :
		push_error("Cannot copy images from FossilSkeleton ", self, " to ", other, " because they do not have the same number of fossils.")
		return
	for i in fossils.size() :
		# other.fossils[i].sprite.texture.set_image(fossils[i].sprite.texture.get_image())
		other.fossils[i].sprite.image = fossils[i].sprite.image
		other.fossils[i].sprite.refresh_texture()


func copy_fresh() -> FossilSkeleton :
	var result := self_scene.instantiate() as FossilSkeleton
	copy_images.call_deferred(result)
	return result

## Does [method copy_fresh] but replaces any non-included fossils with question marks.
func copy_fresh_inclusive(include: Array[StringName]) -> FossilSkeleton :
	var result = copy_fresh()
	result.copy_fresh_inclusive_deferred.call_deferred(include)
	return result

func copy_fresh_inclusive_deferred(include: Array[StringName]) -> void :
	for i in fossils:
		if include.has(i.name) : continue
		is_missing_sprites = true
		i.visible = false


func disassemble() -> void:
	if fossils.size() == 0 :
		return
	if fossils.size() == 1 :
		assembly_positions[0] = fossils[0].position
		return
	for i in fossils.size():
		assembly_positions[i] = fossils[i].position

		var percent := float(i) / float(fossils.size() - 1)
		fossils[i].position = Vector2.RIGHT * (percent * MAX_DISASSEMBLE_WIDTH - MAX_DISASSEMBLE_WIDTH * 0.5)
	pass

func begin_reassemble() -> void:
	assembling_sprite_index = 0
	is_assembling_sprites = true

func disable_collision() -> void:
	for i in fossils :
		i.sprite.destruction_enabled = false
