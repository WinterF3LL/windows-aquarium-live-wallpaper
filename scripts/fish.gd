extends Node2D

var speed := 80.0
var scale_factor := 1.0
var direction := 1.0
var phase := 0.0
var body_color := Color("#f5a623")
var species := 0
var depth_alpha := 1.0
var time := 0.0

func _ready() -> void:
	scale = Vector2.ONE * scale_factor
	modulate.a = depth_alpha
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	var size := get_viewport_rect().size
	position.x += speed * direction * delta
	position.y += sin(time * 1.35 + phase) * 8.0 * delta
	rotation = sin(time * 0.85 + phase) * 0.018
	if direction > 0.0 and position.x > size.x + 140.0:
		position.x = -140.0
	elif direction < 0.0 and position.x < -140.0:
		position.x = size.x + 140.0
	scale.x = abs(scale.x) * direction
	queue_redraw()

func _draw() -> void:
	var tail_wave := sin(time * 5.4 + phase) * 7.0
	var body_radius := Vector2(46, 21)
	if species == 2:
		body_radius = Vector2(38, 25)
	elif species == 3:
		body_radius = Vector2(54, 18)

	draw_ellipse(Vector2.ZERO, body_radius, body_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-38, 0),
		Vector2(-64, -20 + tail_wave),
		Vector2(-61, 20 + tail_wave)
	]), body_color.darkened(0.16))

	if species == 1:
		for x in [-14.0, 2.0, 18.0]:
			draw_line(Vector2(x, -17), Vector2(x + 3, 17), Color(0.08, 0.12, 0.16, 0.65), 5.0, true)
	elif species == 2:
		draw_ellipse(Vector2(-6, 0), Vector2(13, 23), body_color.lightened(0.18))
		draw_line(Vector2(3, -20), Vector2(3, 20), Color(0.95, 0.95, 0.90, 0.7), 5.0, true)
	elif species == 3:
		draw_colored_polygon(PackedVector2Array([
			Vector2(-4, -16), Vector2(10, -35), Vector2(20, -15)
		]), body_color.lightened(0.12))

	draw_circle(Vector2(25, -5), 4.0, Color.WHITE)
	draw_circle(Vector2(26, -5), 1.8, Color("#172126"))
	draw_arc(Vector2(10, 1), 16, 0.2, 2.5, 18, body_color.lightened(0.3), 2.5)

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(32):
		var a := TAU * float(i) / 32.0
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	draw_colored_polygon(points, color)
