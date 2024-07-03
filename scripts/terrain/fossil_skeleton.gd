class_name FossilSkeleton extends Node2D

@onready var sprites : Array[DestructibleSprite] = get_sprites()
@onready var self_scene : PackedScene = Utils.get_scene_clean(self)

func _ready() -> void:
	print(sprites)
	pass

func get_sprites() -> Array[DestructibleSprite]:
	var result : Array[DestructibleSprite] = []
	for i in find_children("*", "DestructibleSprite"):
		result.append(i as DestructibleSprite)
	return result

func copy_images(other: FossilSkeleton) -> void:
	if sprites.size() != other.sprites.size() :
		push_error("Cannot copy images from FossilSkeleton ", self, " to ", other, " because they do not have the same number of sprites.")
		return
	for i in sprites.size() :
		# other.sprites[i].texture.set_image(sprites[i].texture.get_image())
		other.sprites[i].image = sprites[i].image
		other.sprites[i].refresh_texture()
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("system_debug") :
		print("Duped")
		var newguy := self_scene.instantiate() as FossilSkeleton
		get_tree().root.add_child(newguy)
		copy_images(newguy)

