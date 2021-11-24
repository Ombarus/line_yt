tool
extends Resource
class_name Segment

export var p1 := Vector2.ZERO
export var p2 := Vector2.ONE
export var thickness := 1.0
export var debug_name : String

var dir : Vector2
var perp_dir : Vector2
var p1_left : Vector2
var p2_left : Vector2
var p1_right : Vector2
var p2_right : Vector2
var closest_left : Segment
var closest_right : Segment
var other_side : Segment

func UpdateProperties():
	dir = (p2 - p1).normalized()
	perp_dir = Vector2(-dir.y, dir.x).normalized()
	p1_left = p1 + (perp_dir * thickness / -2.0)
	p2_left = p2 + (perp_dir * thickness / -2.0)
	p1_right = p1 + (perp_dir * thickness / 2.0)
	p2_right = p2 + (perp_dir * thickness / 2.0)
	
	
	
