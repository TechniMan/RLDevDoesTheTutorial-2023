extends Resource

const Action = preload("res://objects/actions.gd")
const Entity = preload("res://entities/entity.gd")
const Map = preload("res://dungeon/map.gd")


# const MOVE_DIRECTIONS = {
# 	"move_north" = Vector2i(0, -1)
# }


func dispatch(actor: Entity, map: Map) -> Action:
	var action: Action = null
	
	# quit
	if Input.is_action_just_pressed("quit"):
		action = Action.EscapeAction.new(actor, map)
	
	# player movement input
	if Input.is_action_just_pressed("move_north"):
		action = Action.BumpAction.new(actor, map, 0, -1)
	if Input.is_action_just_pressed("move_northeast"):
		action = Action.BumpAction.new(actor, map, 1, -1)
	if Input.is_action_just_pressed("move_east"):
		action = Action.BumpAction.new(actor, map, 1, 0)
	if Input.is_action_just_pressed("move_southeast"):
		action = Action.BumpAction.new(actor, map, 1, 1)
	if Input.is_action_just_pressed("move_south"):
		action = Action.BumpAction.new(actor, map, 0, 1)
	if Input.is_action_just_pressed("move_southwest"):
		action = Action.BumpAction.new(actor, map, -1, 1)
	if Input.is_action_just_pressed("move_west"):
		action = Action.BumpAction.new(actor, map, -1, 0)
	if Input.is_action_just_pressed("move_northwest"):
		action = Action.BumpAction.new(actor, map, -1, -1)
	
	if Input.is_action_just_pressed("wait"):
		action = Action.WaitAction.new(actor, map)
	
	# cheeky hacky speed-up shortcut; TODO remove or improve
	if action is Action.BumpAction and Input.is_key_pressed(KEY_SHIFT):
		action.dx *= 2
		action.dy *= 2
	
	return action
