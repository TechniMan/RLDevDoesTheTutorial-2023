extends Object

const Entity = preload("res://objects/entity.gd")

static var player = Entity.new(
	0, 0, "@",
	"Player",
	true
)

static var orc = Entity.new(
	0, 0, "o",
	"Orc",
	true
)

static var troll = Entity.new(
	0, 0, "T",
	"Troll",
	true
)
