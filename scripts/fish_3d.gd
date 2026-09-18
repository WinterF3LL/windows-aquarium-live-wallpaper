extends Node3D

const MODELS = [
 preload("res://assets/upstream/fish/01_clownfish.glb"),
 preload("res://assets/upstream/fish/02_blue_tang.glb"),
 preload("res://assets/upstream/fish/24_freshwater_angelfish.glb"),
 preload("res://assets/upstream/fish/23_mandarinfish.glb"),
 preload("res://assets/upstream/fish/03_lionfish.glb")
]
var aquarium: Node3D
var species = 0
var phase = 0.0
var velocity = Vector3.ZERO
var desired = Vector3.ZERO
var time = 0.0
var decision_time = 0.0
var fear = 0.0
var rng = RandomNumberGenerator.new()
var yaw = 0.0
var floor_limit = 0.9
var half_length = 0.85
var half_height = 0.5
var swim_materials: Array[ShaderMaterial] = []

func _ready() -> void:
 rng.seed = int(phase*100000)+species*745
 var source: Node3D = MODELS[species].instantiate()
 var surfaces: Array = []
 _collect_meshes(source,Transform3D.IDENTITY,surfaces)
 var bounds = AABB()
 var first = true
 for surface in surfaces:
  var vertices: PackedVector3Array = surface[0][Mesh.ARRAY_VERTEX]
  for vertex in vertices:
   if first:
    bounds = AABB(vertex,Vector3.ZERO)
    first = false
   else:
    bounds = bounds.expand(vertex)
 var center = bounds.get_center()
 var factor = 1.7/maxf(bounds.size.x,0.001)
 half_length = bounds.size.x*factor*0.5*scale.x
 half_height = bounds.size.y*factor*0.5*scale.y
 # Full imported fins, maximum swimming pitch, and a visible water gap.
 floor_limit = -0.12+half_height+half_length*sin(0.25)+0.20
 position.y = maxf(position.y,floor_limit)
 for surface in surfaces:
  var arrays: Array = surface[0]
  var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
  for i in range(vertices.size()):
   vertices[i] = (vertices[i]-center)*factor
  arrays[Mesh.ARRAY_VERTEX] = vertices
  var mesh = ArrayMesh.new()
  mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
  var fish_mesh = MeshInstance3D.new()
  fish_mesh.mesh = mesh
  var original: Material = surface[1]
  var mat = ShaderMaterial.new()
  mat.shader = preload("res://shaders/model_fish.gdshader")
  if original is BaseMaterial3D:
   mat.set_shader_parameter("body_texture",original.albedo_texture)
   mat.set_shader_parameter("base_color",original.albedo_color)
   mat.set_shader_parameter("has_texture",original.albedo_texture != null)
  mat.set_shader_parameter("phase",phase)
  mat.set_shader_parameter("frequency",[7.0,5.0,4.0,6.0,3.5][species])
  fish_mesh.material_override = mat
  swim_materials.append(mat)
  add_child(fish_mesh)
 source.free()
 velocity = Vector3(rng.randf_range(0.4,0.8)*(1 if rng.randf()>0.5 else -1),0,0)
 yaw = 0 if velocity.x>0 else PI
 rotation.y = yaw
 desired = velocity

# Bake imported node transforms, then orient all species nose-first along +X.
func _collect_meshes(node: Node, parent_transform: Transform3D, surfaces: Array) -> void:
 var transform = parent_transform
 if node is Node3D:
  transform = parent_transform*node.transform
 if node is MeshInstance3D:
  var orient = Basis(Vector3.UP,0.0 if species==2 else PI/2.0)
  for s in range(node.mesh.get_surface_count()):
   var arrays: Array = node.mesh.surface_get_arrays(s).duplicate(true)
   var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
   var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
   for i in range(vertices.size()):
    vertices[i] = orient*(transform*vertices[i])
    if i<normals.size():
     normals[i] = (orient*transform.basis.inverse().transposed()*normals[i]).normalized()
   arrays[Mesh.ARRAY_VERTEX] = vertices
   arrays[Mesh.ARRAY_NORMAL] = normals
   arrays[Mesh.ARRAY_TANGENT] = null
   arrays[Mesh.ARRAY_BONES] = null
   arrays[Mesh.ARRAY_WEIGHTS] = null
   surfaces.append([arrays,node.get_active_material(s)])
 for child in node.get_children():
  _collect_meshes(child,transform,surfaces)
