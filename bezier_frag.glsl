#version 330

uniform float width;

in vec4 g_color;

in vec2 pos;
in vec2 center;

out vec4 frag_color;

void main() {
    vec2 diff = pos - center;
    float dist = length(diff);
    if (dist > (width / 2.)){
        discard;
    }

    frag_color = vec4(0., 0., 0., 1.);
    frag_color.a *= smoothstep(0., .5, 1. - (1. / (width / 2.) * dist));
}