extends Node

onready var music := AudioStreamPlayer.new()

onready var sounds = {
	"weapon_swing": preload("res://snd/swing.wav"),
	"hit": preload("res://snd/hit.wav"),
	"dead": preload("res://snd/dead.wav")
}
onready var sfx = {}

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	music.stream = preload("res://snd/ld45.ogg")
	music.set_bus("Music")
	add_child(music)
	music.play()
	
	for sound in sounds:
		sfx[sound] = AudioStreamPlayer.new()
		sfx[sound].stream = sounds[sound]
		add_child(sfx[sound])

func play(sound):
	sfx[sound].play()