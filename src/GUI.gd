extends CanvasLayer

export(Texture) var heart_full_icon = preload("res://gfx/heart-icon.png")
export(Texture) var heart_empty_icon = preload("res://gfx/heart-empty-icon.png")

const Dialogue = preload("res://scn/Dialogue.tscn")

onready var dialogue = null
onready var hearts = [
		$MarginContainer/GridContainer/HBoxContainer/TextureRect,
		$MarginContainer/GridContainer/HBoxContainer/TextureRect2,
		$MarginContainer/GridContainer/HBoxContainer/TextureRect3,
		$MarginContainer/GridContainer/HBoxContainer/TextureRect4
	]
onready var foodMeter = $MarginContainer/GridContainer/ProgressBar

signal choice(c)

func add_dialogue(text, choices):
	dialogue = Dialogue.instance()
	add_child(dialogue)
	dialogue.set_dialogue(text, choices)
	var _ret = dialogue.connect("choice", self, "_on_choice")

func set_health(value):
	for i in range(hearts.size()):
		hearts[i].texture = heart_full_icon if i < value else heart_empty_icon

func set_food(value):
	foodMeter.value = value
	
	if value <= 1.0:
		foodMeter.modulate = Color(1.0, 0.2, 0.2)
	else:
		foodMeter.modulate = Color(1.0, 1.0, 1.0)

func _on_choice(c):
	remove_child(dialogue)
	dialogue = null
	emit_signal("choice", c)