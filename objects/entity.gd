extends Object
class_name Entity


var char: String
var position: Vector2i
const sight_range: int = 10
var name: String
var blocks_movement: bool


func _init(
	_x: int = 0,
	_y: int = 0,
	_char: String = "?",
	_name: String = "<Unnamed>",
	_blocks_movement: bool = false
):
	char = _char
	position = Vector2i(_x, _y)
	name = _name
	blocks_movement = _blocks_movement


func move(dX: int, dY: int):
	position.x += dX
	position.y += dY


func spawn(x: int, y: int) -> Entity:
	var clone = get_script().new(
		x,
		y,
		char,
		name,
		blocks_movement
	)
	return clone
