shader_type spatial;
render_mode cull_disabled;
uniform sampler2D body_texture : source_color, filter_linear_mipmap_anisotropic;
uniform vec4 base_color : source_color = vec4(1.0);
uniform bool has_texture = true;
uniform float phase = 0.0;
uniform float frequency = 6.0;
uniform float energy = 1.0;
void vertex(){
 float t = clamp((0.85-VERTEX.x)/1.7,0.0,1.0);
 float wave = TIME*frequency*energy+phase-t*5.5;
 float amplitude = 0.095*energy*pow(t,1.8);
 VERTEX.z += sin(wave)*amplitude;
 float slope = -0.095*energy/1.7*(1.8*pow(max(t,0.001),0.8)*sin(wave)-5.5*pow(t,1.8)*cos(wave));
 NORMAL = normalize(vec3(NORMAL.x-slope*NORMAL.z,NORMAL.y,NORMAL.z));
}
void fragment(){
 vec4 tex = base_color;
 if(has_texture){tex *= texture(body_texture,UV);}
 float luminance = dot(tex.rgb,vec3(0.2126,0.7152,0.0722));
 ALBEDO = mix(vec3(luminance),tex.rgb,0.86)*vec3(0.86,0.96,0.98);
 ROUGHNESS = 0.62;
 SPECULAR = 0.24;
 EMISSION = vec3(0.0);
}
