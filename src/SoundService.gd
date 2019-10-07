extends Node

onready var music := AudioStreamPlayer.new()

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	music.stream = preload("res://snd/ld45.ogg")
	music.set_bus("Music")
	add_child(music)
	music.play()