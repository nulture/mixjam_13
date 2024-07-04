class_name Skeleton extends Node2D

const MAX_DISASSEMBLE_WIDTH : float = 500

@export var title : String
@export var fossils_required : Array[Fossil]
@export var missing_scene : PackedScene

var fossils_collected : Array[Fossil]
var hidden_nodes : Array[Sprite2D]

var assembled_positions : Array[Vector2]

var is_pristine_condition : bool :
	get:
		return percent_recovered == 1.0

var is_assemblable : bool :
	get: 
		for i in fossils_required :
			if !fossils_collected.has(i) : 
				return false
		return true

var percent_recovered : float :
	get:
		var result := 0.0
		for i in fossils_collected :
			result += i.get_pixels_percent_of_original()
		return result / fossils_required.size()

var percent_destroyed : float :
	get:
		var result := 0.0
		for i in fossils_collected :
			result += 1.0 - i.get_pixels_percent_of_original()
		return result / fossils_collected.size()

func _ready() -> void :
	# refresh_assembled_positions()
	# refresh_display_nodes()
	disassemble()
	pass

func disassemble() -> void :
	var child_count = get_child_count()
	if child_count == 1 :
		return
	hidden_nodes.resize(child_count)
	assembled_positions.resize(child_count)
	for i in child_count :
		hidden_nodes[i] = get_child(i)
		hidden_nodes[i].replace_by(missing_scene.instantiate())
		assembled_positions[i] = hidden_nodes[i].position
		var percent := float(i) / float(child_count - 1)
		get_child(i).position = Vector2.RIGHT * (MAX_DISASSEMBLE_WIDTH * percent - MAX_DISASSEMBLE_WIDTH * 0.5)

func add_fossil(fossil: Fossil) -> void : 
	var i := fossils_required.find(fossil)
	if i == -1 :
		push_error("Fossil '%s' doesn't belong to skeleton '%s'." % fossil, self)
	# var position = 
	var missing_node = get_child(i)
	missing_node.replace_by(hidden_nodes[i])
	missing_node.queue_free()
	fossils_collected.append(fossil)

func assemble_start() -> void :
	if !is_assemblable : return
	pass

