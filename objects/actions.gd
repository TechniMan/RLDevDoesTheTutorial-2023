extends Object


const Entity = preload("res://objects/entity.gd")
const Map = preload("res://nodes/map.gd")


class Action:
	func perform(map: Map, entity: Entity):
		pass


class EscapeAction extends Action:
	pass


class ActionWithDirection extends Action:
	var dx: int
	var dy: int
	
	func _init(_dx: int, _dy: int):
		dx = _dx
		dy = _dy


class MoveAction extends ActionWithDirection:
	var is_zero: bool
	
	func _init(_dx: int, _dy: int):
		dx = _dx
		dy = _dy
		is_zero = _dx == 0 and _dy == 0
	
	func perform(map: Map, entity: Entity):
		var destination = entity.position + Vector2i(dx, dy)
		# ensure we can move this way
		if not map.is_in_bounds(destination.x, destination.y):
			return
		if not map.is_walkable(destination.x, destination.y):
			return
		if map.get_blocking_entity_at_location(destination) != null:
			return
		# move the entity
		entity.move(dx, dy)


class MeleeAction extends ActionWithDirection:
	func perform(map: Map, entity: Entity):
		var destination = entity.position + Vector2i(dx, dy)
		var target = map.get_blocking_entity_at_location(destination)
		if target == null:
			return
		
		print("You kick the " + target.name + ", much to its annoyance!")


class BumpAction extends ActionWithDirection:
	func perform(map: Map, entity: Entity):
		var destination = entity.position + Vector2i(dx, dy)
		
		if map.get_blocking_entity_at_location(destination):
			return MeleeAction.new(dx, dy).perform(map, entity)
		else:
			return MoveAction.new(dx, dy).perform(map, entity)
