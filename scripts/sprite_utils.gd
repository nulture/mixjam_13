class_name SpriteUtils extends Object

static func copy(from: Sprite2D, to: Sprite2D) -> void :
	to.texture.set_image(from.texture.get_image())