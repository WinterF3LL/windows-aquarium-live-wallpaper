extends Node2D

var height := 260.0
var width := 16.0
var phase := 0.0
var time := 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var segments := 9
	var pts := PackedVector2Array()
	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var sway := sin(time * 0.85 + phase + t * 2.4) * (8.0 + 18.0 * t)
		pts.append(Vector2(sway, -height * t))
	for i in range(pts.size() - 1):
		var t := float(i) / float(segments)
		var c := Color("#2f8b5a").lerp(Color("#76b85d"), t)
		draw_line(pts[i], pts[i + 1], c, max(3.0, width * (1.0 - t * 0.65)), true)
		if i > 1 and i < segments:
			var p := pts[i]
			var side := -1.0 if i % 2 == 0 else 1.0
			draw_line(p, p + Vector2(24.0 * side, -18.0), c.lightened(0.05), max(2.0, width * 0.45), true)
