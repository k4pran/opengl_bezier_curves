#version 330

uniform mat4 proj_mat;

in vec3 point;

out vec4 v_point;

void main(){
    v_point = proj_mat * vec4(point, 1.0);
}