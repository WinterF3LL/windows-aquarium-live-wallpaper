shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled;
void fragment(){
 float depth = smoothstep(0.05,0.96,UV.y);
 vec3 upper = vec3(0.025,0.29,0.59);
 vec3 lower = vec3(0.012,0.095,0.21);
 float shaft = pow(max(0.0,sin(UV.x*25.0+UV.y*2.0+sin(TIME*0.12)*0.2)),16.0);
 ALBEDO = mix(upper,lower,depth)+vec3(0.015,0.06,0.09)*shaft*(1.0-depth);
}
