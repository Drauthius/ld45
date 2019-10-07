extends Area2D

export(int, 1, 100) var damage := 1

func set_animation(direction):
	$AnimationPlayer.play("swing_" + direction)

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()

func _on_MeleeAttack_body_entered(body):
	if body != $".." and body.is_in_group("Living"):
		body.take_damage(damage)
