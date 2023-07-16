extends Node2D


const los = preload("res://objects/los.gd")
const Entity = preload("res://objects/entity.gd")
const EntityFactories = preload("res://objects/entity_factories.gd")


const layer_explored = 0
const layer_visible = 1
const layer_entities = 2
const layer_fog = 3

var TILE = {
	" ": Vector2i(0, 0),
	"#": Vector2i(3, 0),
	".": Vector2i(14, 0),
	"@": Vector2i(0, 1),
	
	"A": Vector2i(0, 3),
	"a": Vector2i(0, 4),
	"O": Vector2i(14, 3),
	"o": Vector2i(14, 4),
	"T": Vector2i(19, 3),
	"t": Vector2i(19, 4),
	
	"0": Vector2i(16, 0),
	"1": Vector2i(17, 0),
	"2": Vector2i(18, 0),
	"3": Vector2i(19, 0),
	"4": Vector2i(20, 0),
	"5": Vector2i(21, 0),
	"6": Vector2i(22, 0),
	"7": Vector2i(23, 0),
	"8": Vector2i(24, 0),
	"9": Vector2i(25, 0),
}

const tile_size = 10
const window_width = 80
const window_height = 50
const half_window_height = Vector2i(window_width / 2, window_height / 2)
const min_room_size = 5
const max_room_size = 10
const max_rooms = 25
const min_monsters_per_room = 0
const max_monsters_per_room = 2
var map_width
var map_height
func is_in_bounds(x: int, y: int) -> bool:
	return x > 0 and x < map_width and y > 0 and y < map_height
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

var rand = RandomNumberGenerator.new()
@onready var debug_label = $DebugLabel

var rooms: Array[Room]
var entities: Array[Entity]
func get_blocking_entity_at_location(location: Vector2i) -> Entity:
	var blockers = entities.filter(func(e: Entity): return e.blocks_movement and e.position == location)
	return blockers.front() if blockers.size() > 0 else null


func set_tile(layer: int, pos: Vector2i, tile: Vector2i, walkable: bool, transparent: bool):
	tilemap.set_cell(layer, pos, 0, tile, 0)
	set_walkable(pos.x, pos.y, walkable)
	set_transparent(pos.x, pos.y, transparent)


func set_wall(x: int, y: int):
	set_tile(layer_explored, Vector2i(x, y), TILE["#"], false, false)


func set_floor(x: int, y: int):
	set_tile(layer_explored, Vector2i(x, y), TILE["."], true, true)


func set_fog(x: int, y: int):
	tilemap.set_cell(layer_fog, Vector2i(x, y), 0, TILE[" "], 0)


class Room:
	var rect: Rect2i
	var connected_centres: Array[Vector2i]
	func _init(_rect: Rect2i):
		rect = _rect


func generate_dungeon(width: int, height: int, player: Entity):
	map_width = width
	map_height = height
	var start_time = Time.get_ticks_msec()
	# initialise map as all walls
	for y in map_height:
		for x in map_width:
			walkable.append(false)
			transparent.append(false)
			set_wall(x, y)
			set_fog(x, y)
	# carve out some rooms
	rooms.clear()
	for r in range(max_rooms):
		# generate a size and position for the room within the bounds of the map
		var room_width = rand.randi_range(min_room_size, max_room_size)
		var room_x = rand.randi_range(1, map_width - room_width - 2)
		var room_height = rand.randi_range(min_room_size, max_room_size)
		var room_y = rand.randi_range(1, map_height - room_height - 2)
		var new_room = Rect2i(room_x, room_y, room_width, room_height)
		
		# if it intersects with an existing room, discard and try again
		if rooms.any(func(room): return room.rect.intersects(new_room)):
			continue
		# carve the room into the map
		carve_room(new_room)
		# add it to the list
		rooms.append(Room.new(new_room))
		# also add some enemies to it
		place_entities(new_room)
	carve_tunnels(rooms)
	# set player position to a starting room
	player.position = rooms[0].rect.get_center()
	# shift tilemap so that player is in centre of the window
	tilemap.position = map_to_px(half_window_height - player.position)
	# time to generate?
	var end_time = Time.get_ticks_msec()
	debug_label.text = "Map generated in " + str(end_time - start_time) + "ms"


func carve_room(room: Rect2i):
	for y in range(room.position.y + 1, room.end.y):
		for x in range(room.position.x + 1, room.end.x):
			set_floor(x, y)


func carve_tunnel(a: Vector2i, b: Vector2i):
	for y in range(a.y, b.y, 1 if b.y > a.y else -1):
		set_floor(a.x, y)
	for x in range(a.x, b.x, 1 if b.x > a.x else -1):
		set_floor(x, b.y)


func place_entities(room: Rect2i):
	var num_monsters = rand.randi_range(min_monsters_per_room, max_monsters_per_room)
	
	for m in range(num_monsters + 1):
		# select random spot in room
		var x = rand.randi_range(room.position.x + 1, room.end.x - 1)
		var y = rand.randi_range(room.position.y + 1, room.end.y - 1)
		
		# ensure entity's spot not already taken
		var e: Entity
		#if not entities.any(func(e): return e.position == Vector2i(x, y)):
		var v = rand.randf()
		if v < 0.8:
			e = EntityFactories.orc.spawn(x, y)
		else:
			e = EntityFactories.troll.spawn(x, y)
		entities.append(e)


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
	pass


func reveal_visible_tiles(position: Vector2i, radius: int):
	tilemap.clear_layer(layer_visible)
	#var tiles = list_visible_tiles_in_range(position, radius)
	var tiles = los.get_visible_points(position, Callable(self, "is_transparent"), 10)
	# draw all tiles visible to player, hiding all fog
	for t in tiles:
		var tile = tilemap.get_cell_atlas_coords(layer_explored, t)
		tilemap.set_cell(layer_visible, t, 0, tile, 0)
		tilemap.erase_cell(layer_fog, t)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func draw_entities(player: Entity):
	var tiles = los.get_visible_points(player.position, Callable(self, "is_transparent"), 10)
	# clear the entity layer ready to redraw
	tilemap.clear_layer(layer_entities)
	# draw all entities visible to player
	for e in entities:
		if tiles.any(func (v): return e.position == v):
			tilemap.set_cell(layer_entities, e.position, 0, TILE[e.char], 0)
	# draw the player
	tilemap.set_cell(layer_entities, player.position, 0, TILE[player.char], 0)
