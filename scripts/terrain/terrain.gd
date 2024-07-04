@tool class_name Terrain extends Node2D

var _image : Texture2D
@export var image : Texture2D :
	get: return _image
	set (value):
		if _image == value : return
		_image = value

static var inst : Terrain

func _ready() -> void:
	inst = self

