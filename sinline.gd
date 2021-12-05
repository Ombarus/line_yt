tool
extends Line2D

export var start := Vector2(0,0) setget set_start
export var length := 1920.0 setget set_length
export var a := 1.0 setget set_a
export var b := 1.0 setget set_b
export var c := 0.0 setget set_c
export var num_points := 100 setget set_num_points
export var curve : Curve
export var align : int = 0

func set_start(val : Vector2):
	start = val
	if Engine.editor_hint:
		Redraw()
	
func set_length(val : float):
	length = val
	if Engine.editor_hint:
		Redraw()
	
func set_a(val : float):
	a = val
	if Engine.editor_hint:
		Redraw()
	
func set_b(val : float):
	b = val
	if Engine.editor_hint:
		Redraw()
		
func set_c(val : float):
	c = val
	if Engine.editor_hint:
		Redraw()
		
func set_num_points(val : int):
	num_points = val
	if Engine.editor_hint:
		Redraw()
	
func _ready():
	Redraw()
	
func Redraw():
	self.clear_points()
	var step : float = length / float(num_points)
	var cur_x := 0.0
	for i in range(num_points):
		var mult = 1.0
		var offset_y = 0.0
		if curve != null:
			mult = curve.interpolate(cur_x / length)
		if align == 0:
			offset_y = mult * a
		elif align == 1:
			offset_y = -mult * a
		self.add_point(Vector2(start.x + cur_x, mult * a * sin(b * cur_x + c) + start.y - offset_y))
		cur_x += step
		
