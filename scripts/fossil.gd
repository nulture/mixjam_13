@tool class_name Fossil extends Destructible
## Fossils can be irreparably damaged or collected if not overlapping anything.

signal collected
signal destroyed

@export_range(0.0, 1.0) var collect_threshold := 0.05
@export_range(0.0, 1.0) var destroy_threshold := 0.67

@onready var area : Area2D = $sprite/area
@onready var animation_player : AnimationPlayer = $animation_player

var chunk_nodes : Array[Destructible]
var chunk_calls: Array[Callable]
var chunk_pixels : Array[int]

var _is_collected : bool
var is_collected : bool :
	get: return _is_collected
	set (value) :
		if _is_collected == value : return
		_is_collected = value

		if collision_enabled :
			collision_enabled = !_is_collected

var _overlap_count : int
var overlap_count : int :
	get: return _overlap_count
	set (value) :
		if _overlap_count == value : return
		_overlap_count = value

		if _overlap_count == 0:
			collect()

var total_overlapping_pixels : int :
	get:
		var result := 0
		for i in chunk_pixels :
			result += i
		return result

func _ready() -> void :
	area.body_entered.connect(on_body_entered)
	area.body_exited.connect(on_body_exited)

	super._ready()

func _physics_process(delta: float) -> void:
	# check_collect()
	pass

func refresh_body() -> void :
	super.refresh_body()
	area.position = body.position
	for i in area.get_children() :
		i.queue_free()
	for i in body.get_children() :
		area.add_child(i.duplicate())
	if Engine.is_editor_hint() : return
	check_destroy()

func check_collect(chunk: Destructible) -> void :
	var index = chunk_nodes.find(chunk)
	chunk_pixels[index] = get_overlapping_pixels(chunk_nodes[index])

	var percent_overlapping = float(total_overlapping_pixels) / float(pixels_original)
	if percent_overlapping < collect_threshold :
		collect()
	pass

func collect() -> void:
	if !collision_enabled : return
	collision_enabled = false
	
	## This isn't working at all??? This is supposed to prevent chunks to recollect fossils if already collected. The print statements even prove it disconnects correctly. But it doesn't work.
	for i in chunk_nodes.size() :
		# print(chunk_nodes[i].pixels_modified.is_connected(chunk_calls[i]))
		chunk_nodes[i].pixels_modified.disconnect(chunk_calls[i])
		# print(chunk_nodes[i].pixels_modified.is_connected(chunk_calls[i]))
	
	chunk_nodes.clear()
	chunk_calls.clear()
	chunk_pixels.clear()
	animation_player.play("fossil/collect")
	reparent(Level.inst.fossil_collected_hook)
	collected.emit()

func destroy() -> void :
	if !collision_enabled : return
	collision_enabled = false
	animation_player.play("fossil/destroy")
	destroyed.emit()

func check_destroy() -> void :
	if get_pixels_percent_of_original() < destroy_threshold :
		destroy()


func on_body_entered(_body: Node2D) -> void :
	var other := _body.get_parent().get_parent() as Destructible
	if other is Destructible && !chunk_nodes.has(other) :
		chunk_nodes.append(other)
		var chunk_call = func() -> void : check_collect(other)
		chunk_calls.append(chunk_call)
		chunk_pixels.append(get_overlapping_pixels(other))

		other.pixels_modified.connect(chunk_call)

func on_body_exited(_body: Node2D) -> void :
	pass
