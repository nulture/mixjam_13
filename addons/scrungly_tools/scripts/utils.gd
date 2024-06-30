class_name Utils extends Object

static func find_child(parent: Node, type: String) -> Node:
	var childs = parent.find_children("*", type)
	if childs.size() == 0 : return null
	return childs[0]
