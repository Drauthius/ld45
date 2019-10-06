extends KinematicBody2D

export(float, 0.1, 100.0) var movement_speed = 100.0
export(int, 1, 100) var max_health = 1

onready var health : int = max_health
onready var dead := false
onready var facing := PI/2

signal hit(character, amount)
signal death(character)

func take_damage(damage):
	health = max(0, health - damage)
	if health > 0:
		emit_signal("hit", self, damage)
	else:
		dead = true
		emit_signal("death", self)
		queue_free()