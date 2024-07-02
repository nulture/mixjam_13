class_name CrustChunk extends DestructibleSpriteWithCollision

const chunk_size := Vector2i(256, 256)

var host : Terrain
var coord : Vector2i

func _init(_image: Image, _coord: Vector2i) -> void:
	super._init(_image)
	coord = _coord
	centered = false
	position = coord * chunk_size

func init(_host: Terrain, _coord: Vector2i, _bitmap: BitMap, _subimage: Image) -> void :
	self.host = _host