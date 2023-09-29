extends Resource
class_name Map


const los = preload("res://objects/los.gd")
const Entity = preload("res://entities/entity.gd")
const Entities = preload("res://entities/entities.gd")
const Tiles = preload("res://dungeon/tiles.gd")
const Room = preload("res://dungeon/room.gd")


const layer_explored = 0
const layer_visible = 1
const layer_entities = 2


const CHAR_TO_ATLAS = {
	# symbols
	" ": Vector2i(0, 0),
	"#": Vector2i(3, 0),
	"%": Vector2i(5, 0),
	".": Vector2i(14, 0),
	"@": Vector2i(0, 1),
	"~": Vector2i(10, 1),
	# letters
	"A": Vector2i(0, 3),
	"a": Vector2i(0, 4),
	"O": Vector2i(14, 3),
	"o": Vector2i(14, 4),
	"T": Vector2i(19, 3),
	"t": Vector2i(19, 4),
	# numbers
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


# MAP MEMBERS

const tile_size = 10
const window_width = 80
const window_height = 50
const half_window_height = Vector2i(window_width / 2.0, window_height / 2.0)
var map_width: int
var map_height: int

func is_in_bounds(x: int, y: int) -> bool:
	return x > 0 and x < map_width and y > 0 and y < map_height
static func map_to_px(map_coords: Vector2i) -> Vector2:
	return map_coords * tile_size

var tile_map: Array[Tile]
func get_tile(x: int, y: int) -> Tile:
	return tile_map[x + y * map_width]
func set_tile(x: int, y: int, v: Tile) -> void:
	tile_map[x + y * map_width] = v
func is_walkable(x: int, y: int) -> bool:
	return tile_map[x + y * map_width].walkable
func is_transparent(x: int, y: int) -> bool:
	return tile_map[x + y * map_width].transparent

var grid: AStarGrid2D
var visible_tiles: Array[bool]
func is_visible(x: int, y: int) -> bool:
	return visible_tiles[x + y * map_width]
func set_visible(x: int, y: int, v: bool) -> void:
	visible_tiles[x + y * map_width] = v

var explored_tiles: Array[bool]
func is_explored(x: int, y: int) -> bool:
	return explored_tiles[x + y * map_width]
func explore(x: int, y: int):
	explored_tiles[x + y * map_width] = true

var entities: Array[Entity]
var rooms: Array[Room]

# END MAP MEMBERS


func _init(width: int, height: int):
	map_width = width
	map_height = height
	# initialise arrays
	tile_map.resize(map_width * map_height)
	tile_map.fill(Tiles.FOG)
	explored_tiles.resize(map_width * map_height)
	explored_tiles.fill(false)
	visible_tiles.resize(map_width * map_height)
	visible_tiles.fill(false)
	
	# initialise cost array
	grid = AStarGrid2D.new()
	grid.set_region(Rect2i(0, 0, map_width, map_height))
	grid.update()


func get_actors() -> Array[Actor]:
	var actors: Array[Actor] = []
	for e in entities:
		if e is Actor and (e as Actor).fighter.is_alive:
			actors.append(e)
	return actors


func get_blocking_entity_at_location(location: Vector2i) -> Entity:
	var blockers = entities.filter(func(e: Entity): return e.blocks_movement and e.position == location)
	return blockers.front() if blockers.size() > 0 else null


func get_actor_at_location(location: Vector2i) -> Actor:
	for a in get_actors():
		if a.position == location:
			return a
	return null


## Finds best path from from to to; if no valid path exists, returns empty
func get_path_to(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	return grid.get_id_path(from, to)


## Draws the world tiles and entities onto the given TileMap
func draw_map(tilemap: TileMap, player: Entity):
	# clear the layers ready to draw
	tilemap.clear_layer(layer_explored)
	tilemap.clear_layer(layer_visible)
	tilemap.clear_layer(layer_entities)
	
	# shift tilemap so that player is in centre of the window
	tilemap.position = Map.map_to_px(half_window_height - player.position)
	
	# set up the nav grid ready for filling in
	grid.clear()
	grid.set_region(Rect2i(0, 0, map_width, map_height))
	grid.update()
	
	# FIRST DRAW THE WORLD #
	
	visible_tiles.fill(false)
	var visible_points = los.get_visible_points(player.position, Callable(self, "is_transparent"), 10)
	
	# fill the explored map with fog or dark explored tiles
	for y in range(map_height):
		for x in range(map_width):
			var v = Vector2i(x, y)
			if is_explored(x, y):
				tilemap.set_cell(layer_explored, v, 0, CHAR_TO_ATLAS[get_tile(x, y).character])
			else:
				tilemap.set_cell(layer_explored, v, 0, CHAR_TO_ATLAS[Tiles.FOG.character])
			
			# fill in light visible tiles
			if visible_points.find(v) != -1:
				tilemap.set_cell(layer_visible, v, 0, CHAR_TO_ATLAS[get_tile(x, y).character])
				explore(x, y)
				set_visible(x, y, true)
			else:
				set_visible(x, y, false)
			
			# fill nav grid with walkability values
			grid.set_point_solid(v, is_walkable(x, y))
	grid.update()
	# THEN DRAW THE ENTITIES #
	
	# draw all entities visible to player
	entities.sort_custom(func(a, b): return a.render_order < b.render_order)
	for e in entities:
		if is_visible(e.position.x, e.position.y):
			tilemap.set_cell(layer_entities, e.position, 0, CHAR_TO_ATLAS[e.character], 0)
		# and add entity to nav grid
		if e.blocks_movement:
			# A lower number means more enemies will crowd behind each other in
			# hallways. A higher number means enemies will take longer paths in
			# order to surround the player.
			grid.set_point_weight_scale(Vector2i(e.position.x, e.position.y), 1)
	
	# draw the player
	tilemap.set_cell(layer_entities, player.position, 0, CHAR_TO_ATLAS[player.character], 0)
