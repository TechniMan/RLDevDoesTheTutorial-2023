extends Node2D


# map
const MapNode = preload("res://map.tscn")
const MapScript = preload("res://Map.gd")
var map: MapScript

# entities
const Entity = preload("res://Entity.gd")
var entities: Array[Entity]
var player: Entity


func _ready():
	# add a map to the game
	var map_node = MapNode.instantiate()
	add_child(map_node)
	map = get_node("Map")
	
	# init player
	player = Entity.new(0, 0, "@", 10)
	entities.append(player)
	
	# set up a basic dungeon of rooms; also sets player position
	map.generate_dungeon(100, 100, player)
	# this is only run after the player moves, so run it once before we start so the player can see
	map.reveal_visible_tiles(player.position, player.sight_range)
	var npc1 = Entity.new(player.position.x, player.position.y - 1, "T", 10)
	entities.append(npc1)


func _process(delta):
	# INPUT
	
	# quit
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# player movement input
	var move = Vector2i.ZERO
	if Input.is_action_just_pressed("move_east"):
		move.x += 1
	if Input.is_action_just_pressed("move_west"):
		move.x -= 1
	if Input.is_action_just_pressed("move_north"):
		move.y -= 1
	if Input.is_action_just_pressed("move_south"):
		move.y += 1
	
	if (move != Vector2i.ZERO and map.is_walkable(player.position.x + move.x, player.position.y + move.y)):
		player.move(move.x, move.y)
		map.reveal_visible_tiles(player.position, player.sight_range)
		# parallax the tilemap when the player moves
		map.tilemap.position -= map.map_to_px(move)
	
	# DRAW
	map.draw_entities(entities)
