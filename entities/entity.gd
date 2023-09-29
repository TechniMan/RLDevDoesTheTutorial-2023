extends Resource
class_name Entity


var character: String
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
	character = _char
	position = Vector2i(_x, _y)
	name = _name
	blocks_movement = _blocks_movement


func move(dX: int, dY: int) -> void:
	position.x += dX
	position.y += dY


func place_at(x: int, y: int) -> void:
	position.x = x
	position.y = y


func spawn(x: int, y: int) -> Entity:
	var clone = get_script().new(
		x,
		y,
		character,
		name,
		blocks_movement
	)
	return clone
