extends "res://src/Character.gd"

onready var interactable = null

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
	
	var velocity := move_and_slide(dir.normalized() * speed)
	
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
