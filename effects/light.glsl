extern number exposure, decay, density, weight, samples;
extern vec2 light;

vec4 effect(vec4 color, Image img, vec2 tex, vec2 pix) {
  vec2 dtex = vec2(tex - light.xy) * 1.0 / number(samples) * density;
  number illum = 1.0;
  vec4 cc = vec4(0.0, 0.0, 0.0, 1.0);

  for (number i = 0; i < samples; i++) {
    tex -= dtex;
    cc += Texel(img, tex) * illum * weight;
    illum *= decay;
  }

  cc *= exposure;
  return cc;
}
