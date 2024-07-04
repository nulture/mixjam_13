class_name DestructArea extends Area2D

@export var gentle : bool

var overlaps : Array[Destructible] = []

func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func on_body_entered(body: Node2D) -> void:
	if body.get_parent().get_parent() is Destructible:
		overlaps.append(body.get_parent().get_parent())

func on_body_exited(body: Node2D) -> void:
	if body.get_parent().get_parent() is Destructible:
		overlaps.erase(body.get_parent().get_parent())

func _get_global_rect() -> Rect2i:
	return Rect2i()


func destruct_overlaps() -> void:
	for i in overlaps:
		if gentle && i.tough : continue
		destruct_single(i)
	temp_destructible = null

var temp_destructible : Destructible

func destruct_single(d: Destructible) -> void:
	temp_destructible = d
	var sect = d.global_rect.intersection(_get_global_rect())
	var local = sect.position - d.global_rect.position
	var ip := Vector2i.ZERO
	for ix in sect.size.x :
		ip.x = local.x + ix
		for iy in sect.size.y :
			ip.y = local.y + iy
			if _pixel_lambda(ip) :
				d.set_pixelv(ip, false)
	d.refresh_all()

func _pixel_lambda(xy: Vector2i) -> bool :
	return true