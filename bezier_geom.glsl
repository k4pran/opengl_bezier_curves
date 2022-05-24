#version 330

layout (triangles) in;
layout (triangle_strip, max_vertices=200) out;

uniform int steps;
uniform float width;

in vec4 v_point[3];

vec3 quadratic_bezier(vec3 p1, vec3 c1, vec3 p2, float t) {
    vec3 term1 = pow(1. - t, 2) * p1;
    vec3 term2 = 2. * t * (1. - t) * c1;
    vec3 term3 = pow(t, 2) * p2;
    return term1 + term2 + term3;
}

vec3 perp_clockwise(vec3 v1) {
    return vec3(v1[1], -v1[0], v1.z);
}

vec3 perp_anticlockwise(vec3 v1) {
    return vec3(-v1.y, v1.x, v1.z);
}

void asRect(vec3 p1, vec3 p2, out vec3 rect_p1, out vec3 rect_p2, out vec3 rect_p3, out vec3 rect_p4) {
    vec3 v1 = p2 - p1;
    vec3 v2 = p1 - p2;

    vec3 perp_to_v1 = perp_clockwise(normalize(v1));
    vec3 perp_to_v2 = perp_clockwise(normalize(v2));

    rect_p1 = p1 + (perp_to_v1 * (width / 2));
    rect_p2 = p1 + (-perp_to_v1 * (width / 2));
    rect_p3 = p2 + (perp_to_v2 * (width / 2));
    rect_p4 = p2 + (-perp_to_v2 * (width / 2));
}


void main() {
    gl_PointSize = 5.; // todo remove eventually

    // start and end points
    vec4 p1 = v_point[0];
    vec4 p2 = v_point[2];

    // control point
    vec4 c1 = v_point[1];

    vec3 last_point = p1.xyz;
    vec3 last_connection_point_1;
    vec3 last_connection_point_2;

    for (int i = 1; i <= steps; i += 2) {
        vec3 current_point = quadratic_bezier(p1.xyz, c1.xyz, p2.xyz, i /  float(steps));

        vec3 start = vec3(last_point);
        vec3 end = vec3(current_point);

        vec3 rect_p1;
        vec3 rect_p2;
        vec3 rect_p3;
        vec3 rect_p4;

        asRect(start, end, rect_p1, rect_p2, rect_p3, rect_p4);

        gl_Position = vec4(rect_p1, 1.);
        EmitVertex();

        gl_Position = vec4(rect_p2, 1.);
        EmitVertex();

        gl_Position = vec4(rect_p4, 1.);
        EmitVertex();
        EndPrimitive();

        gl_Position = vec4(rect_p4, 1.);
        EmitVertex();

        gl_Position = vec4(rect_p3, 1.);
        EmitVertex();

        gl_Position = vec4(rect_p2, 1.);
        EmitVertex();
        EndPrimitive();

        last_point = current_point;

        if (i > 1) {
            gl_Position = vec4(last_connection_point_1, 1.);
            EmitVertex();

            gl_Position = vec4(last_connection_point_2, 1.);
            EmitVertex();

            gl_Position = vec4(rect_p2, 1.);
            EmitVertex();
        }
        last_connection_point_1 = rect_p3;
        last_connection_point_2 = rect_p4;
    }
}