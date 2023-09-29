extends Entity
class_name Actor


const Components = preload("res://entities/components.gd")


var ai: Components.BaseAI
var fighter: Components.Fighter


func _init(
	_x: int = 0,
	_y: int = 0,
	_char: String = "?",
	_name: String = "<Unnamed>",
	_blocks_movement: bool = false,
	_ai: Components.BaseAI = null,
	_fighter: Components.Fighter = null
):
	super(_x, _y, _char, _name, _blocks_movement)
	
	ai = _ai
	if ai != null:
		ai.owner = self
	fighter = _fighter
	fighter.owner = self


func is_alive() -> bool:
	## Returns true as long as this actor can perform actions
	return ai != null


func spawn(x: int, y: int) -> Entity:
	var clone = get_script().new(
		x,
		y,
		character,
		name,
		blocks_movement,
		ai,
		fighter
	)
	return clone
