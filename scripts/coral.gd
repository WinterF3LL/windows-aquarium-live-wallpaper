extends Node2D

var size_factor := 1.0
var hue_shift := 0.0
var phase := 0.0
var time := 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var sway := sin(time * 0.45 + phase) * 2.5
	var base_color := Color.from_hsv(fposmod(0.98 + hue_shift, 1.0), 0.48, 0.82)
	var dark := base_color.darkened(0.18)

	for branch in range(6):
		var x := (branch - 2.5) * 13.0 * size_factor
		var h := (38.0 + float((branch * 17) % 34)) * size_factor
		var top := Vector2(x + sway * (0.35 + branch * 0.08), -h)
		draw_line(Vector2(x, 0), top, dark, 8.0 * size_factor, true)
		draw_circle(top, 7.0 * size_factor, base_color)
		if branch % 2 == 0:
			var arm := top + Vector2(-15.0 * size_factor, 12.0 * size_factor)
			draw_line(top + Vector2(0, 12.0 * size_factor), arm, dark, 6.0 * size_factor, true)
			draw_circle(arm, 5.5 * size_factor, base_color.lightened(0.08))

	draw_ellipse(Vector2(0, 3.0 * size_factor), Vector2(52.0, 13.0) * size_factor, dark.darkened(0.18))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(24):
		var a := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	draw_colored_polygon(points, color)
