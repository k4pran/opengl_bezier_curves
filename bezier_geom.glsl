#version 330

const int MIN_SEGMENTS = 3;
const int MAX_SEGMENTS = 16;

layout (lines_adjacency) in;
layout (triangle_strip, max_vertices=256) out;

uniform int segments;
uniform float width;
uniform int start_segment;
uniform int end_segment;

in vec4 v_point[4];

out vec2 center;
out vec2 pos;

vec3 quadratic_bezier(vec3 p1, vec3 c1, vec3 p2, float t) {
    vec3 term1 = pow(1. - t, 2) * p1;
    vec3 term2 = 2. * t * (1. - t) * c1;
    vec3 term3 = pow(t, 2) * p2;
    return term1 + term2 + term3;
}

vec3 cubic_bezier(vec3 p1, vec3 c1, vec3 c2, vec3 p2, float t) {
    vec3 term1 = pow(1. - t, 3) * p1;
    vec3 term2 = 3. * pow(1. - t, 2) * t * c1;
    vec3 term3 = 3. * (1. - t) * pow(t, 2) * c2;
    vec3 term4 = pow(t, 3) * p2;

    return term1 + term2 + term3 + term4;
}

vec3 perp_clockwise(vec3 v1) {
    return vec3(v1[1], -v1[0], v1.z);
}

vec3 perp_anticlockwise(vec3 v1) {
    return vec3(-v1.y, v1.x, v1.z);
}

vec3 find_mid_point(vec3 p1, vec3 p2) {
    return (p1 + p2) / 2.;
}

void triangulate_cap(vec3 start, vec3 end) {
    float cap_size = width / 4.;
    vec3 v1 = end - start;

    end += (normalize(v1)) * cap_size;

    float cap_curve_factor = 1.;
    vec2 end_center = end.xy - ((end.xy - start.xy) * cap_curve_factor);

    vec3 v_start_to_border = perp_clockwise(normalize(v1));

    vec3 start_border_point_1 = start + (v_start_to_border * (width / 2.));
    vec3 start_border_point_2 = start - (v_start_to_border * (width / 2.));

    vec3 end_border_point_1 = end + (v_start_to_border * (width / 2.));
    vec3 end_border_point_2 = end - (v_start_to_border * (width / 2.));

    // Start triangle
    gl_Position = vec4(end_border_point_1, 1.);
    pos = end_border_point_1.xy;
    center = end_center;
    EmitVertex();

    gl_Position = vec4(end_border_point_2, 1.);
    pos = end_border_point_2.xy;
    center = end_center.xy;
    EmitVertex();

    gl_Position = vec4(start_border_point_2, 1.);
    pos = start_border_point_2.xy;
    center = start.xy;
    EmitVertex();
    EndPrimitive();

    // End Triangle

    gl_Position = vec4(start_border_point_2, 1.);
    pos = start_border_point_2.xy;
    center = start.xy;
    EmitVertex();

    gl_Position = vec4(end_border_point_1, 1.);
    pos = end_border_point_1.xy;
    center = end_center;
    EmitVertex();

    gl_Position = vec4(start_border_point_1, 1.);
    pos = start_border_point_1.xy;
    center = start.xy;
    EmitVertex();
    EndPrimitive();
}

//void triangulate_cap(vec3 start, vec3 end) {
//    float cap_size = width / 4.;
//    vec3 v1 = end - start;
//
//    end += (normalize(v1)) * cap_size;
//
//    float cap_curve_factor = 1.;
//    vec2 end_center = end.xy - ((end.xy - start.xy) * cap_curve_factor);
//
//    vec3 v_start_to_border = perp_clockwise(normalize(v1));
//
//    vec3 start_border_point_1 = start + (v_start_to_border * (width / 2.));
//    vec3 start_border_point_2 = start - (v_start_to_border * (width / 2.));
//
//    vec3 end_border_point_1 = end + (v_start_to_border * (width / 2.));
//    vec3 end_border_point_2 = end - (v_start_to_border * (width / 2.));
//
//    // Start triangle
//    gl_Position = vec4(end_border_point_1, 1.);
//    pos = end_border_point_1.xy;
//    center = end_center;
//    EmitVertex();
//
//    gl_Position = vec4(end_border_point_2, 1.);
//    pos = end_border_point_2.xy;
//    center = end_center.xy;
//    EmitVertex();
//
//    gl_Position = vec4(start_border_point_2, 1.);
//    pos = start_border_point_2.xy;
//    center = start.xy;
//    EmitVertex();
//    EndPrimitive();
//
//    // End Triangle
//
//    gl_Position = vec4(start_border_point_2, 1.);
//    pos = start_border_point_2.xy;
//    center = start.xy;
//    EmitVertex();
//
//    gl_Position = vec4(end_border_point_1, 1.);
//    pos = end_border_point_1.xy;
//    center = end_center;
//    EmitVertex();
//
//    gl_Position = vec4(start_border_point_1, 1.);
//    pos = start_border_point_1.xy;
//    center = start.xy;
//    EmitVertex();
//    EndPrimitive();
//}

