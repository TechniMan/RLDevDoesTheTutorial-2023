extends Resource

const Entities = preload("res://entities/entities.gd")
const Map = preload("res://dungeon/map.gd")
const Tiles = preload("res://dungeon/tiles.gd")
const Room = preload("res://dungeon/room.gd")


static var rand = RandomNumberGenerator.new()


static func generate_dungeon(
	map_width: int,
	map_height: int,
	max_rooms: int,
	min_room_size: int,
	max_room_size: int,
	min_monsters_per_room: int,
	max_monsters_per_room: int,
	player: Entity
) -> Map:
	var new_map = Map.new(map_width, map_height)
	new_map.entities.append(player)
	# initialise map as all walls
	for y in map_height:
		for x in map_width:
			new_map.set_tile(x, y, Tiles.WALL)
	# carve out some rooms
	new_map.rooms.clear()
	for r in range(max_rooms):
		# generate a size and position for the room within the bounds of the map
		var room_width = rand.randi_range(min_room_size, max_room_size)
		var room_x = rand.randi_range(1, map_width - room_width - 2)
		var room_height = rand.randi_range(min_room_size, max_room_size)
		var room_y = rand.randi_range(1, map_height - room_height - 2)
		var new_room = Rect2i(room_x, room_y, room_width, room_height)
		
		# if it intersects with an existing room, discard and try again
		if new_map.rooms.any(func(room): return room.rect.intersects(new_room)):
			continue
		# carve the room into the map
		carve_room(new_room, new_map)
		# add it to the list
		new_map.rooms.append(Room.new(new_room))
		# also add some enemies to it
		var num_monsters = rand.randi_range(min_monsters_per_room, max_monsters_per_room)
		place_entities(new_room, num_monsters, new_map)
	carve_tunnels(new_map.rooms, new_map)
	# set player position to a starting room
	player.position = new_map.rooms[0].rect.get_center()
	
	return new_map


static func carve_room(room: Rect2i, new_map: Map):
	for y in range(room.position.y + 1, room.end.y):
		for x in range(room.position.x + 1, room.end.x):
			new_map.set_tile(x, y, Tiles.FLOOR)


static func carve_tunnel(a: Vector2i, b: Vector2i, new_map: Map):
	for y in range(a.y, b.y, 1 if b.y > a.y else -1):
		new_map.set_tile(a.x, y, Tiles.FLOOR)
	for x in range(a.x, b.x, 1 if b.x > a.x else -1):
		new_map.set_tile(x, b.y, Tiles.FLOOR)


static func place_entities(room: Rect2i, num_monsters: int, new_map: Map):
	for m in range(num_monsters + 1):
		# select random spot in room
		var x = rand.randi_range(room.position.x + 1, room.end.x - 1)
		var y = rand.randi_range(room.position.y + 1, room.end.y - 1)
		
		# ensure entity's spot not already taken
		var e: Entity
		#if not entities.any(func(e): return e.position == Vector2i(x, y)):
		var v = rand.randf()
		if v < 0.8:
			e = Entities.SpawnOrc(x, y)
		else:
			e = Entities.SpawnTroll(x, y)
		new_map.entities.append(e)


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


static func carve_tunnels(rooms: Array[Room], new_map: Map):
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
		carve_tunnel(v, next_v, new_map)
		# ...and the next nearest(s)
		var extras = rand.randi_range(0, mini(3, unused_vertices.size()))
		for e in range(extras):
			carve_tunnel(v, unused_vertices[1], new_map)
		# use the nearest one next time
		v = next_v
	# finally carve from the last room to the first room to close the loop
	carve_tunnel(vertices[0], v, new_map)