func _process(frame_delta: float) -> void:
 var delta = minf(frame_delta,0.05)
 time += delta
 decision_time -= delta
 fear = maxf(0,fear-delta*0.65)
 if decision_time<0:
  decision_time = rng.randf_range(3,6)
  desired = Vector3(rng.randf_range(0.32,0.62)*(1 if velocity.x>0 else -1),rng.randf_range(-0.12,0.12),rng.randf_range(-0.14,0.14))
 var target_velocity = desired
 if aquarium.cursor_active:
  var cursor_ray: Vector3 = aquarium.cursor_direction
  var cursor_at_depth: Vector3 = aquarium.cursor_world
  if absf(cursor_ray.z)>0.001:
   cursor_at_depth += cursor_ray*(position.z/cursor_ray.z)
  var offset: Vector3 = position-cursor_at_depth
  offset.z = 0.0
  var distance = offset.length()
  if distance<1.15 or (distance<4.5 and aquarium.cursor_speed>650):
   fear = 1.0
  if fear>0.05 and distance<6:
   target_velocity = offset.normalized()*(0.8+fear*2.0)
  elif distance<5.5 and distance>1.4 and aquarium.cursor_speed<230:
   target_velocity = -offset.normalized()*0.50
   target_velocity.y += sin(time+phase)*0.08
 # Anticipate the walls without feeding boundary corrections into speed.
 var aspect = aquarium.get_viewport().get_visible_rect().size.aspect()
 var camera_to_fish: Vector3 = global_position-aquarium.camera.global_position
 var camera_depth = maxf(0.1,camera_to_fish.dot(-aquarium.camera.global_basis.z))
 var visible_width = camera_depth*tan(deg_to_rad(aquarium.camera.fov)*0.5)*aspect
 # Keep the complete silhouette visible, but allow distant fish to use the full
 # perspective width instead of forcing every depth into the same narrow box.
 var x_limit = maxf(2.0,visible_width-half_length-0.12)
 var turn_distance = 0.55
 var ceiling_limit = 9.8-half_height
 if position.x>x_limit-turn_distance:
  desired.x = -0.48
  target_velocity.x = lerpf(target_velocity.x,-0.62,clampf((position.x-x_limit+turn_distance)/turn_distance,0.0,1.0))
 elif position.x<-x_limit+turn_distance:
  desired.x = 0.48
  target_velocity.x = lerpf(target_velocity.x,0.62,clampf((-position.x-x_limit+turn_distance)/turn_distance,0.0,1.0))
 if position.y<floor_limit+1.0:
  target_velocity.y = maxf(target_velocity.y,(floor_limit+1.0-position.y)*0.55)
 if position.y>ceiling_limit-0.8:
  target_velocity.y = minf(target_velocity.y,-(position.y-ceiling_limit+0.8)*0.55)
 if position.z>4.8:
  target_velocity.z = minf(target_velocity.z,-0.22)
 if position.z<-5.8:
  target_velocity.z = maxf(target_velocity.z,0.22)
 # Soft separation avoids overlapping schools without abrupt direction changes.
 for neighbor in aquarium.fish_list:
  if neighbor==self:
   continue
  var away: Vector3 = position-neighbor.position
  var d = away.length()
  if d>0.01 and d<0.85:
   target_velocity += away.normalized()*(0.85-d)*0.5
 var speed_limit = lerpf(0.72,2.8,fear)
 target_velocity = target_velocity.limit_length(speed_limit)
 velocity = velocity.lerp(target_velocity,1.0-exp(-delta*(1.2+fear*3))).limit_length(speed_limit)
 position += velocity*delta
 # Final silhouette containment also applies during panic and separation.
 if position.y<floor_limit:
  position.y = floor_limit
  velocity.y = maxf(velocity.y,0.12)
 if position.y>ceiling_limit:
  position.y = ceiling_limit
  velocity.y = minf(velocity.y,-0.12)
 if absf(position.x)>x_limit:
  position.x = clampf(position.x,-x_limit,x_limit)
  velocity.x = -signf(position.x)*minf(absf(velocity.x),0.72)
 position.z = clampf(position.z,-7.0,6.0)
 if velocity.length()>0.05:
  var aim = atan2(-velocity.z,velocity.x)
  yaw = lerp_angle(yaw,aim,1.0-exp(-delta*2.5))
  rotation.y = yaw
  rotation.z = lerp_angle(rotation.z,clampf(velocity.y,-0.25,0.25)*signf(velocity.x),1.0-exp(-delta*2))
 for mat in swim_materials:
  mat.set_shader_parameter("energy",1.0+fear*0.7)
