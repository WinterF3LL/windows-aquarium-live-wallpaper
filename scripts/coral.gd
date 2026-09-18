extends Node2D

var size_factor: float = 1.0
var hue_shift: float = 0.0
var phase: float = 0.0
var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var sway: float = sin(time * 0.45 + phase) * 2.5
	var base_color: Color = Color.from_hsv(fposmod(0.98 + hue_shift, 1.0), 0.48, 0.82)
	var dark: Color = base_color.darkened(0.18)

	for branch: int in range(6):
		var branch_x: float = (float(branch) - 2.5) * 13.0 * size_factor
		var branch_height: float = (38.0 + float((branch * 17) % 34)) * size_factor
		var top: Vector2 = Vector2(
			branch_x + sway * (0.35 + float(branch) * 0.08),
			-branch_height
		)

		draw_line(Vector2(branch_x, 0.0), top, dark, 8.0 * size_factor, true)
		draw_circle(top, 7.0 * size_factor, base_color)

		if branch % 2 == 0:
			var arm: Vector2 = top + Vector2(-15.0 * size_factor, 12.0 * size_factor)
			draw_line(top + Vector2(0.0, 12.0 * size_factor), arm, dark, 6.0 * size_factor, true)
			draw_circle(arm, 5.5 * size_factor, base_color.lightened(0.08))

	_draw_ellipse_shape(
		Vector2(0.0, 3.0 * size_factor),
		Vector2(52.0, 13.0) * size_factor,
		dark.darkened(0.18)
	)

func _draw_ellipse_shape(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i: int in range(24):
		var angle: float = TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
