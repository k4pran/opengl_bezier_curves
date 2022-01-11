#version 330

in vec3 point;
in vec4 color;

out vec3 v_point;
out vec4 v_color;

void main(){
    v_point = point;
    v_color = color;
}