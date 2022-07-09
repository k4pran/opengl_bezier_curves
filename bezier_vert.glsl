#version 330

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

in vec3 point;
in vec4 color;

out vec4 v_point;
out vec4 v_color;

void main(){
    v_color = color;
    v_point = projection * view * model * vec4(point, 1.0);
}