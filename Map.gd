extends Node2D


const los = preload("res://los.gd")


const layer_explored = 0
const layer_visible = 1
const layer_entities = 2
const layer_fog = 3

const tile_fog = Vector2i(0, 0)
const tile_wall = Vector2i(3, 0)
const tile_floor = Vector2i(14, 0)
const tile_player = Vector2i(0, 1)
func tile_num(n):
	return Vector2i(16 + n, 0)
func tile_char(c: String):
	return Vector2i(c.unicode_at(0) - "a".unicode_at(0), 4)

var tile_size = 10
const window_width = 160
const window_height = 100
var map_width = 100
var map_height = 100
func map_to_px(map_coords: Vector2i) -> Vector2:
	return map_coords * tile_size
@onready var tilemap = $TileMap

var walkable: Array[bool]
func is_walkable(x: int, y: int) -> bool:
	return !walkable[x + y * map_width]
func set_walkable(x: int, y: int, v: bool):
	walkable[x + y * map_width] = not v

var transparent: Array[bool]
func is_transparent(x: int, y: int) -> bool:
	return transparent[x + y * map_width]
func set_transparent(x: int, y: int, v: bool):
	transparent[x + y * map_width] = v

var player_pos: Vector2i
var player_los: int
var rand = RandomNumberGenerator.new()
@onready var debug_label = $DebugLabel


func set_tile(layer: int, pos: Vector2i, tile: Vector2i, walkable: bool, transparent: bool):
	tilemap.set_cell(layer, pos, 0, tile, 0)
	set_walkable(pos.x, pos.y, walkable)
	set_transparent(pos.x, pos.y, transparent)


func set_wall(x: int, y: int):
	set_tile(layer_explored, Vector2i(x, y), tile_wall, false, false)


func set_floor(x: int, y: int):
	set_tile(layer_explored, Vector2i(x, y), tile_floor, true, true)


func set_fog(x: int, y: int):
	tilemap.set_cell(layer_fog, Vector2i(x, y), 0, tile_fog, 0)


class Room:
	var rect: Rect2i
	var connected_centres: Array[Vector2i]
	func _init(_rect: Rect2i):
		rect = _rect


func generate_dungeon(width: int, height: int):
	var start_time = Time.get_ticks_msec()
	# initialise map as all walls
	for y in map_height:
		for x in map_width:
			walkable.append(false)
			transparent.append(false)
			set_wall(x, y)
			#set_fog(x, y)
	# carve out some rooms
	var rooms: Array[Room]
	for r in range(20):
		var room_width = rand.randi_range(3, 10)
		var room_x = rand.randi_range(1, map_width - room_width - 2)
		var room_height = rand.randi_range(3, 10)
		var room_y = rand.randi_range(1, map_height - room_height - 2)
		var new_room = Rect2i(room_x, room_y, room_width, room_height)
		# if it intersects with an existing room, discard and try again
		if rooms.any(func(room): room.rect.intersects(new_room)):
			continue
		# carve the room into the map
		carve_room(new_room)
		# add it to the list
		rooms.append(Room.new(new_room))
	# carve out some tunnels between nearby rooms
	#	for room in rooms:
	#		var nearestRoom: Room = rooms.reduce(
	#			func(current_nearest: Room, r: Room):
	#				var d_new = (r.rect.get_center() - room.rect.get_center()).length()
	#				if d_new == 0 or room.connected_centres.any(func(c): return c == r.rect.get_center()):
	#					return current_nearest
	#				var d_old = (current_nearest.rect.get_center() - room.rect.get_center()).length()
	#				return r if d_new < d_old else current_nearest
	#		)
	#		room.connected_centres.append(nearestRoom.rect.get_center())
	#		nearestRoom.connected_centres.append(room.rect.get_center())
	#		carve_tunnel(room.rect.get_center(), nearestRoom.rect.get_center())
	#	# and again!
	#	for room in rooms:
	#		var nearestRoom: Room = rooms.reduce(
	#			func(current_nearest: Room, r: Room):
	#				var d_new = (r.rect.get_center() - room.rect.get_center()).length()
	#				if d_new == 0 or room.connected_centres.any(func(c): return c == r.rect.get_center()):
	#					return current_nearest
	#				var d_old = (current_nearest.rect.get_center() - room.rect.get_center()).length()
	#				return r if d_new < d_old else current_nearest
	#		)
	#		room.connected_centres.append(nearestRoom.rect.get_center())
	#		nearestRoom.connected_centres.append(room.rect.get_center())
	#		carve_tunnel(room.rect.get_center(), nearestRoom.rect.get_center())
	carve_tunnels(rooms)
	# set player position to a starting room
	player_pos = rooms[0].rect.get_center()
	# shift tilemap so that player is in centre of the window
	#tilemap.position = map_to_px(Vector2i(window_width / 2, window_height / 2))
	#tilemap.position -= map_to_px(player_pos)
	var end_time = Time.get_ticks_msec()
	debug_label.text = "Map generated in " + str(end_time - start_time) + "ms"


