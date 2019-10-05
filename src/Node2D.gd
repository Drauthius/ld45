extends Node2D

const TileSet = preload("res://res/new_tileset.tres")
const TileDef = "res://dat/tiles.json"
const RoomDef = "res://dat/rooms.json"

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
			var def = tileDef[roomDef[0][x][y]]
			$TileMap.set_cell(y, x,
				def["tiles"][randi() % def["tiles"].size()],
				true if def.has("flip_x") and def["flip_x"] and randf() < 0.5 else false,
				true if def.has("flip_y") and def["flip_y"] and randf() < 0.5 else false)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()