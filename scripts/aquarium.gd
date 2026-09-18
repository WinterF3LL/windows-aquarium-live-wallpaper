extends Node2D

const FISH_SCRIPT := preload("res://scripts/fish.gd")
const PLANT_SCRIPT := preload("res://scripts/plant.gd")
const BUBBLE_SCRIPT := preload("res://scripts/bubble.gd")

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	get_window().borderless = true
	get_window().always_on_top = false
	_spawn_plants()
	_spawn_fish()
	_spawn_bubbles()
	queue_redraw()

func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0a5d78"))
	for i in range(12):
		var t := float(i) / 12.0
		var y := size.y * t
		var c := Color(0.02 + 0.02 * t, 0.32 + 0.13 * t, 0.45 + 0.10 * t, 1.0)
		draw_rect(Rect2(0, y, size.x, size.y / 12.0 + 2.0), c)
	for i in range(9):
		var x := size.x * (float(i) / 8.0)
		draw_circle(Vector2(x, size.y * 0.08), size.x * 0.08, Color(0.7, 0.95, 1.0, 0.025))
	var sand_y := size.y * 0.82
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, sand_y),
		Vector2(size.x * 0.18, sand_y - 26),
		Vector2(size.x * 0.37, sand_y + 14),
		Vector2(size.x * 0.58, sand_y - 20),
		Vector2(size.x * 0.78, sand_y + 8),
		Vector2(size.x, sand_y - 18),
		Vector2(size.x, size.y),
		Vector2(0, size.y)
	]), Color("#d8c693"))
	for rock in [
		[Vector2(size.x * 0.12, size.y * 0.84), 90.0],
		[Vector2(size.x * 0.32, size.y * 0.88), 70.0],
		[Vector2(size.x * 0.73, size.y * 0.85), 105.0],
		[Vector2(size.x * 0.89, size.y * 0.89), 65.0]
	]:
		draw_circle(rock[0], rock[1], Color("#263d43"))

func _spawn_fish() -> void:
	var size := get_viewport_rect().size
	for i in range(18):
		var fish := Node2D.new()
		fish.set_script(FISH_SCRIPT)
		fish.position = Vector2(rng.randf_range(-80.0, size.x + 80.0), rng.randf_range(size.y * 0.14, size.y * 0.76))
		fish.set("speed", rng.randf_range(45.0, 120.0))
		fish.set("scale_factor", rng.randf_range(0.55, 1.45))
		fish.set("phase", rng.randf_range(0.0, TAU))
		fish.set("direction", -1.0 if rng.randi() % 2 == 0 else 1.0)
		fish.set("body_color", [
			Color("#f5a623"), Color("#f05a4f"), Color("#5ec8e5"),
			Color("#f1d65c"), Color("#6bc4a5"), Color("#9f7aea")
		][rng.randi_range(0, 5)])
		add_child(fish)

func _spawn_plants() -> void:
	var size := get_viewport_rect().size
	for i in range(15):
		var plant := Node2D.new()
		plant.set_script(PLANT_SCRIPT)
		plant.position = Vector2(size.x * float(i) / 14.0 + rng.randf_range(-35.0, 35.0), size.y * rng.randf_range(0.82, 0.96))
		plant.set("height", rng.randf_range(150.0, 390.0))
		plant.set("phase", rng.randf_range(0.0, TAU))
		plant.set("width", rng.randf_range(10.0, 22.0))
		add_child(plant)

func _spawn_bubbles() -> void:
	var size := get_viewport_rect().size
	for i in range(32):
		var bubble := Node2D.new()
		bubble.set_script(BUBBLE_SCRIPT)
		bubble.position = Vector2(rng.randf_range(0.0, size.x), rng.randf_range(0.0, size.y))
		bubble.set("radius", rng.randf_range(2.0, 8.0))
		bubble.set("speed", rng.randf_range(18.0, 62.0))
		bubble.set("phase", rng.randf_range(0.0, TAU))
		add_child(bubble)
