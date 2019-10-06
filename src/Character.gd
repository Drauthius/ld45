extends KinematicBody2D

export(float, 0.1, 100.0) var speed = 2.0
export(int, 1, 100) var max_health = 1

onready var health : int = max_health
onready var dead := false
onready var facing := PI/2