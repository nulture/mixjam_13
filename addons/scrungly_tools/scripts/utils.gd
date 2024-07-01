class_name Utils extends Object

static func find_child(parent: Node, type: String) -> Node:
	var childs = parent.find_children("*", type)
	if childs.size() == 0 : return null
	return childs[0]

static func random_point_in_unit_circle() -> Vector2 :
	return (Vector2.RIGHT * randf_range(0, 1)).rotated(randf_range(0, TAU))
