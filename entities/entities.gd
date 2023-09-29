extends Resource


const Actor = preload("res://entities/actor.gd")
const Components = preload("res://entities/components.gd")
const HostileEnemy = Components.HostileEnemy
const Fighter = Components.Fighter


static var PLAYER = Actor.new(
	0, 0, "@",
	"Player",
	true,
	null,
	Fighter.new(30, 2, 5)
)

static var ORC = Actor.new(
	0, 0, "o",
	"Orc",
	true,
	HostileEnemy.new(null),
	Fighter.new(10, 0, 3)
)

static var TROLL = Actor.new(
	0, 0, "T",
	"Troll",
	true,
	HostileEnemy.new(null),
	Fighter.new(16, 1, 4)
)
