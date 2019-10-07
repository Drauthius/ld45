extends Node

var Choice = load("res://src/Choice.gd")

onready var consequences = {}

func _ready():
	reset()

func add_consequence(consequence : int):
	consequences[consequence] += 1

func reset():
	for consequence in Choice.Consequence.values():
		consequences[consequence] = 0

func take_damage(damage, is_player):
	if is_player and consequences[Choice.Consequence.EXTRA_DAMAGE]:
		consequences[Choice.Consequence.EXTRA_DAMAGE] -= 1
		return damage * 2
	elif not is_player and consequences[Choice.Consequence.UNLUCKY_HIT]:
		consequences[Choice.Consequence.UNLUCKY_HIT] -= 1
		return 0
	
	return damage