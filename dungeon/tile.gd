extends Resource
class_name Tile


var walkable: bool
var transparent: bool
var char: String
var colour: Color


func _init(_walkable: bool, _transparent: bool, _char: String):
	walkable = _walkable
	transparent = _transparent
	char = _char
	colour = Color.WHITE
