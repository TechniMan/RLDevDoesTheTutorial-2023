extends Resource
class_name Action


const Entity = preload("res://entities/entity.gd")
const Map = preload("res://dungeon/map.gd")


# ACTION BASE MEMBERS

var entity: Entity
var map: Map

func _init(_entity: Entity, _map: Map):
	entity = _entity
	map = _map

func perform():
	pass

# END ACTION BASE MEMBERS


class EscapeAction extends Action:
	pass


class WaitAction extends Action:
	func perform():
		pass


class ActionWithDirection extends Action:
	var dx: int
	var dy: int
	var destination: Vector2i
	var blocking_entity: Entity
	
	func _init(_entity: Entity, _map: Map, _dx: int, _dy: int):
		entity = _entity
		map = _map
		dx = _dx
		dy = _dy
		destination = entity.position + Vector2i(dx, dy)
		blocking_entity = map.get_blocking_entity_at_location(destination)


class MoveAction extends ActionWithDirection:
	func perform():
		var is_zero = dx == 0 and dy == 0
		# ensure we can move this way and are not blocked
		if not map.is_in_bounds(destination.x, destination.y):
			return
		if not map.is_walkable(destination.x, destination.y):
			return
		if blocking_entity != null:
			return
		# move the entity
		entity.move(dx, dy)


class MeleeAction extends ActionWithDirection:
	func perform():
		var destination = entity.position + Vector2i(dx, dy)
		if blocking_entity == null:
			return
		
		print("You kick the " + blocking_entity.name + ", much to its annoyance!")


class BumpAction extends ActionWithDirection:
	func perform():
		if blocking_entity:
			return MeleeAction.new(entity, map, dx, dy).perform()
		else:
			return MoveAction.new(entity, map, dx, dy).perform()
