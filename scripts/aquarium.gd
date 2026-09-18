extends Node3D

const WALLPAPER_SCRIPT = preload("res://scripts/windows_wallpaper.gd")
const FISH_SCRIPT = preload("res://scripts/fish_3d.gd")
const SURFACE = preload("res://shaders/surface.gdshader")
const ATLAS = preload("res://assets/aquarium-materials.png")
var rng = RandomNumberGenerator.new()
var wallpaper_host: Node
var camera: Camera3D
var fish_list: Array[Node3D] = []
var particles: Array[Node3D] = []
var cursor_world = Vector3.ZERO
var cursor_direction = Vector3.FORWARD
var cursor_active = false
var cursor_speed = 0.0
var last_mouse = Vector2.ZERO
var wallpaper_mode = false
var stop_check_elapsed = 0.0
var is_throttled = false
var elapsed = 0.0
var paused = false

func _ready() -> void:
 rng.seed = 682713
 get_window().always_on_top = false
 RenderingServer.set_default_clear_color(Color("086697"))
 _environment()
 _landscape()
 # The photographic reef supplies the distant coral colonies.
 _vegetation()
 _fish()
 _particles()
 wallpaper_host = Node.new()
 wallpaper_host.set_script(WALLPAPER_SCRIPT)
 add_child(wallpaper_host)
 wallpaper_mode = OS.get_cmdline_user_args().has("--wallpaper")
 if wallpaper_mode:
  # Reparent only after the aquarium has replaced Godot's startup splash and
  # completed a real draw. Attaching earlier can freeze the splash in WorkerW.
  await RenderingServer.frame_post_draw
  await get_tree().create_timer(0.35).timeout
  wallpaper_host.call("attach_to_desktop")

func _exit_tree() -> void:
 if wallpaper_host != null and wallpaper_host.has_method("detach_from_desktop"):
  wallpaper_host.call("detach_from_desktop")

func material(tile: Vector2, tint: Color, repeats: float = 1.0, sway: float = 0.0) -> ShaderMaterial:
 var m = ShaderMaterial.new()
 m.shader = SURFACE
 m.set_shader_parameter("atlas", ATLAS)
 m.set_shader_parameter("leaf_texture",preload("res://assets/upstream/plants/vallisneria.jpg"))
 m.set_shader_parameter("tile", tile)
 m.set_shader_parameter("tint", tint)
 m.set_shader_parameter("repeats", repeats)
 m.set_shader_parameter("sway", sway)
 m.set_shader_parameter("phase", rng.randf()*TAU)
 return m

func _environment() -> void:
 camera = Camera3D.new()
 camera.position = Vector3(0,5.8,21.5)
 add_child(camera)
 camera.look_at(Vector3(0,4.8,0))
 camera.fov = 48
 camera.near = 0.1
 camera.far = 100
 var env = Environment.new()
 env.background_mode = Environment.BG_COLOR
 env.background_color = Color("063876")
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color("d0e0da")
 env.ambient_light_energy = 1.0
 env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
 env.fog_enabled = true
 env.fog_light_color = Color("07528a")
 env.fog_light_energy = 0.8
 env.fog_density = 0.005
 var world = WorldEnvironment.new()
 world.environment = env
 add_child(world)
 var backdrop = MeshInstance3D.new()
 var backdrop_mesh = QuadMesh.new()
 backdrop_mesh.size = Vector2(88,44)
 backdrop.mesh = backdrop_mesh
 backdrop.position = Vector3(0,10,-25)
 var water_material = ShaderMaterial.new()
 water_material.shader = preload("res://shaders/reef_backdrop.gdshader")
 water_material.set_shader_parameter("reef",preload("res://assets/upstream/backdrop/reef.jpg"))
 backdrop.material_override = water_material
 backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(backdrop)
 var sun = DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-62,-28,0)
 sun.light_color = Color("e3eee9")
 sun.light_energy = 0.82
 sun.shadow_enabled = true
 sun.directional_shadow_max_distance = 45
 add_child(sun)
 var fill = OmniLight3D.new()
 fill.position = Vector3(-7,8,8)
 fill.light_color = Color("a7c7df")
 fill.light_energy = 0.38
 fill.omni_range = 22
 add_child(fill)
 for i in range(9):
  var ray = MeshInstance3D.new()
  var plane = QuadMesh.new()
  plane.size = Vector2(rng.randf_range(0.7,1.8),14)
  ray.mesh = plane
  var m = ShaderMaterial.new()
  m.shader = preload("res://shaders/ray.gdshader")
  m.set_shader_parameter("phase",float(i))
  ray.material_override = m
  ray.position = Vector3(-12+i*3.1,8,-5)
  ray.rotation.z = -0.17
  ray.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  add_child(ray)

