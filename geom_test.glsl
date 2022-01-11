#version 330

layout (points) in;
layout (points, max_vertices=1) out;

in vec3 v_point[1];
in vec4 v_color[1];

out vec4 g_color;

void main() {
    gl_Position = vec4(v_point[0], 1.0);
    g_color = v_color[0];
    EmitVertex();
    EndPrimitive();
}