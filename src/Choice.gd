#extends Object
class_name Choice

enum Result {
	BREAK_OUT,
	NOOP,
	RESTART,
	QUIT
}

var text : String
var result : int

func _init(_text : String, _result : int):
	text = _text
	result = _result