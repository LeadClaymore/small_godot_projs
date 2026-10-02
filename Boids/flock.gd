extends Node2D

@export var count := 400
## neighbor detection radius
@export var perception := 60.0

@export_category("Movement params")
@export var min_speed := 80.0
@export var max_speed := 220.0
@export var max_force := 500.0
@export var separation_radius := 22.0
@export var separation_weight := 1.6
@export var alignment_weight := 1.0
@export var cohesion_weight := 0.9

@export_category("visual")
@export var boid_size := 6.0
@export var color := Color(0.4, 0.8, 1.0)

var bounds := Vector2.ZERO

# info for each boid
var pos := PackedVector2Array()
var vel := PackedVector2Array()
var acc := PackedVector2Array()

var grid := {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bounds = get_viewport_rect().size
	pos.resize(count)
	vel.resize(count)
	acc.resize(count)
	
	for ii in count:
		pos[ii] = Vector2(randf() * bounds.x, randf() * bounds.y)
		vel[ii] = Vector2.from_angle(randf() * 2 * PI) * randf_range(min_speed, max_speed)
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	_build_grid()
	for ii in count:
		var p := pos[ii]
		var cell := Vector2i(p / perception)
		var sep := Vector2.ZERO
		var ali := Vector2.ZERO
		var coh := Vector2.ZERO
		var n := 0
		
		# for each bucket [-1, 0, 1] in the x and y dir
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var bucket = grid.get(cell + Vector2i(dx, dy))
				
				if bucket == null:
					continue
				for jj in bucket:
					if jj == ii:
						continue
					var offset := p - pos[jj]
					var d2 := offset.length_squared()
					if d2 > perception * perception || d2 == 0.0:
						continue
					n += 1
					ali += vel[jj]
					coh += pos[jj]
					if d2 < separation_radius * separation_radius:
						sep += offset / d2
		
		var a := Vector2.ZERO
		if n > 0:
			a += _steer(vel[ii], ali / n) * alignment_weight
			a += _steer(vel[ii], (coh / n) - p) * cohesion_weight
			a += _steer(vel[ii], sep) * separation_weight
		acc[ii] = a.limit_length(max_force)
	for ii in count:
		var v := (vel[ii] + acc[ii] * delta).limit_length(max_speed)
		if v.length() < min_speed:
			v = v.normalized() * min_speed
		vel[ii] = v
		var p := pos[ii] + v * delta
		pos[ii] = Vector2(fposmod(p.x, bounds.x), fposmod(p.y, bounds.y))
	queue_redraw()

func _steer(curr: Vector2, desired: Vector2) -> Vector2:
	if desired == Vector2.ZERO:
		return Vector2.ZERO
	return (desired.normalized() * max_speed - curr).limit_length(max_force)

func _build_grid() -> void:
	grid.clear()
	for ii in count:
		var key := Vector2i(pos[ii] / perception)
		if grid.has(key):
			grid[key].append(ii)
		else:
			grid[key] = [ii]

func _draw() -> void:
	for ii in count:
		var d := vel[ii].normalized()
		var n := Vector2(-d.y, d.x)
		var p := pos[ii]
		draw_colored_polygon(PackedVector2Array
		([
			p + d * boid_size * 1.5,
			p - d * boid_size + n * boid_size * 0.6,
			p - d * boid_size - n * boid_size * 0.6
		]), 
		color)
