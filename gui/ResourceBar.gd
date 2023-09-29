extends ProgressBar


@export var starting_value: int
@export var maximum_value: int
@export var length: int
@export var background: StyleBoxFlat
@export var foreground: StyleBoxFlat


func _ready():
	max_value = maximum_value
	value = starting_value
	size.x = length
	add_theme_stylebox_override(&"background", background)
	add_theme_stylebox_override(&"fill", foreground)
