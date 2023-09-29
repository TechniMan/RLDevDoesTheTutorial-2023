extends Resource
class_name Action


const Entity = preload("res://entities/entity.gd")
const Actor = preload("res://entities/actor.gd")
const Map = preload("res://dungeon/map.gd")


# ACTION BASE MEMBERS

var entity: Actor
var map: Map

func _init(_entity: Actor, _map: Map):
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
	var target_actor: Actor
	
	func _init(_entity: Actor, _map: Map, _dx: int, _dy: int):
		entity = _entity
		map = _map
		dx = _dx
		dy = _dy
		destination = entity.position + Vector2i(dx, dy)
		blocking_entity = map.get_blocking_entity_at_location(destination)
		target_actor = map.get_actor_at_location(destination)


class MoveAction extends ActionWithDirection:
	func perform():
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
		if target_actor == null:
			return
		
		var damage = entity.fighter.power - target_actor.fighter.defense

		var attack_description = "{self} attacks {target}".format({
			"self": entity.name,
			"target": target_actor.name
		})
		if damage > 0:
			print(attack_description + " for " + str(damage) + " hit points.")
			target_actor.fighter.take_damage(damage)
		else:
			print(attack_description + " but does no damage.")


class BumpAction extends ActionWithDirection:
	func perform():
		if target_actor:
			return MeleeAction.new(entity, map, dx, dy).perform()
		else:
			return MoveAction.new(entity, map, dx, dy).perform()
