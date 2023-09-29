extends Resource

const Action = preload("res://objects/actions.gd")
const Entity = preload("res://entities/entity.gd")
const Map = preload("res://dungeon/map.gd")


func dispatch(actor: Entity, map: Map) -> Action:
	var action: Action = null
	
	# quit
	if Input.is_action_just_pressed("quit"):
		action = Action.EscapeAction.new(actor, map)
	
	# player movement input
	if Input.is_action_just_pressed("move_east"):
		action = Action.BumpAction.new(actor, map, 1, 0)
	if Input.is_action_just_pressed("move_west"):
		action = Action.BumpAction.new(actor, map, -1, 0)
	if Input.is_action_just_pressed("move_north"):
		action = Action.BumpAction.new(actor, map, 0, -1)
	if Input.is_action_just_pressed("move_south"):
		action = Action.BumpAction.new(actor, map, 0, 1)
	
	# cheeky hacky speed-up shortcut; TODO remove or improve
	if action is Action.BumpAction and Input.is_key_pressed(KEY_SHIFT):
		action.dx *= 2
		action.dy *= 2
	
	return action
