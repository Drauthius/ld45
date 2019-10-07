extends Node
class_name LevelGenerator

const TileDefinition = "res://dat/tiles2.json"
#const RoomDefinition = "res://dat/rooms.json"

const Chest = preload("res://scn/Chest.tscn")

const Size = { w = 16, h = 12 }

enum Direction { LEFT, RIGHT, UP, DOWN }

var tilemap : TileMap
var tileDefs

func fill(node, _tilemap, _level):
	tilemap = _tilemap
	tileDefs = _read_json(TileDefinition)
	
	var map = {}
	var path = []
	
	var dir = randi() % Direction.size()
	var x = 0
	var y = 0
	_create_terminal_room(dir, x, y)
	match dir:
		Direction.LEFT: x = x - Size.w
		Direction.RIGHT: x = x + Size.w
		Direction.UP: y = y - Size.h
		Direction.DOWN: y = y + Size.h
	_create_intersection(x, y)

func _create_terminal_room(dir : int, x : int, y : int) -> void:
	if dir != Direction.UP:
		for ox in range(x, x + Size.w):
			_set_cell(ox, y, tileDefs["bottom-wall"])
			_set_cell(ox, y+1, tileDefs["top-wall"])
	
	if dir != Direction.LEFT:
		for oy in range(y, y + Size.h):
			_set_cell(x, oy, tileDefs["side-wall"])
		if _get_cell(x + 1, y + 1) != -1:
			_set_cell(x + 1, y + 1, tileDefs["topleft-wall"])
	
	if dir != Direction.RIGHT:
		for oy in range(y, y + Size.h):
			_set_cell(x + Size.w - 1, oy, tileDefs["side-wall"])
		if _get_cell(x + Size.w - 2, y + 1) != -1:
			_set_cell(x + Size.w - 2, y + 1, tileDefs["topright-wall"])
	
	if dir != Direction.DOWN:
		for ox in range(x, x + Size.w):
			_set_cell(ox, y + Size.h - 1, tileDefs["bottom-wall"])
	
	for ox in range(x, x + Size.w):
		for oy in range(y, y + Size.h):
			if _get_cell(ox, oy) == -1:
				_set_cell(ox, oy, tileDefs["ground"])

func _create_intersection(x : int, y : int) -> void:
	pass

func _get_cell(x, y):
	return tilemap.get_cell(x, y) #y, x)

func _set_cell(x, y, tileDef):
	tilemap.set_cell(x, y, #y, x,
		tileDef["tiles"][randi() % tileDef["tiles"].size()],
		true if tileDef.has("flip_x") and tileDef["flip_x"] and randf() < 0.5 else false,
		true if tileDef.has("flip_y") and tileDef["flip_y"] and randf() < 0.5 else false)

#func fill(node, tilemap, _level):
#	var tileDef = read_json(TileDefinition)
#	var roomDef = read_json(RoomDefinition)
#
#	for x in range(roomDef[0]["tiles"].size()):
#		for y in range(roomDef[0]["tiles"][x].size()):
#			var tile = roomDef[0]["tiles"][x][y]
#			var def = tileDef[int(tile)]
#
#			if randf() < 0.1 and x > 0 and y > 0 and \
#			   typeof(roomDef[0]["tiles"][x][y]) != TYPE_STRING and roomDef[0]["tiles"][x][y] == 0 and \
#			   typeof(roomDef[0]["tiles"][x][y-1]) != TYPE_STRING and roomDef[0]["tiles"][x][y-1] == 0 and \
#			   typeof(roomDef[0]["tiles"][x-1][y]) != TYPE_STRING and roomDef[0]["tiles"][x-1][y] == 0 and \
#			   typeof(roomDef[0]["tiles"][x-1][y-1]) != TYPE_STRING and roomDef[0]["tiles"][x-1][y-1] == 0:
#				roomDef[0]["tiles"][x][y] = "H"
#				roomDef[0]["tiles"][x-1][y] = "H"
#				roomDef[0]["tiles"][x][y-1] = "H"
#				roomDef[0]["tiles"][x-1][y-1] = "H"
#				tilemap.set_cell(y - 1, x - 1,
#					randi() % 2 + 12,
#					true if randf() < 0.5 else false)
#				tilemap.set_cell(y - 1, x, -1)
#				tilemap.set_cell(y, x - 1, -1)
#			else:
#				tilemap.set_cell(y, x,
#					def["tiles"][randi() % def["tiles"].size()],
#					true if def.has("flip_x") and def["flip_x"] and randf() < 0.5 else false,
#					true if def.has("flip_y") and def["flip_y"] and randf() < 0.5 else false)
#
#			if typeof(tile) == TYPE_STRING:
#				match tile:
#					"C":
#						var obj := Chest.instance()
#						node.add_child(obj)
#						obj.position = tilemap.map_to_world(Vector2(y, x)) + tilemap.cell_size / 2

func _read_json(file : String) -> JSONParseResult:
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