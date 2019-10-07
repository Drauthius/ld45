extends Node2D

const Choice = preload("res://src/Choice.gd")

func _ready():
	randomize()
	
	LevelGenerator.new().fill(self, $TileMap, 1)
	
	$GUI.set_health($Player.health)
	$GUI.set_food($Player.food)
	
	$GUI.add_dialogue("You seem to be stuck in this place. How about I let you out, and you give me something later?",
		[ Choice.new("I guess...", Choice.Result.BREAK_OUT) ])
	get_tree().paused = true

func _process(delta):
	$Player.food = max(0, $Player.food - delta)
	$GUI.set_food($Player.food)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		get_tree().quit()

func _on_GUI_choice(choice):
	match choice.result:
		Choice.Result.BREAK_OUT:
			$Cage.frame = 1
			$Cage.z_index = -1
		Choice.Result.RESTART:
			# warning-ignore:return_value_discarded
			get_tree().reload_current_scene()
		Choice.Result.QUIT:
			get_tree().quit()
	get_tree().paused = false

func _on_Player_hit(_character, _amount):
	$GUI.set_health($Player.health)

func _on_Player_death(_character):
	$GUI.add_dialogue("Oh my. You seem to have died. Care to try again?", [ Choice.new("Yes", Choice.Result.RESTART), Choice.new("No", Choice.Result.QUIT) ])
	get_tree().paused = true
