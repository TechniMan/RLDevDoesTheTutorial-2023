extends Object
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


static var FLOOR = Tile.new(true, true, ".")
static var WALL = Tile.new(false, false, "#")
static var FOG = Tile.new(true, false, "~")
