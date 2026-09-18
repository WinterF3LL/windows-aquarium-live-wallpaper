extends SceneTree

const STEP := 1.0 / 60.0
const SIMULATED_SECONDS := 300.0

func _initialize() -> void:
	var packed_scene: PackedScene = load("res://scenes/aquarium.tscn")
	var scene: Node = packed_scene.instantiate()
	root.add_child(scene)
	await process_frame
	scene.process_mode = Node.PROCESS_MODE_DISABLED

	var maximum_speed := 0.0
	var minimum_clearance := INF
	var maximum_edge_coverage := 0.0
	var steps := int(SIMULATED_SECONDS / STEP)
	var fish_list: Array = scene.get("fish_list")
	for _step in range(steps):
		for fish: Node3D in fish_list:
			fish.call("_process", STEP)
			var velocity: Vector3 = fish.get("velocity")
			var floor_limit: float = fish.get("floor_limit")
			maximum_speed = maxf(maximum_speed, velocity.length())
			minimum_clearance = minf(minimum_clearance, fish.position.y - floor_limit)
			var camera: Camera3D = scene.get("camera")
			var camera_to_fish: Vector3 = fish.global_position-camera.global_position
			var camera_depth := maxf(0.1, camera_to_fish.dot(-camera.global_basis.z))
			var aspect := root.get_visible_rect().size.aspect()
			var visible_width := camera_depth*tan(deg_to_rad(camera.fov)*0.5)*aspect
			var fish_limit := maxf(2.0, visible_width-fish.get("half_length")-0.12)
			maximum_edge_coverage = maxf(maximum_edge_coverage, absf(fish.position.x)/fish_limit)

	print("fish_stability max_speed=%.3f min_clearance=%.3f edge_coverage=%.3f" % [maximum_speed, minimum_clearance, maximum_edge_coverage])
	if maximum_speed > 0.721 or minimum_clearance < -0.001 or maximum_edge_coverage < 0.90:
		quit(1)
	else:
		quit(0)
