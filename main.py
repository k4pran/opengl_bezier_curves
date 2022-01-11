import moderngl
import numpy as np

from PIL import Image

ctx = moderngl.create_standalone_context()

shaders_source = {}

with open("vert_test.glsl", "r") as f:
    shaders_source['vertex_shader'] = f.read()

with open("geom_test.glsl", "r") as f:
    shaders_source['geometry_shader'] = f.read()

with open("frag_test.glsl", "r") as f:
    shaders_source['fragment_shader'] = f.read()

prog = ctx.program(**shaders_source)

points = np.array([
    [0.0, 0.0, 0.0, 1, 0, 0, 1],
])

ctx.enable(moderngl.PROGRAM_POINT_SIZE)
vbo = ctx.buffer(points.astype('f4').tobytes())
vao = ctx.simple_vertex_array(prog, vbo, 'point', 'color')

fbo = ctx.simple_framebuffer((512, 512))

fbo.use()

fbo.clear(0.0, 0.0, 0.0, 1.0)

vao.render(moderngl.POINTS)

Image.frombytes('RGB', fbo.size, fbo.read(), 'raw', 'RGB', 0, -1).show()