extends Node2D

const Chest = preload("res://scn/Chest.tscn")

const TileDef = "res://dat/tiles.json"
const RoomDef = "res://dat/rooms.json"

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
	randomize()
	
	var tileDef = read_json(TileDef)
	var roomDef = read_json(RoomDef)
	
	for x in range(roomDef[0]["tiles"].size()):
		for y in range(roomDef[0]["tiles"][x].size()):
			var tile = roomDef[0]["tiles"][x][y]
			var def = tileDef[int(tile)]
			
			if randf() < 0.1 and x > 0 and y > 0 and \
			   typeof(roomDef[0]["tiles"][x][y]) != TYPE_STRING and roomDef[0]["tiles"][x][y] == 0 and \
			   typeof(roomDef[0]["tiles"][x][y-1]) != TYPE_STRING and roomDef[0]["tiles"][x][y-1] == 0 and \
			   typeof(roomDef[0]["tiles"][x-1][y]) != TYPE_STRING and roomDef[0]["tiles"][x-1][y] == 0 and \
			   typeof(roomDef[0]["tiles"][x-1][y-1]) != TYPE_STRING and roomDef[0]["tiles"][x-1][y-1] == 0:
				roomDef[0]["tiles"][x][y] = "H"
				roomDef[0]["tiles"][x-1][y] = "H"
				roomDef[0]["tiles"][x][y-1] = "H"
				roomDef[0]["tiles"][x-1][y-1] = "H"
				$TileMap.set_cell(y - 1, x - 1,
					randi() % 2 + 12,
					true if randf() < 0.5 else false)
				$TileMap.set_cell(y - 1, x, -1)
				$TileMap.set_cell(y, x - 1, -1)
			else:
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
	
	$GUI.set_health($Player.health)
	$GUI.set_food($Player.food)
	
	$GUI.add_dialogue("You seem to be stuck in this place. How about I let you out, and you give me something later?", [ "apa", "bepa" ])
	paused = true

func _process(delta):
	if paused:
		return
	
	$Player.food = max(0, $Player.food - delta)
	$GUI.set_food($Player.food)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		get_tree().quit()

func _on_GUI_choice(id):
	print(id)
	paused = false
