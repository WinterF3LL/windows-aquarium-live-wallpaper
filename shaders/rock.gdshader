shader_type spatial;
uniform sampler2D rock_texture : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D rock_normal : hint_normal, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0);
void fragment(){
 vec3 stone = texture(rock_texture,UV*vec2(2.0,1.0)).rgb;
 float mineral = dot(stone,vec3(0.30,0.59,0.11));
 ALBEDO = mix(stone,vec3(mineral),0.72)*tint.rgb*1.55 + tint.rgb*0.025;
 NORMAL_MAP = texture(rock_normal,UV*vec2(2.0,1.0)).rgb;
 NORMAL_MAP_DEPTH = 0.28;
 ROUGHNESS = 0.94;
}
