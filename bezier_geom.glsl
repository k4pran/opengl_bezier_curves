#version 330

layout (triangles) in;
layout (line_strip, max_vertices=200) out;

uniform int steps;

in vec4 v_point[3];

vec3 quadratic_bezier(vec3 p1, vec3 c1, vec3 p2, float t) {
    vec3 term1 = pow(1. - t, 2) * p1;
    vec3 term2 = 2. * t * (1. - t) * c1;
    vec3 term3 = pow(t, 2) * p2;
    return term1 + term2 + term3;
}


void main() {

    // start and end points
    vec4 p1 = v_point[0];
    vec4 p2 = v_point[2];

    // control point
    vec4 c1 = v_point[1];

    vec3 last_point = p1.xyz;
    for (int i = 0; i <= steps; i += 2) {
        vec3 current_point = quadratic_bezier(p1.xyz, c1.xyz, p2.xyz, i /  float(steps));

        gl_Position = vec4(last_point, 1.);
        EmitVertex();

        gl_Position = vec4(current_point, 1.);
        EmitVertex();
        EndPrimitive();

        last_point = current_point;
    }
}