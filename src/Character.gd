extends KinematicBody2D

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
	damage = ConsequenceEngine.take_damage(damage, is_player)
	
	health = max(0, health - damage)
	if health > 0:
		emit_signal("hit", self, damage)
	else:
		dead = true
		emit_signal("death", self)
		queue_free()

func update_sprite(stopped):
	if stopped:
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.seek(0, true)
			$AnimationPlayer.stop()
	else:
		var anim := "run_"
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