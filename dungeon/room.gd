extends Resource
class_name Room


var rect: Rect2i
var connected_centres: Array[Vector2i]


func _init(_rect: Rect2i):
	rect = _rect
