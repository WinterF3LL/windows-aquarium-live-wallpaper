extends Node2D

var speed := 80.0
var scale_factor := 1.0
var direction := 1.0
var phase := 0.0
var body_color := Color("#f5a623")
var time := 0.0

func _ready() -> void:
	scale = Vector2.ONE * scale_factor
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	var size := get_viewport_rect().size
	position.x += speed * direction * delta
	position.y += sin(time * 1.35 + phase) * 8.0 * delta
	if direction > 0.0 and position.x > size.x + 120.0:
		position.x = -120.0
	elif direction < 0.0 and position.x < -120.0:
		position.x = size.x + 120.0
	scale.x = abs(scale.x) * direction

func _draw() -> void:
	draw_ellipse(Vector2.ZERO, Vector2(44, 20), body_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-38, 0), Vector2(-62, -18), Vector2(-60, 18)
	]), body_color.darkened(0.12))
	draw_circle(Vector2(24, -4), 3.2, Color.WHITE)
	draw_circle(Vector2(25, -4), 1.6, Color.BLACK)
	draw_arc(Vector2(6, 1), 14, 0.2, 2.6, 18, body_color.lightened(0.25), 3.0)

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(32):
		var a := TAU * float(i) / 32.0
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	draw_colored_polygon(points, color)
