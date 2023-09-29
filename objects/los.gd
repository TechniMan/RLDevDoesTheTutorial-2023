extends Resource


"""
Functions related to line of sight calculations
Adapted from this Python implementation https://raw.githubusercontent.com/irskep/clubsandwich/afc79ed/clubsandwich/line_of_sight.py
adapted from this RogueBasin article http://www.roguebasin.com/index.php?title=Python_shadowcasting_implementation
"""


const MULT = [
  [1,  0,  0, -1, -1,  0,  0,  1],
  [0,  1, -1,  0,  0, -1,  1,  0],
  [0,  1,  1,  0,  0, -1, -1,  0],
  [1,  0,  0,  1, -1,  0,  0, -1],
]


# Returns a set of all points visible from the given vantage point.
static func get_visible_points(vantage_point: Vector2i, get_allows_light: Callable, max_distance: int) -> Array[Vector2i]:
	var los_cache: Array[Vector2i] = []
	los_cache.append(vantage_point)
	for region in range(8):
		_cast_light(
			los_cache,
			get_allows_light,
			vantage_point.x,
			vantage_point.y,
			1,
			1.0,
			0.0,
			max_distance,
			MULT[0][region],
			MULT[1][region],
			MULT[2][region],
			MULT[3][region]
		)
	return los_cache


# do not use; use get_visible_points
static func _cast_light(los_cache: Array[Vector2i], get_allows_light: Callable, cx, cy, row, start, end, radius, xx, xy, yx, yy):
	if start < end:
		return
	
	var radius_squared = radius * radius
	
	for j in range(row, radius+1):
		var dx = -j-1
		var dy = -j
		var blocked = false
		var new_start
		while dx <= 0:
			dx += 1
			# Translate the dx, dy coordinates into map coordinates:
			var X = cx + dx * xx + dy * xy
			var Y = cy + dx * yx + dy * yy
			var point = Vector2i(X, Y)
			# l_slope and r_slope store the slopes of the left and right
			# extremities of the square we're considering:
			var l_slope = (dx - 0.5) / (dy + 0.5)
			var r_slope = (dx + 0.5) / (dy - 0.5)
			if start < r_slope:
				continue
			elif end > l_slope:
				break
			else:
				# Our light beam is touching this square; light it:
				if (dx * dx) + (dy * dy) < radius_squared:
					los_cache.append(point)
				if blocked:
					# we're scanning a row of blocked squares:
					if not get_allows_light.call(point.x, point.y):
						new_start = r_slope
						continue
					else:
						blocked = false
						start = new_start
				else:
					if not get_allows_light.call(point.x, point.y) and j < radius:
						# This is a blocking square, start a child scan:
						blocked = true
						_cast_light(
							los_cache, get_allows_light,
							cx, cy, j + 1, start, l_slope,
							radius, xx, xy, yx, yy)
						new_start = r_slope
		# Row is scanned; do next row unless last square was blocked:
		if blocked:
			break
