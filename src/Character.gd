extends KinematicBody2D

# warning-ignore:unused_class_variable
export(float, 0.1, 100.0) var movement_speed = 100.0
export(int, 1, 100) var max_health = 1

const QPI = PI/4

onready var is_player := false
onready var health : int = max_health
onready var dead := false
onready var facing := PI/2

signal hit(character, amount)
signal death(character)

func take_damage(damage):
	if $EffectPlayer.is_playing():
		return
	
	damage = ConsequenceEngine.take_damage(damage, is_player)
	
	# warning-ignore:narrowing_conversion
	health = max(0, health - damage)
	if health > 0:
		emit_signal("hit", self, damage)
		$EffectPlayer.play("damaged")
	else:
		dead = true
		emit_signal("death", self)
		if not is_player:
			queue_free()

# warning-ignore:unused_argument
func update_sprite(stopped):
	if is_player and not $AttackCooldown.is_stopped():
		stopped = false
	
	if stopped:
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.current_animation.replace("attack_", "run_")
			$AnimationPlayer.seek(0, true)
			$AnimationPlayer.stop()
	else:
		var anim := "run_"
		if is_player and not $AttackCooldown.is_stopped():
			anim = "attack_"
			
		if facing > 5*QPI and facing < 7*QPI:
			anim += "down"
		elif facing > 3*QPI and facing < 5*QPI:
			anim += "right"
		elif facing > QPI and facing < 3*QPI:
			anim += "up"
		else:
			anim += "left"
		#print(facing, " -> ", anim)
		$AnimationPlayer.play(anim)