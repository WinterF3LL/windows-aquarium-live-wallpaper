shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_add;
uniform float phase = 0.0;
void fragment(){
 float edge = pow(sin(UV.x * 3.14159265), 3.0);
 float fade = pow(1.0-UV.y, 1.4);
 ALBEDO = vec3(0.16,0.5,0.65);
 ALPHA = edge * fade * (0.024 + sin(TIME*0.3+phase)*0.008);
}