func _landscape() -> void:
 var floor_mesh = PlaneMesh.new()
 floor_mesh.size = Vector2(70,65)
 floor_mesh.subdivide_width = 50
 floor_mesh.subdivide_depth = 50
 var sand = MeshInstance3D.new()
 sand.mesh = floor_mesh
 sand.position = Vector3(0,-0.12,-8)
 sand.material_override = material(Vector2.ZERO,Color(0.94,0.91,0.83),18)
 add_child(sand)
 # Layered boulders frame an open sandy swimming corridor.
 for side in [-1,1]:
  for i in range(11):
   var x = side * rng.randf_range(8.2,13.8)
   var z = rng.randf_range(-5,4)
   var s = Vector3(rng.randf_range(1.3,2.8),rng.randf_range(1.4,2.8),rng.randf_range(1.0,2.0))
   _rock(Vector3(x,s.y*0.48,z),s,Color("b3a494"))
 for i in range(28):
  var s = rng.randf_range(0.22,0.82)
  _rock(Vector3(rng.randf_range(-11,11),s*0.3,rng.randf_range(-4,7)),Vector3(s*1.6,s,s),Color("95978a"))
 for arrangement in [Vector3(-6.8,0.45,7.6),Vector3(-3.6,0.34,7.9),Vector3(5.1,0.34,7.7),Vector3(8.2,0.65,6.8)]:
  _rock(arrangement,Vector3(1.15,0.64,0.8),Color("958878"))
 # Distant reef terraces disappear into blue water.
 for i in range(6):
  var x = rng.randf_range(-20,20)
  var h = rng.randf_range(1.5,4.5)
  _rock(Vector3(x,h*0.25,-12-rng.randf()*6),Vector3(rng.randf_range(2,4),h,2.5),Color("497d72"))

func _rock(pos: Vector3, dimensions: Vector3, tint: Color) -> void:
 var st = SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 st.set_smooth_group(0)
 var rings = 24
 var sides = 32
 var seed_value = rng.randf()*100
 for j in range(rings):
  for k in range(sides):
   for corner in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
    var u = float(k+corner.x)/sides
    var v = float(j+corner.y)/rings
    var a = u*TAU
    var b = v*PI
    var n = Vector3(cos(a)*sin(b),cos(b),sin(a)*sin(b))
    var rough = 1.0+0.055*sin(a*5+seed_value)*sin(b*7)+0.025*cos(a*9+b*6)
    st.set_uv(Vector2(u,v))
    st.set_normal(n)
    st.add_vertex(n*rough)
 var rock = MeshInstance3D.new()
 rock.mesh = st.commit()
 rock.position = pos
 rock.scale = dimensions
 rock.rotation.y = rng.randf()*TAU
 rock.material_override = rock_material(tint)
 add_child(rock)

func _vegetation() -> void:
 # Long ribbon leaves, with real curved surfaces and independently phased current.
 for cluster in range(11):
  var x = rng.randf_range(-13,13)
  var z = rng.randf_range(-8,-4)
  if cluster < 7:
   x = [-5.6,-4.4,3.8,5.2,7.0,-12.5,12.8][cluster]
   z = rng.randf_range(0.8,3.2)
  for blade in range(rng.randi_range(6,10)):
   var h = rng.randf_range(4.0,11.8)
   var w = rng.randf_range(0.24,0.64)
   var lean = rng.randf_range(-2.2,2.2)
   var st = SurfaceTool.new()
   st.begin(Mesh.PRIMITIVE_TRIANGLES)
   for j in range(15):
    for corner in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
     var t = (float(j)+corner.y)/15.0
     var breadth = w * (0.45+sin(t*PI)*0.7) * (1.0-pow(t,8))
     st.set_uv(Vector2(corner.x,t))
     st.add_vertex(Vector3(lean*t*t+sin(t*3.5)*lean*0.25+(corner.x-0.5)*breadth,h*t,sin(t*3.8+lean)*0.42*t+absf(corner.x-0.5)*0.14))
   st.generate_normals()
   var leaf = MeshInstance3D.new()
   leaf.mesh = st.commit()
   leaf.position = Vector3(x+rng.randf_range(-0.6,0.6),0,z+rng.randf_range(-0.5,0.5))
   leaf.rotation.y = rng.randf_range(-1.0,1.0)
   leaf.material_override = material(Vector2(0,0.5),Color(rng.randf_range(0.78,1.12),rng.randf_range(0.86,1.08),rng.randf_range(0.8,1.12)),1,0.24)
   add_child(leaf)
 # Branching wine-red sea fans tucked among the stones.
 for p in [Vector3(-11,0,5),Vector3(-6.7,0,5.6),Vector3(10,0,4.8),Vector3(8.8,1.2,-1)]:
  _branch(p,Vector3(0.18,1.3,0.05),0.19,4)
 _rock(Vector3(2.4,0.1,5.4),Vector3(1.3,0.20,0.85),Color("bab3a3"))
 for p in [Vector3(-2.1,0.25,5.8),Vector3(6.1,0.28,4.7),Vector3(0.4,0.22,7.0)]:
  _rock(p,Vector3(0.60,0.50,0.50),Color("7ec8bd"))
 # Pale anemone in the central foreground.
 for i in range(85):
  var a = rng.randf()*TAU
  var r = rng.randf_range(0.05,1.05)
  var base = Vector3(2.4+cos(a)*r,0.10,5.4+sin(a)*r*0.55)
  _branch(base,Vector3(cos(a)*0.45,rng.randf_range(0.85,1.8),sin(a)*0.3),0.043,0,Color("ded8c9"))

