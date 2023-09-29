extends Node2D


# map
const ProcGen = preload("res://dungeon/procgen.gd")
const Map = preload("res://dungeon/map.gd")
var map: Map
@onready var tile_map = $TileMap

# entities
const Entity = preload("res://entities/entity.gd")
const Actor = preload("res://entities/actor.gd")
const Entities = preload("res://entities/entities.gd")
var player: Entity

# event handler
const Actions = preload("res://objects/actions.gd")
var input_handler = preload("res://objects/input_handlers.gd").new()


func _ready():
	# init player
	player = Entities.SpawnPlayer()
	
	# set up a basic dungeon of rooms; also sets player position
	map = ProcGen.generate_dungeon(
		100, 100,
		25, 5, 10,
		0, 2,
		player
	)
	
	# initial draw of the entities
	map.draw_map(tile_map, player)


func _process(_delta):
	# INPUT
	var action = input_handler.dispatch(player, map)
	
	if action is Actions.EscapeAction:
		get_tree().quit()
	elif action != null:
		# if player is dead
		if player.fighter.get_hp() <= 0:
			print("You died!")
			return
		
		# player takes their turn, followed by the enemies
		action.perform()
		handle_enemy_turns()
		
		# DRAW only need to update view after input from player
		map.draw_map(tile_map, player)


func handle_enemy_turns():
	for a in map.get_actors():
		if a.ai:
			a.ai.perform(player, map)
