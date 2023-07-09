extends Object


var char: String
var position: Vector2i
var sight_range: int


func _init(startX: int, startY: int, character: String, vision_range: int = 10):
	char = character
	position = Vector2i(startX, startY)
	sight_range = vision_range


func move(dX: int, dY: int):
	position.x += dX
	position.y += dY
