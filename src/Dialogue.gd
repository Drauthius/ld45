extends Control

export(float, 0.0, 100.0) var characters_per_second = 30.0

onready var container := $PanelContainer/VBoxContainer
onready var description := container.get_node("Description")

onready var printing := false
onready var visibility_per_second := 0.0
onready var num_choices := 0

signal choice(id)

func _process(delta):
	if not printing:
		return
	
	var speed : float = visibility_per_second
	match description.text.replace(" ", "")[max(0, description.visible_characters - 1)]:
		".", ",", "?":
			speed /= 10.0
	description.percent_visible += delta * speed
	
	if description.percent_visible >= 1.0:
		printing = false

		for choice in container.get_children():
			choice.visible_characters = -1

func set_dialogue(text : String, choices : Array):
	printing = true
	description.text = text
	description.percent_visible = 0
	visibility_per_second = 1 / (description.text.length() / characters_per_second)
	
	num_choices = choices.size()
	for i in range(num_choices):
		var choice := Label.new()
		choice.text = " " + String(i + 1) + ": " + choices[i]
		choice.visible_characters = 0
		choice.mouse_filter = Control.MOUSE_FILTER_STOP
		var _ret = choice.connect("gui_input", self, "_handle_click", [ i + 1 ])
		container.add_child(choice)

func _unhandled_input(event):	
	if event is InputEventKey and event.pressed:
		if printing and event.scancode == KEY_ESCAPE or event.scancode == KEY_SPACE:
			visibility_per_second = 1000.0
			get_tree().set_input_as_handled()
		elif event.scancode >= KEY_1 and event.scancode <= KEY_9:
			var id : int = event.scancode - KEY_0
			if id <= num_choices:
				get_tree().set_input_as_handled()
				emit_signal("choice", id)

func _handle_click(event, id):
	if printing:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		emit_signal("choice", id)