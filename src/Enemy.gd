extends "res://src/Character.gd"

export(float, 1.0, 1000.0) var detect_range := 150.0

onready var target = $"../Player"
onready var detect_range_squared = detect_range * detect_range

func _physics_process(delta):
	if dead or $"..".paused:
		return
	elif position.distance_squared_to(target.position) > detect_range_squared:
		return
	
	var direction : Vector2 = (target.position - position).normalized()
	var _velocity = move_and_slide(direction * movement_speed)