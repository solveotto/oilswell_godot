extends Node



func fill_missing_segment(points: Array) -> Array:
	var filled_points = []
	
	for i in range(points.size() - 1):
		var start = points[i]
		var end = points[i + 1]
		filled_points.append(start)

		# If the next point is not continuous, interpolate the missing ones
		var x_diff = end[0] - start[0]
		var y_diff = end[1] - start[1]
		
		while abs(x_diff) > 1 or abs(y_diff) > 1:
			if x_diff != 0:
				start[0] += sign(x_diff)
			if y_diff != 0:
				start[1] += sign(y_diff)
			filled_points.append(start.duplicate())
			x_diff = end[0] - start[0]
			y_diff = end[1] - start[1]

	# Append the last point
	filled_points.append(points[-1])

	return filled_points

func _ready():
# Example usage:
	var points = [
		Vector2(25, 12), Vector2(25, 13), Vector2(26, 13), Vector2(27, 13), Vector2(28, 13),
		Vector2(29, 13), Vector2(30, 13), Vector2(31, 13), Vector2(32, 13), Vector2(33, 13),
		Vector2(34, 13), Vector2(35, 13), Vector2(36, 13), Vector2(36, 14), Vector2(36, 15),
		Vector2(36, 16), Vector2(35, 16), Vector2(34, 16), Vector2(33, 16), Vector2(32, 16),
		Vector2(31, 16), Vector2(30, 16), Vector2(28, 16), Vector2(27, 16), Vector2(26, 16),
		Vector2(25, 16)
	]

	var complete_points = fill_missing_segment(points)
	print(complete_points)