void triangulate(vec3 start, vec3 anchor, vec3 end) {
    vec3 v_anc1 = anchor - start;
    vec3 v_anc2 = anchor - end;

    vec3 v_start_to_border = perp_anticlockwise(normalize(v_anc1));
    vec3 v_end_to_border = perp_clockwise(normalize(v_anc2));
    vec3 v_corner = normalize(v_start_to_border + v_end_to_border);

    vec3 start_border_point_1 = start + (v_start_to_border * (width / 2.));
    vec3 start_border_point_2 = start - (v_start_to_border * (width / 2.));
    vec3 anchor_border_point_1 = anchor + (v_start_to_border * (width / 2.));
    vec3 anchor_border_point_2 = anchor + (v_end_to_border * (width / 2.));
    vec3 end_border_point_1 = end + (v_end_to_border * (width / 2.));
    vec3 end_border_point_2 = end - (v_end_to_border * (width / 2.));
    vec3 corner_point = anchor - (v_corner * (width / 2.));

    // Start segment
    gl_Position = vec4(start_border_point_1, 1.);
    pos = start_border_point_1.xy;
    center = ((start_border_point_1 + start_border_point_2) / 2.).xy;
    EmitVertex();

    gl_Position = vec4(start_border_point_2, 1.);
    pos = start_border_point_2.xy;
    center = ((start_border_point_1 + start_border_point_2) / 2.).xy;
    EmitVertex();

    gl_Position = vec4(corner_point, 1.);
    pos = corner_point.xy;
    center = ((corner_point + (v_start_to_border * (width / 2.)))).xy;
    EmitVertex();
    EndPrimitive();

    gl_Position = vec4(corner_point, 1.);
    pos = corner_point.xy;
    center = ((corner_point + (v_start_to_border * (width / 2.)))).xy;
    EmitVertex();

    gl_Position = vec4(start_border_point_1, 1.);
    pos = start_border_point_1.xy;
    center = ((start_border_point_1 + start_border_point_2) / 2.).xy;
    EmitVertex();

    gl_Position = vec4(anchor_border_point_1, 1.);
    pos = anchor_border_point_1.xy;
    center = ((anchor_border_point_1 - (v_start_to_border * (width / 2.)))).xy;
    EmitVertex();
    EndPrimitive();

    // Anchor segment

    gl_Position = vec4(anchor_border_point_1, 1.);
    pos = anchor_border_point_1.xy;
    center = ((anchor_border_point_1 + corner_point) / 2.).xy;
    EmitVertex();

    gl_Position = vec4(corner_point, 1.);
    pos = corner_point.xy;
    center = ((corner_point + anchor_border_point_1) / 2.).xy;
    EmitVertex();

    gl_Position = vec4(anchor_border_point_2, 1.);
    pos = anchor_border_point_2.xy;
    center = ((corner_point + anchor_border_point_2) / 2.).xy;
    EmitVertex();
    EndPrimitive();


    // End segment
    gl_Position = vec4(anchor_border_point_2, 1.);
    pos = anchor_border_point_2.xy;
    center = ((anchor_border_point_2 - (v_end_to_border * (width / 2.)))).xy;
    EmitVertex();

    gl_Position = vec4(end_border_point_1, 1.);
    pos = end_border_point_1.xy;
    center = ((end_border_point_1 + end_border_point_2) / 2.).xy;
    EmitVertex();

    gl_Position = vec4(corner_point, 1.);
    pos = corner_point.xy;
    center = ((corner_point + anchor_border_point_2) / 2.).xy;
    EmitVertex();
    EndPrimitive();

    gl_Position = vec4(corner_point, 1.);
    pos = corner_point.xy;
    center = ((corner_point + (v_end_to_border * (width / 2.)))).xy;
    EmitVertex();

    gl_Position = vec4(end_border_point_2, 1.);
    pos = end_border_point_2.xy;
    center = ((end_border_point_2 + end_border_point_1) / 2.).xy;
    EmitVertex();

    gl_Position = vec4(end_border_point_1, 1.);
    pos = end_border_point_1.xy;
    center = ((end_border_point_2 + end_border_point_1) / 2.).xy;
    EmitVertex();
    EndPrimitive();
}

void main() {
    int nb_segments = end_segment - start_segment;
    nb_segments = nb_segments > MAX_SEGMENTS ? MAX_SEGMENTS : nb_segments;
    nb_segments = nb_segments < MIN_SEGMENTS ? MIN_SEGMENTS : nb_segments;

    // start and end points
    vec4 p1 = v_point[0];
    vec4 p2 = v_point[3];

    // control points
    vec4 c1 = v_point[1];
    vec4 c2 = v_point[2];

    // get bezier points
    vec3 bezier_points[MAX_SEGMENTS];

    // bridge segments
    if (start_segment != 0) {
        vec3 bezier_point1 = cubic_bezier(p1.xyz, c1.xyz, c2.xyz, p2.xyz, (start_segment - 1) / float(segments));
        vec3 bezier_point2 = cubic_bezier(p1.xyz, c1.xyz, c2.xyz, p2.xyz, (start_segment) / float(segments));
        vec3 bezier_point3 = cubic_bezier(p1.xyz, c1.xyz, c2.xyz, p2.xyz, (start_segment + 1) / float(segments));
        vec3 mid_point1 = find_mid_point(bezier_point1, bezier_point2);
        vec3 mid_point2 = find_mid_point(bezier_point2, bezier_point3);
        triangulate(mid_point1, bezier_point2, mid_point2);
    }

    for (int i = 0; i <= nb_segments; i++) {
        vec3 bezier_point = cubic_bezier(p1.xyz, c1.xyz, c2.xyz, p2.xyz, (i + start_segment) / float(segments));
        bezier_points[i] = bezier_point;
    }

    // get mids
    vec3 mid_points[MAX_SEGMENTS];
    for (int i = 0; i < nb_segments; i++) {
        mid_points[i] = find_mid_point(bezier_points[i], bezier_points[i + 1]);
    }

    if (start_segment == 0) {
        triangulate_cap(mid_points[0], bezier_points[0]);
    }

    for (int i = 1; i < nb_segments; i++) {
        triangulate(mid_points[i - 1], bezier_points[i], mid_points[i]);
    }

    if (end_segment == segments) {
        triangulate_cap(mid_points[nb_segments - 1], bezier_points[nb_segments]);
    }
}