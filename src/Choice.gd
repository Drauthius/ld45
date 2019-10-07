#extends Object
class_name Choice

enum Result {
	BREAK_OUT,
	NOOP,
	WEAPON,
	RESTART,
	QUIT
}

enum Consequence {
	CURSED_CHEST,
	UNLUCKY_HIT,
	EXTRA_DAMAGE
}

var text : String
var result : int
var consequence

func _init(_text : String, _result : int, _consequence = null):
	text = _text
	result = _result
	consequence = _consequence

static func random(num : int, result : int) -> Array:
	assert(num < Consequence.size())
	
	var consequences = Consequence.values()
	var ret = []
	for _i in range(num):
		var i = randi() % consequences.size()
		var consequence = consequences[i]
		consequences.remove(i)
		
		var text
		match consequence:
			Consequence.CURSED_CHEST:
				text = "The next chest you open is cursed"
			Consequence.UNLUCKY_HIT:
				text = "Your next attack is unlucky"
			Consequence.EXTRA_DAMAGE:
				text = "The next damage you take will hurt more"
		
		ret.append(load("res://src/Choice.gd").new(text, result, consequence))
	
	return ret