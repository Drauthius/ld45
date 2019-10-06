extends "res://src/Character.gd"

export(int, 1, 100) var food = 50

const MeleeAttack = preload("res://scn/MeleeAttack.tscn")

onready var interactable = null

func _process(_delta):
	if dead or $"..".paused:
		return
	
	if Input.is_action_just_pressed("player_interact") and interactable != null:
		interactable.queue_free()
		interactable = null
	
	if Input.is_action_pressed("player_attack") and $AttackCooldown.is_stopped():
		$AttackCooldown.start()
		var attack := MeleeAttack.instance()
		add_child(attack)
		attack.rotation = facing
		attack.position = Vector2(16, 0).rotated(facing)

func _physics_process(_delta):
	if dead or $"..".paused:
		return
	
	var dir := Vector2(0.0, 0.0)
	
	if Input.is_action_pressed("player_left"):
		dir.x -= 1
	if Input.is_action_pressed("player_right"):
		dir.x += 1
	if Input.is_action_pressed("player_up"):
		dir.y -= 1
	if Input.is_action_pressed("player_down"):
		dir.y += 1
	
	if dir.length_squared() != 0.0:
		facing = dir.angle()
	
	var velocity := move_and_slide(dir.normalized() * movement_speed)
	
	if velocity.length_squared() <= 0.001 and $AnimationPlayer.is_playing():
		$AnimationPlayer.seek(0, true)
		$AnimationPlayer.stop()
	else:
		$AnimationPlayer.play("run_down")

func _on_InteractionRange_body_entered(body):
	if body.is_in_group("Interactable"):
		if interactable != null:
			interactable.set_outline(false)
		interactable = body
		interactable.set_outline(true)

func _on_InteractionRange_body_exited(body):
	if body.is_in_group("Interactable"):
		if interactable == body:
			interactable.set_outline(false)
			interactable = null
			
			for newbody in $InteractionRange.get_overlapping_bodies():
				if newbody != body:
					_on_InteractionRange_body_entered(newbody)
					if interactable != null:
						print("new")
						return
