shader_type spatial;
render_mode unshaded, fog_disabled;
uniform sampler2D reef : source_color, filter_linear_mipmap_anisotropic;
void fragment(){
 vec3 photograph = texture(reef,UV).rgb;
 // Blue water tint recedes behind the living foreground without flattening coral detail.
 float luminance = dot(photograph,vec3(0.2126,0.7152,0.0722));
 vec3 tint = mix(vec3(luminance),photograph,0.78)*vec3(0.76,0.94,1.08);
 ALBEDO = mix(tint,vec3(0.025,0.16,0.28),0.32);
}
