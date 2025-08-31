#version 300 es
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;        // setFloat(0, width), setFloat(1, height)
uniform float uTime;       // setFloat(2, time)
uniform sampler2D uTexture; // setImageSampler(0, image)

out vec4 fragColor;

void main() {
  // coords normalizados 0..1
  vec2 uv = FlutterFragCoord().xy / uSize;

  // “borda presa” no lado esquerdo (edge cresce pros lados soltos)
  float edge = 1.0 - uv.x;

  // ondulação principal no X, decaindo perto da borda presa
  float waveX = sin(uv.y * 9.0 + uTime * 4.0) * 0.035 * edge;

  // pequena ondulação no Y
  float waveY = cos(uv.x * 7.0 + uTime * 2.3) * 0.02 * edge;

  vec2 warped = uv + vec2(waveX, waveY);

  // leve “perspectiva” (encolhe um pouco perto da borda presa)
  float persp = 1.0 - 0.12 * edge;
  warped = mix(vec2(0.0, warped.y), warped, persp);

  // amostra textura (o seu pôster)
  vec4 c = texture(uTexture, warped);

  // sombra suave na região de maior curvatura
  float curlShade = smoothstep(0.0, 0.03, abs(waveX)) * 0.25 * edge;
  c.rgb *= (1.0 - curlShade);

  fragColor = c;
}
