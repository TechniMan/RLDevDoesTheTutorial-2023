extends Resource

const Tile = preload("res://dungeon/tile.gd")


static var FLOOR = Tile.new(true, true, " ")
static var WALL = Tile.new(false, false, "#")
static var FOG = Tile.new(true, false, "~")
