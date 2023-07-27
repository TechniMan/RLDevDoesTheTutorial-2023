extends Node2D


# map
const Map = preload("res://objects/map.gd")
var map: Map
const ProcGen = preload("res://objects/procgen.gd")
@onready var tile_map = $TileMap

# entities
const Entity = preload("res://objects/entity.gd")
const EntityFactories = preload("res://objects/entity_factories.gd")
var player: Entity

# event handler
const Actions = preload("res://objects/actions.gd")
var input_handler = preload("res://objects/input_handlers.gd").new()


func _ready():
	# init player
	player = EntityFactories.player
	
	# set up a basic dungeon of rooms; also sets player position
	map = ProcGen.generate_dungeon(
		100, 100,
		25, 5, 10,
		0, 2,
		player
	)
	
	# initial draw of the entities
	map.draw_map(tile_map, player)


func _process(delta):
	# INPUT
	var action = input_handler.dispatch(player, map)
	
	if action is Actions.EscapeAction:
		get_tree().quit()
	elif action != null:
		# player takes their turn, followed by the enemies
		action.perform()
		handle_enemy_turns()
		
		# DRAW only need to update view after input from player
		map.draw_map(tile_map, player)


func handle_enemy_turns():
	for e in map.entities:
		print("The " + e.name + " wonders when it will get to take a real turn.")
