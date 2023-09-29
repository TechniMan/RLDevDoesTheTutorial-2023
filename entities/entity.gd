extends Resource
class_name Entity


const RenderOrder = preload("res://entities/render_order.gd")


const sight_range: int = 10
var character: String
var colour: Color
var position: Vector2i
var name: String
var blocks_movement: bool
var render_order: int


func _init(
	_x: int = 0,
	_y: int = 0,
	_char: String = "?",
	_colour: Color = Color.WHITE,
	_name: String = "<Unnamed>",
	_blocks_movement: bool = false,
	_render_order: int = RenderOrder.CORPSE
):
	character = _char
	position = Vector2i(_x, _y)
	name = _name
	blocks_movement = _blocks_movement
	render_order = _render_order


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