func carve_room(room: Rect2i):
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			set_floor(x, y)


func carve_tunnel(a: Vector2i, b: Vector2i):
	for y in range(a.y, b.y, 1 if b.y > a.y else -1):
		set_floor(a.x, y)
	for x in range(a.x, b.x, 1 if b.x > a.x else -1):
		set_floor(x, b.y)


class Connection:
	var a: Vector2i
	var b: Vector2i
	
	func _init(_a, _b):
		a = _a
		b = _b
	
	# magnitude/length of the connection
	func magnitude() -> int:
		return (b - a).length()
	
	# True if connections share the same pair of points
	func equals(other: Connection) -> bool:
		return (a == other.a and b == other.b) or (a == other.b and b == other.a)


func carve_tunnels(rooms: Array[Room]):
	#	# init dictionary
	#	var connections: Array[Connection]
	#	# put in initial attempt at connections
	#	for room in rooms:
	#		rooms.sort_custom(func(a: Room, b: Room):
	#			var da = (room.rect.get_center() - a.rect.get_center()).length()
	#			var db = (room.rect.get_center() - b.rect.get_center()).length()
	#			return da <= db
	#		)
	#		connections.append(Connection.new(room.rect.get_center(), rooms[1].rect.get_center()))
	#		connections.append(Connection.new(room.rect.get_center(), rooms[2].rect.get_center()))
	#		connections.append(Connection.new(room.rect.get_center(), rooms[3].rect.get_center()))
	#	var duplicate_indices: Array[int]
	#	for c in range(connections.size() - 1):
	#		for d in range(c + 1, connections.size()):
	#			# if duplicate, remove it
	#			if connections[c].equals(connections[d]):
	#				duplicate_indices.append(d)
	#	# try and remove the later ones first, so the earlier indices are still correct
	#	duplicate_indices.sort()
	#	duplicate_indices.reverse()
	#	for d in duplicate_indices:
	#		connections.remove_at(d)
	#	#TODO restrict connections to 2 per room?
	#	# carve those tunnels
	#	for c in connections:
	#		carve_tunnel(c.a, c.b)
	var vertices = rooms.map(func(r: Room): return r.rect.get_center())
	var unused_vertices = vertices.duplicate(true)
	var v = vertices[0]
	while unused_vertices.size() > 2:
		# remove self
		unused_vertices.remove_at(unused_vertices.find(v))
		# sort remaining linkable room centres
		unused_vertices.sort_custom(func(a, b):
			var da = (v - a).length()
			var db = (v - b).length()
			return da < db
		)
		# carve tunnel to the nearest...
		var next_v = unused_vertices.front()
		carve_tunnel(v, next_v)
		# ...and the next nearest(s)
		var extras = rand.randi_range(0, mini(3, unused_vertices.size()))
		for e in range(extras):
			carve_tunnel(v, unused_vertices[1])
		# use the nearest one next time
		v = next_v
	# finally carve from the last room to the first room to close the loop
	carve_tunnel(vertices[0], v)


# Called when the node enters the scene tree for the first time.
func _ready():
	# set up a basic dungeon of rooms
	# also sets player position
	generate_dungeon(map_width, map_height)
	tilemap.set_cell(layer_entities, player_pos, 0, tile_player, 0)
	player_los = 10
	reveal_visible_tiles(player_pos, player_los)


func reveal_visible_tiles(position: Vector2i, radius: int):
	tilemap.clear_layer(layer_visible)
	#var tiles = list_visible_tiles_in_range(position, radius)
	var tiles = los.get_visible_points(player_pos, Callable(self, "is_transparent"), 10)
	for t in tiles:
		var tile = tilemap.get_cell_atlas_coords(layer_explored, t)
		tilemap.set_cell(layer_visible, t, 0, tile, 0)
		tilemap.erase_cell(layer_fog, t)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
	
	if (move != Vector2i.ZERO and is_walkable(player_pos.x + move.x, player_pos.y + move.y)):
		player_pos += move
		reveal_visible_tiles(player_pos, player_los)
		# parallax the tilemap when the player moves
		tilemap.position -= map_to_px(move)
	# debug_label.text = "frametime: " + str(int(_delta * 1000)) + " fps: " + str(int(1.0 / _delta))
	# debug_label.text = str(player_pos) + " " + str(player_pos + Vector2i(player_los, player_los))
	
	draw_entities()


func draw_entities():
	# clear the entity layer ready to redraw
	tilemap.clear_layer(layer_entities)
	# player
	tilemap.set_cell(layer_entities, player_pos, 0, tile_player, 0)
