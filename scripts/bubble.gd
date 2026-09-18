extends Node2D

var radius := 5.0
var speed := 35.0
var phase := 0.0
var time := 0.0

func _process(delta: float) -> void:
	time += delta
	position.y -= speed * delta
	position.x += sin(time * 1.4 + phase) * 5.0 * delta
	if position.y < -20.0:
		var size := get_viewport_rect().size
		position.y = size.y + 20.0
		position.x = fmod(position.x + 137.0, size.x)
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0.85, 0.97, 1.0, 0.16))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 20, Color(0.92, 1.0, 1.0, 0.45), 1.2)
