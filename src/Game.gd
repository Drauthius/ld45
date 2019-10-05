extends Node2D

const Dialogue = preload("res://scn/Dialogue.tscn")

const TileSet = preload("res://res/new_tileset.tres")
const Chest = preload("res://scn/Chest.tscn")

const TileDef = "res://dat/tiles.json"
const RoomDef = "res://dat/rooms.json"

onready var dialogue
onready var paused := false

func read_json(file : String) -> JSONParseResult:
	var f := File.new()
	var err := f.open(file, File.READ)
	if err != OK:
		print("Could not open file ", file, ": ", err)
		get_tree().quit()
	
	var content := f.get_as_text()
	f.close()
	
	var json := JSON.parse(content)
	if json.error != OK:
		print("JSON parsing failed from file ", file, ": ", json.error_string)
		get_tree().quit()
	
	return json.result

# Called when the node enters the scene tree for the first time.
func _ready():
	var tileDef = read_json(TileDef)
	var roomDef = read_json(RoomDef)
	
	for x in range(roomDef[0].size()):
		for y in range(roomDef[0][x].size()):
			var tile = roomDef[0][x][y]
			var def = tileDef[int(tile)]
			$TileMap.set_cell(y, x,
				def["tiles"][randi() % def["tiles"].size()],
				true if def.has("flip_x") and def["flip_x"] and randf() < 0.5 else false,
				true if def.has("flip_y") and def["flip_y"] and randf() < 0.5 else false)
			if typeof(tile) == TYPE_STRING:
				match tile:
					"C":
						var obj := Chest.instance()
						add_child(obj)
						obj.position = $TileMap.map_to_world(Vector2(y, x)) + $TileMap.cell_size / 2
	
	paused = true
	dialogue = Dialogue.instance()
	add_child(dialogue)
	dialogue.set_dialogue("You seem to be stuck in this place. How about I let you out, and you give me something later?", [ "apa", "bepa" ])
	var _ret = dialogue.connect("choice", self, "_on_choice")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		get_tree().quit()

func _on_choice(id):
	print(id)
	remove_child(dialogue)
	paused = false