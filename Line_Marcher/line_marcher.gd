extends Node2D

@export var _debug := false
@export var num_of_lines := 100
@export var line_constraints := Vector2(10, 100)
@export var angle_constraints := Vector2(0, 2 * PI)
@export var starting_angle := 0.0
@export var random_starting_angle := true

var point_list: PackedVector2Array = []
## Bounds of the viewport/camera, idk If ill use
var bounds := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	point_list.resize(num_of_lines)
	var bounds_rect: Rect2 = get_viewport_rect()
	bounds = bounds_rect.size
	point_list[0] = bounds_rect.get_center()
	
	# the angle starts as set by user unless set to be random then its a random angle between (0, 2PI)
	var curr_ang: float = starting_angle if !random_starting_angle else randf_range(0, 2 * PI)
	
	if _debug:
		print("[%d]: <%s, %s>, [%s == %s]"%[0, point_list[0].x, point_list[0].y, curr_ang, rad_to_deg(curr_ang)])
	
	for ii in range(num_of_lines - 1):
		point_list[ii + 1] = point_list[ii] + Vector2(
			sin(curr_ang) * randf_range(line_constraints.x, line_constraints.y), 
			cos(curr_ang) * randf_range(line_constraints.x, line_constraints.y)
		)
		
		if _debug:
			print("[%d]: <%s, %s>, [%s == %s]"%[ii + 1, point_list[ii + 1].x, point_list[ii + 1].y, curr_ang, rad_to_deg(curr_ang)])
		
		var angle_change := randf_range(angle_constraints.x, angle_constraints.y)
		# angle change can be positive or negative
		curr_ang += angle_change if randi() % 2 else -angle_change
	
	pass # Replace with function body.

func _draw() -> void:
	for ii in range(1, num_of_lines):
		draw_line(point_list[ii - 1], point_list[ii], Color.DARK_CYAN, 2.0)
	# IDK what ThemeDB.fallback_font is but I don't know other fonts in godot
	draw_char(ThemeDB.fallback_font, point_list[0], "S", 16, Color.GREEN)
	draw_char(ThemeDB.fallback_font, point_list[num_of_lines - 1], "E", 16, Color.RED)
	pass
