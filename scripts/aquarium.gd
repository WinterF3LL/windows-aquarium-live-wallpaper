extends Node2D

const FISH_SCRIPT := preload("res://scripts/fish.gd")
const PLANT_SCRIPT := preload("res://scripts/plant.gd")
const BUBBLE_SCRIPT := preload("res://scripts/bubble.gd")
const CORAL_SCRIPT := preload("res://scripts/coral.gd")
const WALLPAPER_SCRIPT := preload("res://scripts/windows_wallpaper.gd")

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
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
		wallpaper_host.call("attach_to_desktop")

	queue_redraw()

func _exit_tree() -> void:
	if wallpaper_host != null and wallpaper_host.has_method("detach_from_desktop"):
		wallpaper_host.call("detach_from_desktop")

func _draw() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color("#07516b"))

	for i: int in range(16):
		var t: float = float(i) / 16.0
		var y: float = viewport_size.y * t
		var water_color: Color = Color(
			0.025 + 0.015 * t,
			0.30 + 0.13 * t,
			0.43 + 0.11 * t,
			1.0
		)
		draw_rect(
			Rect2(0.0, y, viewport_size.x, viewport_size.y / 16.0 + 2.0),
			water_color
		)

	for i: int in range(10):
		var x: float = viewport_size.x * (float(i) / 9.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 42.0, 0.0),
			Vector2(x + 28.0, 0.0),
			Vector2(x + 120.0, viewport_size.y * 0.58),
			Vector2(x + 20.0, viewport_size.y * 0.58)
		]), Color(0.78, 0.96, 1.0, 0.018))

	for i: int in range(7):
		var haze_position: Vector2 = Vector2(
			viewport_size.x * (0.08 + float(i) * 0.15),
			viewport_size.y * (0.18 + float(i % 3) * 0.13)
		)
		draw_circle(
			haze_position,
			90.0 + float(i) * 9.0,
			Color(0.6, 0.92, 0.95, 0.018)
		)

	var sand_y: float = viewport_size.y * 0.82
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, sand_y),
		Vector2(viewport_size.x * 0.16, sand_y - 24.0),
		Vector2(viewport_size.x * 0.34, sand_y + 16.0),
		Vector2(viewport_size.x * 0.54, sand_y - 18.0),
		Vector2(viewport_size.x * 0.75, sand_y + 8.0),
		Vector2(viewport_size.x, sand_y - 14.0),
		Vector2(viewport_size.x, viewport_size.y),
		Vector2(0.0, viewport_size.y)
	]), Color("#d9ca9d"))

	for i: int in range(13):
		var ripple_y: float = sand_y + 30.0 + float(i) * 15.0
		draw_arc(
			Vector2(viewport_size.x * 0.5, ripple_y),
			viewport_size.x * (0.2 + float(i) * 0.018),
			PI + 0.15,
			TAU - 0.15,
			48,
			Color(0.37, 0.30, 0.19, 0.06),
			2.0
		)

	var rock_positions: Array[Vector2] = [
		Vector2(viewport_size.x * 0.09, viewport_size.y * 0.86),
		Vector2(viewport_size.x * 0.29, viewport_size.y * 0.90),
		Vector2(viewport_size.x * 0.68, viewport_size.y * 0.87),
		Vector2(viewport_size.x * 0.88, viewport_size.y * 0.90)
	]
	var rock_radii: PackedFloat32Array = PackedFloat32Array([94.0, 68.0, 112.0, 74.0])

	for i: int in range(rock_positions.size()):
		var rock_position: Vector2 = rock_positions[i]
		var rock_radius: float = rock_radii[i]
		draw_circle(rock_position, rock_radius, Color("#263d43"))
		draw_circle(
			rock_position + Vector2(-18.0, -22.0),
			rock_radius * 0.58,
			Color("#385159")
		)

func _spawn_fish() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var fish_colors: Array[Color] = [
		Color("#f5a623"),
		Color("#e95c4a"),
		Color("#4fc2df"),
		Color("#f1d65c"),
		Color("#55b98b"),
		Color("#8a72d8"),
		Color("#ef7d42"),
		Color("#3ea6b5")
	]

	for _i: int in range(22):
		var fish: Node2D = Node2D.new()
		fish.set_script(FISH_SCRIPT)

		var depth: float = rng.randf_range(0.0, 1.0)
		var fish_scale: float = lerpf(0.48, 1.42, depth)
		var fish_speed: float = lerpf(48.0, 112.0, depth) * rng.randf_range(0.86, 1.12)
		var fish_alpha: float = lerpf(0.52, 1.0, depth)
		var fish_direction: float = -1.0 if rng.randi() % 2 == 0 else 1.0
		var fish_species: int = rng.randi_range(0, 3)
		var color_index: int = rng.randi_range(0, fish_colors.size() - 1)

		fish.position = Vector2(
			rng.randf_range(-100.0, viewport_size.x + 100.0),
			rng.randf_range(viewport_size.y * 0.12, viewport_size.y * 0.72)
		)
		fish.set("speed", fish_speed)
		fish.set("scale_factor", fish_scale)
		fish.set("depth_alpha", fish_alpha)
		fish.set("phase", rng.randf_range(0.0, TAU))
		fish.set("direction", fish_direction)
		fish.set("species", fish_species)
		fish.set("body_color", fish_colors[color_index])
		fish.z_index = int(lerpf(-4.0, 4.0, depth))
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
	var viewport_size: Vector2 = get_viewport_rect().size
	var divisor: float = maxf(1.0, float(count - 1))

	for i: int in range(count):
		var plant: Node2D = Node2D.new()
		plant.set_script(PLANT_SCRIPT)
		plant.position = Vector2(
			viewport_size.x * float(i) / divisor + rng.randf_range(-50.0, 50.0),
			viewport_size.y * rng.randf_range(min_y, max_y)
		)
		plant.set("height", rng.randf_range(min_height, max_height))
		plant.set("phase", rng.randf_range(0.0, TAU))
		plant.set("width", rng.randf_range(10.0, 22.0) * width_scale)
		plant.z_index = layer
		plant.modulate.a = 0.74 if layer < 0 else 0.95
		add_child(plant)

func _spawn_corals() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var positions: PackedFloat32Array = PackedFloat32Array([0.19, 0.41, 0.61, 0.79, 0.94])

	for i: int in range(positions.size()):
		var coral: Node2D = Node2D.new()
		coral.set_script(CORAL_SCRIPT)
		coral.position = Vector2(
			viewport_size.x * positions[i],
			viewport_size.y * rng.randf_range(0.85, 0.93)
		)
		coral.set("size_factor", rng.randf_range(0.72, 1.28))
		coral.set("hue_shift", rng.randf_range(-0.08, 0.12))
		coral.set("phase", rng.randf_range(0.0, TAU))
		coral.z_index = rng.randi_range(1, 5)
		add_child(coral)

func _spawn_bubbles() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	for _i: int in range(40):
		var bubble: Node2D = Node2D.new()
		bubble.set_script(BUBBLE_SCRIPT)
		bubble.position = Vector2(
			rng.randf_range(0.0, viewport_size.x),
			rng.randf_range(0.0, viewport_size.y)
		)
		bubble.set("radius", rng.randf_range(2.0, 8.0))
		bubble.set("speed", rng.randf_range(18.0, 62.0))
		bubble.set("phase", rng.randf_range(0.0, TAU))
		bubble.z_index = rng.randi_range(-3, 5)
		add_child(bubble)
