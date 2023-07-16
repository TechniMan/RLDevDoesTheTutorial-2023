extends Node2D


# map
const MapNode = preload("res://map.tscn")
const MapScript = preload("res://nodes/map.gd")
var map: MapScript

# entities
const Entity = preload("res://objects/entity.gd")
const EntityFactories = preload("res://objects/entity_factories.gd")
var player: Entity

# event handler
const Actions = preload("res://objects/actions.gd")
var input_handler = preload("res://objects/input_handlers.gd").new()


func _ready():
	# add a map to the game
	var map_node = MapNode.instantiate()
	add_child(map_node)
	map = get_node("Map")
	
	# init player
	player = EntityFactories.player
	
	# set up a basic dungeon of rooms; also sets player position
	map.generate_dungeon(100, 100, player)
	# this is only run after the player moves, so run it once before we start so the player can see
	map.reveal_visible_tiles(player.position, player.sight_range)
	# parallax the tilemap to centre the player
	map.tilemap.position = map.map_to_px(map.half_window_height - player.position)
	# initial draw of the entities
	map.draw_entities(player)


func _process(delta):
	# INPUT
	var action = input_handler.dispatch()
	
	if action is Actions.EscapeAction:
		get_tree().quit()
	elif action != null:
		# player takes their turn, followed by the enemies
		action.perform(map, player)
		handle_enemy_turns()
		
		# DRAW only need to update view after input from player
		map.reveal_visible_tiles(player.position, player.sight_range)
		# parallax the tilemap when the player moves
		map.tilemap.position = map.map_to_px(map.half_window_height - player.position)
		map.draw_entities(player)


func handle_enemy_turns():
	for e in map.entities:
		print("The " + e.name + " wonders when it will get to take a real turn.")
