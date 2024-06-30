
## Selects one of multiple PackedScenes to place in the world on [method _ready].
## Great for creating randomized decorations from a large selection of assets.
@icon("res://assets/icons/SceneRandomizer3D.svg")
@tool class_name SceneRandomizer3D extends Node3D

## Use this button to manually refresh this scene. Do this for existing nodes
## whose [member pool] resource has been modified.
@export var manual_refresh : bool :
	get : return false
	set (value) :
		refresh()

## NO TOUCHY! Used internally. This value is automatically modified
## when moving this node around.
@export var serialized_seed : int

var _scene_override : int = -1
## Use this to override the selected scene in [member pool].
## Set to -1 for a random scene. Values over [member pool]'s size will wrap.
@export var scene_override : int = -1 :
	get : return _scene_override
	set (value) :
		if _scene_override == value : return
		_scene_override = max(value, -1)
		
		if pool != null : rebuild()

var _pool : SceneRandomizerPool
## The [SceneRandomizerPool] from which to draw. Works best if
## all contents are already included in the resource.
@export var pool : SceneRandomizerPool :
	get : return _pool
	set (value) :
		if _pool == value : return
		_pool = value
		
		rebuild()

var scene_index : int :
	get :
		if scene_override > -1 : return scene_override % pool_size
		return random.randi_range(0, pool_size - 1)

var scene_rotation : Vector3 :
	get :
		var x : float
		if pool.random_pitch : x = get_random_angle(0)
		
		var y : float
		if pool.random_yaw : y = get_random_angle(1)
		
		var z : float
		if pool.random_roll : z = get_random_angle(2)
		
		return Vector3(x, y, z)

var pool_size : int :
	get : return pool.contents.size()

const REFRESH_DELAY : float = 0.15

var delay_counter : float = REFRESH_DELAY
var previous_position : Vector3
var is_dirty : bool
var random := RandomNumberGenerator.new()
var editor_child : Node3D

func _ready() -> void :
	if Engine.is_editor_hint() :
		refresh()
		previous_position = position
	else :
		## This is automatically called in the [member pool] setter.
		#rebuild()
		pass

func _process(delta: float) -> void :
	if !Engine.is_editor_hint() : return
	
	if previous_position != position :
		is_dirty = true
		delay_counter = REFRESH_DELAY
	else:
		delay_counter -= delta
	
	if is_dirty && delay_counter <= 0.0 :
		refresh()
		is_dirty = false
	
	previous_position = position

func get_random_angle(i : int) -> float : 
	random.seed += i
	var result = random.randf_range(0.0, 2.0 * PI)
	random.seed -= i
	return result

func refresh() -> void :
	if Engine.is_editor_hint():
		serialized_seed = hash(position)
	rebuild()
	
func rebuild() -> void :
	for i in get_child_count() :
		get_child(i).queue_free()
	
	random.seed = serialized_seed
	
	if pool == null : return
	
	editor_child = pool.contents[scene_index].instantiate()
	editor_child.rotation = scene_rotation
	
	add_child.call_deferred(editor_child)
