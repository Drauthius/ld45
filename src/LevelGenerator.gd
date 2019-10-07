extends Node
class_name LevelGenerator

const TileDefinition = "res://dat/tiles.json"

const Chest = preload("res://scn/Chest.tscn")

const Size = { w = 12, h = 8 }

enum Direction { LEFT, RIGHT, UP, DOWN }

var tilemap : TileMap
var tileDefs
var map := {}
var path := []

func fill(node, _tilemap, _level):
	tilemap = _tilemap
	tileDefs = _read_json(TileDefinition)

	var dir = randi() % Direction.size()
	var room := Vector2(0, 0)
	map[room.x] = {}
	map[room.x][room.y] = dir
	
	# warning-ignore:return_value_discarded
	_create_room(dir, 0, room)
	path.append(room)
	
	while true:
		room = _translate(room, dir)
		dir = _flip(dir)
		
		var num_exits = 1 if path.size() < 4 else 0
		var open = _create_room(dir, num_exits, room)
		path.append(room)
		
		if open.size() == 0:
			break
		
		dir = open[randi() % open.size()]

func _translate(room : Vector2, dir : int) -> Vector2:
	match dir:
		Direction.LEFT: return room + Vector2(-1, 0)
		Direction.RIGHT: return room + Vector2(1, 0)
		Direction.UP: return room + Vector2(0, -1)
		Direction.DOWN: return room + Vector2(0, 1)

func _flip(dir : int) -> int:
	match dir:
		Direction.LEFT: return Direction.RIGHT
		Direction.RIGHT: return Direction.LEFT
		Direction.UP: return Direction.DOWN
		Direction.DOWN: return Direction.UP

# warning-ignore:unused_argument
func _create_room(from : int, num_open : int, room : Vector2) -> Array:
	var available = []
	for dir in Direction.values():
		var r = _translate(room, dir)
		if not map.has(r.x) or not map[r.x].has(r.y):
			available.append(dir)
	
	var open = {}
	for dir in range(Direction.size()):
		open[dir] = from == dir
	
	# warning-ignore:narrowing_conversion
	num_open = min(available.size() - 1, num_open)
	while num_open > 0:
		var dir = randi() % Direction.size()
		if not open[dir]:
			open[dir] = true
			num_open -= 1
	
	var x : int = room.x * Size.w
	var y : int = room.y * Size.h
	
	if not open[Direction.UP]:
		for ox in range(x, x + Size.w):
			_set_cell(ox, y, tileDefs["bottom-wall"])
			_set_cell(ox, y+1, tileDefs["top-wall"])
	
	if not open[Direction.LEFT]:
		for oy in range(y, y + Size.h):
			_set_cell(x, oy, tileDefs["side-wall"])
		if _get_cell(x + 1, y + 1) != -1:
			_set_cell(x + 1, y + 1, tileDefs["topleft-wall"])
	
	if not open[Direction.RIGHT]:
		for oy in range(y, y + Size.h):
			_set_cell(x + Size.w - 1, oy, tileDefs["side-wall"])
		if _get_cell(x + Size.w - 2, y + 1) != -1:
			_set_cell(x + Size.w - 2, y + 1, tileDefs["topright-wall"])
	
	if not open[Direction.DOWN]:
		for ox in range(x, x + Size.w):
			_set_cell(ox, y + Size.h - 1, tileDefs["bottom-wall"])
	
	for ox in range(x, x + Size.w):
		for oy in range(y, y + Size.h):
			if _get_cell(ox, oy) == -1:
				_set_cell(ox, oy, tileDefs["ground"])
	
	var dirs = []
	for dir in open.keys():
		if open[dir] and dir != from:
			dirs.append(dir)
	return dirs

func _get_cell(x, y):
	return tilemap.get_cell(x, y) #y, x)

func _set_cell(x, y, tileDef):
	tilemap.set_cell(x, y, #y, x,
		tileDef["tiles"][randi() % tileDef["tiles"].size()],
		tileDef.has("flip_x") and tileDef["flip_x"] and randf() < 0.5,
		tileDef.has("flip_y") and tileDef["flip_y"] and randf() < 0.5)

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