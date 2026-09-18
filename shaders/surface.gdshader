shader_type spatial;
render_mode cull_disabled;
uniform sampler2D atlas : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D leaf_texture : source_color, filter_linear_mipmap_anisotropic;
uniform vec2 tile = vec2(0.0);
uniform vec4 tint : source_color = vec4(1.0);
uniform float repeats = 1.0;
uniform float sway = 0.0;
uniform float phase = 0.0;
uniform float metallic_amount = 0.0;
varying vec3 world;
void vertex(){
 VERTEX.x += sin(TIME * 0.48 + VERTEX.y * 0.32 + phase) * sway * VERTEX.y * VERTEX.y * 0.012;
 world = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}
void fragment(){
 vec2 q = tile + vec2(0.008) + fract(UV * repeats) * 0.484;
 vec3 tex = texture(atlas,q).rgb;
 float caustic = pow(0.5+0.5*sin(world.x*3.2+world.z*2.9+sin(world.z*3.0-TIME*0.5)*1.7+TIME*0.7),18.0);
 ALBEDO = tex * tint.rgb * (1.0 + caustic * 0.10);
 if(sway>0.0){
  // Keep photographic vein detail while transmitting the aquarium top light.
  vec3 leaf = texture(leaf_texture,vec2(UV.x,1.0-UV.y)).rgb;
  ALBEDO = mix(leaf*vec3(1.35,1.45,1.05),vec3(0.26,0.48,0.13),0.62)*tint.rgb*mix(0.78,1.18,UV.y);
  EMISSION = ALBEDO*0.16;
  ROUGHNESS=0.63;
 }else{
  if(tile.x<0.1 && tile.y<0.1){ALBEDO=mix(ALBEDO,vec3(0.64,0.61,0.54)*tint.rgb,0.84);}
  ROUGHNESS=0.88;
 }
 METALLIC = metallic_amount;
}

