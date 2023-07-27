extends Object

const Actions = preload("res://objects/actions.gd")
const Entity = preload("res://objects/entity.gd")
const Map = preload("res://objects/map.gd")


func dispatch(actor: Entity, map: Map) -> Actions.Action:
	var action: Actions.Action = null
	
	# quit
	if Input.is_action_just_pressed("quit"):
		action = Actions.EscapeAction.new(actor, map)
	
	# player movement input
	if Input.is_action_just_pressed("move_east"):
		action = Actions.BumpAction.new(actor, map, 1, 0)
	if Input.is_action_just_pressed("move_west"):
		action = Actions.BumpAction.new(actor, map, -1, 0)
	if Input.is_action_just_pressed("move_north"):
		action = Actions.BumpAction.new(actor, map, 0, -1)
	if Input.is_action_just_pressed("move_south"):
		action = Actions.BumpAction.new(actor, map, 0, 1)
	
	# cheeky hacky speed-up shortcut; TODO remove or improve
	if action is Actions.BumpAction and Input.is_key_pressed(KEY_SHIFT):
		action.dx *= 2
		action.dy *= 2
	
	return action
