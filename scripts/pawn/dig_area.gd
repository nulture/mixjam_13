class_name DiggerArea extends DestructArea

# @export var dig_delay : float = 1.0
@onready var pawn_digger : PawnDigger = $".."

var timer : Timer

func get_rect_world(rect: CollisionShape2D) -> Rect2 :
	return Rect2(rect.global_position + rect.shape.get_rect().position, rect.shape.get_rect().size)

func _ready() -> void:
	super._ready()

	# timer = Timer.new()
	# timer.wait_time = dig_delay
	# timer.one_shot = false
	# timer.timeout.connect(destroy_stuff)
	# add_child(timer)

func _physics_process(delta: float) -> void:
	if monitoring && pawn_digger.charging :
		destruct_overlaps()
	pass

func _get_global_rect() -> Rect2i :
	var shape : CollisionShape2D = get_child(0)
	var _rect = shape.shape as RectangleShape2D
	return Rect2i(Vector2i(shape.global_position - _rect.size * 0.5), _rect.size)
