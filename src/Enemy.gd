extends "res://src/Character.gd"

export(float, 1.0, 1000.0) var detect_range := 150.0

onready var target = $"../Player"
onready var detect_range_squared = detect_range * detect_range

enum State { IDLE, CHASING }
onready var state = State.IDLE

signal lockedon

func _process(_delta):
	if dead:
		return
	
	if state == State.IDLE and position.distance_squared_to(target.position) <= detect_range_squared:
		state = State.CHASING
		emit_signal("lockedon")

func _physics_process(_delta):
	if dead:
		return
	elif state == State.IDLE:
		return
	elif not $AttackCooldown.is_stopped():
		return
	
	var direction : Vector2 = (target.position - position).normalized()
	facing = direction.angle() + PI
	
	var _velocity = move_and_slide(direction * movement_speed)
	
	update_sprite(false) #velocity.length_squared() <= 0.001)
	
	# Check for player collision
	for i in range(get_slide_count()):
		var coll = get_slide_collision(i)
		if coll.collider == target:
			$AttackCooldown.start()
			target.take_damage(1)
			return
