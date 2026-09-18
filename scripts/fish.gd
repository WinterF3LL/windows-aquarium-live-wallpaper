extends Node2D

var speed: float = 80.0
var scale_factor: float = 1.0
var direction: float = 1.0
var phase: float = 0.0
var body_color: Color = Color("#f5a623")
var species: int = 0
var depth_alpha: float = 1.0
var time: float = 0.0

func _ready() -> void:
	scale = Vector2.ONE * scale_factor
	modulate.a = depth_alpha
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	var viewport_size: Vector2 = get_viewport_rect().size
	position.x += speed * direction * delta
	position.y += sin(time * 1.35 + phase) * 8.0 * delta
	rotation = sin(time * 0.85 + phase) * 0.018

	if direction > 0.0 and position.x > viewport_size.x + 140.0:
		position.x = -140.0
	elif direction < 0.0 and position.x < -140.0:
		position.x = viewport_size.x + 140.0

	scale.x = absf(scale.x) * direction
	queue_redraw()

func _draw() -> void:
	var tail_wave: float = sin(time * 5.4 + phase) * 7.0
	var body_radius: Vector2 = Vector2(46.0, 21.0)

	if species == 2:
		body_radius = Vector2(38.0, 25.0)
	elif species == 3:
		body_radius = Vector2(54.0, 18.0)

	_draw_ellipse_shape(Vector2.ZERO, body_radius, body_color)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-38.0, 0.0),
		Vector2(-64.0, -20.0 + tail_wave),
		Vector2(-61.0, 20.0 + tail_wave)
	]), body_color.darkened(0.16))

	if species == 1:
		for stripe_x: float in [-14.0, 2.0, 18.0]:
			draw_line(
				Vector2(stripe_x, -17.0),
				Vector2(stripe_x + 3.0, 17.0),
				Color(0.08, 0.12, 0.16, 0.65),
				5.0,
				true
			)
	elif species == 2:
		_draw_ellipse_shape(Vector2(-6.0, 0.0), Vector2(13.0, 23.0), body_color.lightened(0.18))
		draw_line(Vector2(3.0, -20.0), Vector2(3.0, 20.0), Color(0.95, 0.95, 0.90, 0.7), 5.0, true)
	elif species == 3:
		draw_colored_polygon(PackedVector2Array([
			Vector2(-4.0, -16.0),
			Vector2(10.0, -35.0),
			Vector2(20.0, -15.0)
		]), body_color.lightened(0.12))

	draw_circle(Vector2(25.0, -5.0), 4.0, Color.WHITE)
	draw_circle(Vector2(26.0, -5.0), 1.8, Color("#172126"))
	draw_arc(Vector2(10.0, 1.0), 16.0, 0.2, 2.5, 18, body_color.lightened(0.3), 2.5)

func _draw_ellipse_shape(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i: int in range(32):
		var angle: float = TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
