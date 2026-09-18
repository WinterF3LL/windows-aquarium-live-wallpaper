shader_type spatial;
uniform sampler2D atlas : source_color, filter_linear_mipmap_anisotropic;
uniform int species = 0;
void fragment(){
 vec3 scales = texture(atlas,vec2(0.506)+fract(UV*vec2(3.0,1.5))*0.488).rgb;
 float x = UV.x;
 vec3 c = vec3(0.12,0.43,0.76);
 if(species==0){
  c=vec3(1.0,0.32,0.035);
  float bands = max(1.0-smoothstep(0.035,0.065,abs(x-0.25)),max(1.0-smoothstep(0.035,0.065,abs(x-0.56)),1.0-smoothstep(0.025,0.05,abs(x-0.8))));
  float rims = max(1.0-smoothstep(0.064,0.08,abs(x-0.25)),max(1.0-smoothstep(0.064,0.08,abs(x-0.56)),1.0-smoothstep(0.05,0.067,abs(x-0.8))));
  c=mix(c,vec3(0.035),rims);
  c=mix(c,vec3(0.92,0.96,0.90),bands);
 }else if(species==1){
  c=vec3(0.055,0.25,0.8);
  c=mix(c,vec3(0.02,0.055,0.12),smoothstep(0.68,0.74,sin(x*6.0+UV.y*4.0)));
 }else if(species==2){
  c=vec3(0.94,0.78,0.08);
 }else{
  c=vec3(0.28,0.72,0.67);
  c=mix(c,vec3(0.055,0.17,0.19),pow(0.5+0.5*sin(x*36.0),14.0)*0.8);
 }
 float back = 0.5+0.5*cos(UV.y*6.283185);
 c *= mix(1.15,0.64,back);
 float gill = smoothstep(0.017,0.002,abs(x-0.73-0.018*sin(UV.y*6.283185)));
 c *= 1.0-gill*0.24;
 ALBEDO=c*(0.89+scales*0.13);
 ROUGHNESS=0.34;
 METALLIC=0.06;
}
