shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha;
uniform vec4 fin_color : source_color = vec4(1.0,0.6,0.1,1.0);
void fragment(){
 float ribs=pow(0.5+0.5*cos(UV.x*92.0),10.0);
 ALBEDO=fin_color.rgb*(0.82+0.18*ribs);
 ALBEDO=mix(ALBEDO,vec3(0.035,0.05,0.06),smoothstep(0.88,1.0,UV.y)*0.65);
 ALPHA=mix(0.93,0.58,UV.y)+ribs*0.1;
 ROUGHNESS=0.58;
}
