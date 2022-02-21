import moderngl_window as mglw, moderngl
import numpy as np

shaders_source = {}

with open("vert_test.glsl", "r") as f:
    shaders_source['vertex_shader'] = f.read()

# with open("geom_test.glsl", "r") as f:
#     shaders_source['geometry_shader'] = f.read()

with open("frag_test.glsl", "r") as f:
    shaders_source['fragment_shader'] = f.read()


class Test(mglw.WindowConfig):
    gl_version = (3, 3)
    window_size = (1920, 1080)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        vertices = np.array([
            0.0, 0.8,
            -0.6, -0.8,
            0.6, -0.8,
        ], dtype='f4')

        self.ctx.enable(moderngl.PROGRAM_POINT_SIZE)
        self.ctx.wireframe = False
        
        self.prog = self.ctx.program(**shaders_source)
        self.vbo = self.ctx.buffer(vertices.astype('f4').tobytes())
        self.vao = self.ctx.simple_vertex_array(self.prog, self.vbo, 'in_vert')


    def render(self, time, frametime):
        self.ctx.clear(1.0, 1.0, 1.0)
        self.vao.render(moderngl.TRIANGLES)

if __name__ == "__main__":
    mglw.run_window_config(Test)