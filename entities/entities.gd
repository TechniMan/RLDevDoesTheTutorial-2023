extends Resource


const Actor = preload("res://entities/actor.gd")
const Components = preload("res://entities/components.gd")
const HostileEnemy = Components.HostileEnemy
const Fighter = Components.Fighter


static func SpawnPlayer() -> Actor:
	return Actor.new(
		0, 0, "@",
		Color.WHITE,
		"Player",
		true,
		null,
		Fighter.new(30, 2, 5)
	)

static func SpawnOrc(x: int, y: int) -> Actor:
	return Actor.new(
		x, y, "o",
		Color.OLIVE,
		"Orc",
		true,
		HostileEnemy.new(null),
		Fighter.new(10, 0, 3)
	)

static func SpawnTroll(x: int, y: int) -> Actor:
	return Actor.new(
		x, y, "T",
		Color.DARK_OLIVE_GREEN,
		"Troll",
		true,
		HostileEnemy.new(null),
		Fighter.new(16, 1, 4)
	)
