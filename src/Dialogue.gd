extends Control

export(float, 0.0, 100.0) var characters_per_second = 30.0

onready var container := $PanelContainer/VBoxContainer
onready var description := container.get_node("Description")

onready var printing := false
onready var visibility_per_second := 0.0
onready var choices := []

signal choice(c)

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

func set_dialogue(text : String, _choices : Array):
	printing = true
	description.text = text
	description.percent_visible = 0
	visibility_per_second = 1 / (description.text.length() / characters_per_second)
	
	choices = _choices
	for i in range(choices.size()):
		var choice := Label.new()
		choice.text = " " + String(i + 1) + ": " + choices[i].text
		choice.visible_characters = 0
		choice.mouse_filter = Control.MOUSE_FILTER_STOP
		var _ret = choice.connect("gui_input", self, "_handle_click", [ choices[i] ])
		container.add_child(choice)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if printing and event.scancode == KEY_ESCAPE or event.scancode == KEY_SPACE:
			visibility_per_second = 1000.0
			get_tree().set_input_as_handled()
		elif not printing and event.scancode >= KEY_1 and event.scancode <= KEY_9:
			var id : int = event.scancode - KEY_0
			if id <= choices.size():
				get_tree().set_input_as_handled()
				emit_signal("choice", choices[id-1])

func _handle_click(event, c):
	if printing:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		emit_signal("choice", c)