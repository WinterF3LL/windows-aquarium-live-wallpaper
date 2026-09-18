shader_type spatial;
render_mode cull_disabled;
uniform sampler2D atlas : source_color, filter_linear_mipmap_anisotropic;
varying vec3 world;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 vec3 stone=texture(atlas,vec2(0.505,0.005)+fract(UV*2.0)*0.485).rgb;
 ALBEDO=COLOR.rgb*(0.80+stone*0.4)*mix(1.16,0.65,UV.y);
 EMISSION=ALBEDO*0.08;
 ROUGHNESS=0.86;
}
