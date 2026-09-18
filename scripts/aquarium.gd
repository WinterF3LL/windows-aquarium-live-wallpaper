extends Node2D

const FISH_SCRIPT := preload("res://scripts/fish.gd")
const PLANT_SCRIPT := preload("res://scripts/plant.gd")
const BUBBLE_SCRIPT := preload("res://scripts/bubble.gd")
const CORAL_SCRIPT := preload("res://scripts/coral.gd")
const WALLPAPER_SCRIPT := preload("res://scripts/windows_wallpaper.gd")

var rng := RandomNumberGenerator.new()
var wallpaper_host: Node

func _ready() -> void:
	rng.randomize()
	get_window().borderless = true
	get_window().always_on_top = false

	_spawn_back_plants()
	_spawn_corals()
	_spawn_fish()
	_spawn_front_plants()
	_spawn_bubbles()

	wallpaper_host = Node.new()
	wallpaper_host.set_script(WALLPAPER_SCRIPT)
	add_child(wallpaper_host)

	if OS.get_name() == "Windows":
		await get_tree().process_frame
		wallpaper_host.attach_to_desktop()

	queue_redraw()

func _exit_tree() -> void:
	if wallpaper_host != null and wallpaper_host.has_method("detach_from_desktop"):
		wallpaper_host.detach_from_desktop()

func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("#07516b"))

	for i in range(16):
		var t := float(i) / 16.0
		var y := size.y * t
		var c := Color(
			0.025 + 0.015 * t,
			0.30 + 0.13 * t,
			0.43 + 0.11 * t,
			1.0
		)
		draw_rect(Rect2(0, y, size.x, size.y / 16.0 + 2.0), c)

	# Soft surface-light shafts.
	for i in range(10):
		var x := size.x * (float(i) / 9.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 42, 0),
			Vector2(x + 28, 0),
			Vector2(x + 120, size.y * 0.58),
			Vector2(x + 20, size.y * 0.58)
		]), Color(0.78, 0.96, 1.0, 0.018))

	# Distant haze.
	for i in range(7):
		var p := Vector2(size.x * (0.08 + i * 0.15), size.y * (0.18 + (i % 3) * 0.13))
		draw_circle(p, 90.0 + i * 9.0, Color(0.6, 0.92, 0.95, 0.018))

	var sand_y := size.y * 0.82
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, sand_y),
		Vector2(size.x * 0.16, sand_y - 24),
		Vector2(size.x * 0.34, sand_y + 16),
		Vector2(size.x * 0.54, sand_y - 18),
		Vector2(size.x * 0.75, sand_y + 8),
		Vector2(size.x, sand_y - 14),
		Vector2(size.x, size.y),
		Vector2(0, size.y)
	]), Color("#d9ca9d"))

	# Sand ripples.
	for i in range(13):
		var y := sand_y + 30.0 + i * 15.0
		draw_arc(
			Vector2(size.x * 0.5, y),
			size.x * (0.2 + i * 0.018),
			PI + 0.15,
			TAU - 0.15,
			48,
			Color(0.37, 0.30, 0.19, 0.06),
			2.0
		)

	for rock in [
		[Vector2(size.x * 0.09, size.y * 0.86), 94.0],
		[Vector2(size.x * 0.29, size.y * 0.90), 68.0],
		[Vector2(size.x * 0.68, size.y * 0.87), 112.0],
		[Vector2(size.x * 0.88, size.y * 0.90), 74.0]
	]:
		draw_circle(rock[0], rock[1], Color("#263d43"))
		draw_circle(rock[0] + Vector2(-18, -22), rock[1] * 0.58, Color("#385159"))

func _spawn_fish() -> void:
	var size := get_viewport_rect().size
	for i in range(22):
		var fish := Node2D.new()
		fish.set_script(FISH_SCRIPT)

		var depth := rng.randf_range(0.0, 1.0)
		var fish_scale := lerp(0.48, 1.42, depth)

		fish.position = Vector2(
			rng.randf_range(-100.0, size.x + 100.0),
			rng.randf_range(size.y * 0.12, size.y * 0.72)
		)
		fish.set("speed", lerp(48.0, 112.0, depth) * rng.randf_range(0.86, 1.12))
		fish.set("scale_factor", fish_scale)
		fish.set("depth_alpha", lerp(0.52, 1.0, depth))
		fish.set("phase", rng.randf_range(0.0, TAU))
		fish.set("direction", -1.0 if rng.randi() % 2 == 0 else 1.0)
		fish.set("species", rng.randi_range(0, 3))
		fish.set("body_color", [
			Color("#f5a623"),
			Color("#e95c4a"),
			Color("#4fc2df"),
			Color("#f1d65c"),
			Color("#55b98b"),
			Color("#8a72d8"),
			Color("#ef7d42"),
			Color("#3ea6b5")
		][rng.randi_range(0, 7)])
		fish.z_index = int(lerp(-4.0, 4.0, depth))
		add_child(fish)

func _spawn_back_plants() -> void:
	_spawn_plant_layer(13, 0.78, 0.94, 120.0, 300.0, -6, 0.72)

func _spawn_front_plants() -> void:
	_spawn_plant_layer(10, 0.84, 0.97, 220.0, 455.0, 6, 1.05)

func _spawn_plant_layer(
	count: int,
	min_y: float,
	max_y: float,
	min_height: float,
	max_height: float,
	layer: int,
	width_scale: float
) -> void:
	var size := get_viewport_rect().size
	for i in range(count):
		var plant := Node2D.new()
		plant.set_script(PLANT_SCRIPT)
		plant.position = Vector2(
			size.x * float(i) / max(1.0, float(count - 1)) + rng.randf_range(-50.0, 50.0),
			size.y * rng.randf_range(min_y, max_y)
		)
		plant.set("height", rng.randf_range(min_height, max_height))
		plant.set("phase", rng.randf_range(0.0, TAU))
		plant.set("width", rng.randf_range(10.0, 22.0) * width_scale)
		plant.z_index = layer
		plant.modulate.a = 0.74 if layer < 0 else 0.95
		add_child(plant)

func _spawn_corals() -> void:
	var size := get_viewport_rect().size
	var positions := [0.19, 0.41, 0.61, 0.79, 0.94]
	for i in range(positions.size()):
		var coral := Node2D.new()
		coral.set_script(CORAL_SCRIPT)
		coral.position = Vector2(size.x * positions[i], size.y * rng.randf_range(0.85, 0.93))
		coral.set("size_factor", rng.randf_range(0.72, 1.28))
		coral.set("hue_shift", rng.randf_range(-0.08, 0.12))
		coral.set("phase", rng.randf_range(0.0, TAU))
		coral.z_index = rng.randi_range(1, 5)
		add_child(coral)

func _spawn_bubbles() -> void:
	var size := get_viewport_rect().size
	for i in range(40):
		var bubble := Node2D.new()
		bubble.set_script(BUBBLE_SCRIPT)
		bubble.position = Vector2(rng.randf_range(0.0, size.x), rng.randf_range(0.0, size.y))
		bubble.set("radius", rng.randf_range(2.0, 8.0))
		bubble.set("speed", rng.randf_range(18.0, 62.0))
		bubble.set("phase", rng.randf_range(0.0, TAU))
		bubble.z_index = rng.randi_range(-3, 5)
		add_child(bubble)