func _branch(base: Vector3, offset: Vector3, radius: float, depth: int, color: Color = Color("933b63")) -> void:
 var mesh = CylinderMesh.new()
 mesh.top_radius = radius*0.57
 mesh.bottom_radius = radius
 mesh.height = offset.length()
 mesh.radial_segments = 10
 var obj = MeshInstance3D.new()
 obj.mesh = mesh
 obj.position = base+offset*0.5
 obj.material_override = material(Vector2(0.5,0),color.lightened(0.34),1)
 add_child(obj)
 if absf(offset.normalized().dot(Vector3.FORWARD)) < 0.99:
  obj.look_at(obj.position+offset,Vector3.FORWARD)
  obj.rotate_object_local(Vector3.RIGHT,PI/2)
 if depth > 0:
  for side in [-1,1]:
   _branch(base+offset*rng.randf_range(0.58,0.9),Vector3(side*rng.randf_range(0.22,0.66),offset.y*rng.randf_range(0.65,0.91),rng.randf_range(-0.28,0.28)),radius*0.68,depth-1,color)

func _fish() -> void:
 for i in range(14):
  var fish = Node3D.new()
  fish.set_script(FISH_SCRIPT)
  fish.set("species", [0,1,2,0,1,3,0,2,1,4,0,1,3,2][i])
  fish.set("phase",rng.randf()*TAU)
  fish.set("aquarium",self)
  fish.position = Vector3(-10.0+float(i%5)*4.6+rng.randf_range(-0.5,0.5),[2.0,5.8,7.4,3.4,6.3,8.1,4.8,2.7,7.0,5.0,1.8,8.4,3.8,6.0][i],[-1.0,4.6,1.5,5.3,-4.0,2.5,4.0,-2.0,1.0,3.8,5.5,-4.0,2.5,0.0][i])
  var size = rng.randf_range(0.72,1.12)
  fish.scale = Vector3.ONE*size
  add_child(fish)
  fish_list.append(fish)

func _particles() -> void:
 var sphere = SphereMesh.new()
 sphere.radius = 0.025
 sphere.height = 0.05
 sphere.radial_segments = 6
 sphere.rings = 3
 var mat = StandardMaterial3D.new()
 mat.albedo_color = Color(0.6,0.87,0.89,0.30)
 mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 for i in range(95):
  var particle = MeshInstance3D.new()
  particle.mesh = sphere
  particle.material_override = mat
  particle.position = Vector3(rng.randf_range(-15,15),rng.randf_range(0,12),rng.randf_range(-8,7))
  particle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  add_child(particle)
  particles.append(particle)

func _process(delta: float) -> void:
 elapsed += delta
 if wallpaper_mode:
  stop_check_elapsed += delta
  if stop_check_elapsed>=0.25:
   stop_check_elapsed = 0.0
   if FileAccess.file_exists(ProjectSettings.globalize_path("res://.wallpaper-stop")):
    get_tree().quit()
    return
   var covered := FileAccess.file_exists(ProjectSettings.globalize_path("res://.wallpaper-covered"))
   if covered != is_throttled:
    is_throttled = covered
    Engine.max_fps = 2 if covered else 30
    print("Aquarium throttled to 2 FPS while covered." if covered else "Aquarium resumed at 30 FPS.")
 var mouse = get_viewport().get_mouse_position()
 var screen_size = get_viewport().get_visible_rect().size
 # Global cursor polling also works when the wallpaper window is behind desktop icons.
 if wallpaper_host != null and wallpaper_host.get("attached"):
  mouse = Vector2(DisplayServer.mouse_get_position()-DisplayServer.window_get_position())
  mouse *= screen_size/Vector2(DisplayServer.window_get_size())
 cursor_active = Rect2(Vector2.ZERO,screen_size).has_point(mouse)
 var instantaneous_speed = mouse.distance_to(last_mouse)/maxf(delta,0.001)
 instantaneous_speed *= 1280.0 / maxf(screen_size.x,1.0)
 cursor_speed = lerpf(cursor_speed,instantaneous_speed,1.0-exp(-delta*12))
 last_mouse = mouse
 var origin = camera.project_ray_origin(mouse)
 var direction = camera.project_ray_normal(mouse)
 cursor_direction = direction
 if absf(direction.z)>0.001:
  cursor_world = origin+direction*(-origin.z/direction.z)
 for i in range(particles.size()):
  var p = particles[i]
  p.position.y += delta*(0.04+float(i%5)*0.018)
  p.position.x += sin(elapsed*0.4+float(i))*delta*0.018
  if p.position.y>12:
   p.position.y=0

func rock_material(tint: Color) -> ShaderMaterial:
 var mat = ShaderMaterial.new()
 mat.shader = preload("res://shaders/rock.gdshader")
 mat.set_shader_parameter("rock_texture",preload("res://assets/upstream/materials/Rock01_DM.jpg"))
 mat.set_shader_parameter("rock_normal",preload("res://assets/upstream/materials/Rock01_NM.png"))
 mat.set_shader_parameter("tint",tint)
 return mat
