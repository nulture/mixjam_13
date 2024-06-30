extends Pawn

@export var speed : Vector2 = Vector2.ONE
@export var speed_down_add = 1.0
@export var friction : Vector2 = Vector2.ONE

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	velocity -= velocity * friction
	
	var input_vector = Input.get_vector("p1_move_left", "p1_move_right", "p1_move_up", "p1_move_down") * speed
	if input_vector.y > 0 :
		input_vector.y += speed_down_add
	velocity += input_vector
	
	super._physics_process(delta)

func _process(delta: float) -> void:
	super._process(delta)
