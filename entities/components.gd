extends Resource
class_name Component

const Action = preload("res://objects/actions.gd")
const Entity = preload("res://entities/entity.gd")
const LOS = preload("res://objects/los.gd")
const Map = preload("res://dungeon/map.gd")


# BASE COMPONENT MEMBERS

var owner: Entity

func _init(_owner: Entity):
	owner = _owner

# END BASE COMPONENT MEMBERS


class Fighter extends Component:
	var _max_hp: int
	var _current_hp: int
	var defense: int
	var power: int
	
	func _init(_hp: int, _defense: int, _power: int):
		_max_hp = _hp
		_current_hp = _hp
		defense = _defense
		power = _power
	
	func get_hp() -> int:
		return _current_hp
	
	func set_hp(value: int):
		# clamp current_hp between 0 and max_hp
		_current_hp = maxi(0, mini(value, _max_hp))
	
	func take_damage(damage: int):
		_current_hp -= damage


class BaseAI extends Component:
	func perform(_target: Entity, _map: Map) -> void:
		pass
	
	## Compute and return path to destination.
	##
	## In case of no valid path, returns empty array.
	func get_path_to(destination: Vector2i, map: Map) -> Array[Vector2i]:
		return map.get_path_to(owner.position, destination)


class HostileEnemy extends BaseAI:
	var path: Array[Vector2i]
	
	func perform(target: Entity, map: Map):
		var dx = target.position.x - owner.position.x
		var dy = target.position.y - owner.position.y
		var distance = maxi(absi(dx), abs(dy)) # Chebyshev distance: diag equidistant to orthog
		
		# is owning entity visible to player
		if map.is_visible(owner.position.x, owner.position.y):
			# if in melee range
			if distance <= 1:
				return Action.MeleeAction.new(owner, map, dx, dy).perform()
			# else, calculate path to player
			path = get_path_to(target.position, map)
		
		if path:
			var destination = path[1]
			return Action.MoveAction.new(owner, map, destination.x - owner.position.x, destination.y - owner.position.y).perform()
		
		return Action.WaitAction.new(owner, map).perform()
