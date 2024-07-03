class_name Utils extends Object

## Returns the node's [PackedScene] from its file path, using all defaults of the file.
static func get_scene_clean(node: Node) -> PackedScene:
	return load(node.scene_file_path)

## Returns the node's [PackedScene] from the current point in time. Use this to duplicate
## a scene at a certain point in time and then duplicate it later.
static func get_scene_cache(node: Node) -> PackedScene:
	var result := PackedScene.new()
	result.pack(node)
	return result

static func find_child(parent: Node, type: String) -> Node:
	var childs = parent.find_children("*", type)
	if childs.size() == 0 : return null
	return childs[0]

static func random_point_in_unit_circle() -> Vector2 :
	return (Vector2.RIGHT * randf_range(0, 1)).rotated(randf_range(0, TAU))
