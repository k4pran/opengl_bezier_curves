#version 330

in vec3 point;

out vec4 v_point;

void main(){
    v_point = vec4(point, 1.0);
}