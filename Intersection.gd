tool
extends Node

export(Array, Resource) var Segments setget set_segments
export var CapOnly : bool = false
export var UpdateEditor : bool setget set_update_editor
func set_update_editor(val):
	DrawIntersections()

var _start_data

func _ready():
	DrawIntersections()

func set_segments(val : Array):
	var actual_array = []
	for v in val:
		if v == null:
			v = Segment.new()
		actual_array.append(v)
	Segments = actual_array
		

func DrawIntersections():
	Clear()
	var vertices := []
	# Create a list of unique vertices
	for s in Segments:
		if not s.p1 in vertices:
			vertices.append(s.p1)
		if not s.p2 in vertices:
			vertices.append(s.p2)
	
	# Start solving intersections for each vertices
	for vertex in vertices:
		var intersecting_segments := []
		
		# Find all segments that are part of the intersection
		for segment in Segments:
			if segment.p1 == vertex || segment.p2 == vertex:
				intersecting_segments.append(segment)
				
		if intersecting_segments.size() <= 1:
			continue
		
		# For simplicity later, make sure that the line's direction is always
		# towards the intersection by flipping p1 and p2 if needed
		for segment in intersecting_segments:
			if segment.p1 == vertex:
				var tmp = segment.p1
				segment.p1 = segment.p2
				segment.p2 = tmp
			segment.UpdateProperties()
			# handle existing ends
		
		var to_process = intersecting_segments.duplicate()
		var start_data = to_process[0]
		_start_data = start_data
		# Order the lines in clockwise from the first line
		to_process.remove(0)
		to_process.sort_custom(self, "sort_clockwise")
		to_process.insert(0, start_data)
		_start_data = null
		for i in range(to_process.size()):
			var prev : int = i - 1
			if prev < 0:
				prev = to_process.size()-1
			var next : int = (i + 1) % to_process.size()
			to_process[i].closest_left = to_process[prev]
			to_process[i].closest_right = to_process[next]
		
		for segment in to_process:
			# Intersect the left edge of the rectangle to the right edge of the next line
			var left_result = Geometry.line_intersects_line_2d(segment.p1_left, segment.dir, segment.closest_left.p1_right, segment.closest_left.dir)
			if left_result is Vector2:
				var offset_length : float = (segment.p2_left - left_result).length()
				var seg_length : float = (segment.p2_left - segment.p1_left).length()
				var left_length : float = (segment.closest_left.p2_right - segment.closest_left.p1_right).length()
				
				# If the lines are nearly parallel they might extend way too much and cause issue.
				# So only merge lines if the merge can happen in less than half the segment length
				if offset_length < 0.5 * seg_length and offset_length < 0.5 * left_length:
					segment.p2_left = left_result
					segment.closest_left.p2_right = left_result
			else:
				print("no collision?")
			
			# Do the same thing for the other side of the line
			var right_result = Geometry.line_intersects_line_2d(segment.p1_right, segment.dir, segment.closest_right.p1_left, segment.closest_right.dir)
			if right_result is Vector2:
				var offset_length : float = (segment.p2_right - right_result).length()
				var seg_length : float = (segment.p2_right - segment.p1_right).length()
				var right_length : float = (segment.closest_right.p2_left - segment.closest_right.p1_left).length()
				
				# If the lines are nearly parallel they might extend way too much and cause issue.
				# So only merge lines if the merge can happen in less than half the segment length
				if offset_length < 0.5 * seg_length and offset_length < 0.5 * right_length:
					segment.p2_right = right_result
					segment.closest_right.p2_left = right_result
			else:
				print("no collision?")
		
		# Render the result
		var current : Segment = to_process[0]
		var end : Segment = current
		var points := []
		while true:
			points.append(current.p2_left)
			if not CapOnly:
				points.append(current.p1_left)
				points.append(current.p1_right)
			if current.other_side != null:
				points.append(current.other_side.p2_right)
				points.append(current.other_side.p2_left)
			points.append(current.p2_right)
			current = current.closest_right
			if current == end:
				break
				
		var poly := Polygon2D.new()
		add_child(poly)
		poly.polygon = PoolVector2Array(points)
		poly.update()
		
func sort_clockwise(a, b):
	var angle_a : float = _start_data.dir.angle_to(a.dir)
	var  angle_b : float = _start_data.dir.angle_to(b.dir)
	var angle_a_pos : float = angle_a if angle_a >= 0.0 else angle_a + 2.0 * PI
	var angle_b_pos : float = angle_b if angle_b >= 0.0 else angle_b + 2.0 * PI
	return angle_b_pos < angle_a_pos

func Clear():
	for c in get_children():
		c.queue_free()
		c.visible = false
