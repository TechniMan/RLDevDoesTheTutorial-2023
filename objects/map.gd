extends Object


const los = preload("res://objects/los.gd")
const Entity = preload("res://objects/entity.gd")
const EntityFactories = preload("res://objects/entity_factories.gd")
const Tile = preload("res://objects/tile_types.gd")
const Room = preload("res://objects/procgen.gd").Room


const layer_explored = 0
const layer_visible = 1
const layer_entities = 2


const CHAR_TO_ATLAS = {
	" ": Vector2i(0, 0),
	"#": Vector2i(3, 0),
	".": Vector2i(14, 0),
	"@": Vector2i(0, 1),
	"~": Vector2i(10, 1),
	
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
var map_width: int
var map_height: int

func is_in_bounds(x: int, y: int) -> bool:
	return x > 0 and x < map_width and y > 0 and y < map_height
static func map_to_px(map_coords: Vector2i) -> Vector2:
	return map_coords * tile_size

var tile_map: Array[Tile]
func get_tile(x: int, y: int) -> Tile:
	return tile_map[x + y * map_width]
func set_tile(x: int, y: int, v: Tile):
	tile_map[x + y * map_width] = v
func is_walkable(x: int, y: int) -> bool:
	return tile_map[x + y * map_width].walkable
func is_transparent(x: int, y: int) -> bool:
	return tile_map[x + y * map_width].transparent

var explored_tiles: Array[bool]
func is_explored(x: int, y: int) -> bool:
	return explored_tiles[x + y * map_width]
func explore(x: int, y: int):
	explored_tiles[x + y * map_width] = true

var entities: Array[Entity]
var rooms: Array[Room]


func _init(width: int, height: int):
	map_width = width
	map_height = height
	# initialise arrays
	tile_map.resize(map_width * map_height)
	tile_map.fill(Tile.FOG)
	explored_tiles.resize(map_width * map_height)
	explored_tiles.fill(false)


func get_blocking_entity_at_location(location: Vector2i) -> Entity:
	var blockers = entities.filter(func(e: Entity): return e.blocks_movement and e.position == location)
	return blockers.front() if blockers.size() > 0 else null


## Draws the world tiles and entities onto the given TileMap
func draw_map(tilemap: TileMap, player: Entity):
	# clear the layers ready to draw
	tilemap.clear_layer(layer_explored)
	tilemap.clear_layer(layer_visible)
	tilemap.clear_layer(layer_entities)
	
	# shift tilemap so that player is in centre of the window
	tilemap.position = map_to_px(half_window_height - player.position)
	
	# FIRST DRAW THE WORLD #
	
	# fill in light visible tiles
	var visible_tiles = los.get_visible_points(player.position, Callable(self, "is_transparent"), 10)
	for t in visible_tiles:
		tilemap.set_cell(layer_visible, t, 0, CHAR_TO_ATLAS[get_tile(t.x, t.y).char])
		explore(t.x, t.y)
	
	# fill the explored map with fog or dark explored tiles
	for y in range(map_height):
		for x in range(map_width):
			if is_explored(x, y):
				tilemap.set_cell(layer_explored, Vector2i(x, y), 0, CHAR_TO_ATLAS[get_tile(x, y).char])
			else:
				tilemap.set_cell(layer_explored, Vector2i(x, y), 0, CHAR_TO_ATLAS[Tile.FOG.char])
	
	# THEN DRAW THE ENTITIES #
	
	# draw all entities visible to player
	for e in entities:
		if visible_tiles.any(func (v): return e.position == v):
			tilemap.set_cell(layer_entities, e.position, 0, CHAR_TO_ATLAS[e.char], 0)
	# draw the player
	tilemap.set_cell(layer_entities, player.position, 0, CHAR_TO_ATLAS[player.char], 0)
