#include <flutter/runtime_effect.glsl>

uniform vec2 resolution;
uniform float radius;
uniform vec2 center;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy;
    vec2 diff = uv - center;
    float dist = length(diff);
    float strength = 0.0;
    
    if (dist < radius) {
        float edge = dist / radius;
        strength = (1.0 - edge) * 0.03;
    }
    
    vec2 offset = normalize(diff) * strength * 40.0;
    vec2 sampleUV = uv + offset;
    vec4 color = texture(uScene, sampleUV / resolution);
    
    fragColor = color;
}