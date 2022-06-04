import moderngl_window as mglw, moderngl
import numpy as np

shaders_source = {}

with open("bezier_vert.glsl", "r") as f:
    shaders_source['vertex_shader'] = f.read()

with open("bezier_geom.glsl", "r") as f:
    shaders_source['geometry_shader'] = f.read()

with open("bezier_frag.glsl", "r") as f:
    shaders_source['fragment_shader'] = f.read()

def frustum(left: float, right: float, bottom: float, top: float,
                     near: float, far: float):
    width = right - left
    height = top - bottom
    depth = far - near

    x = 2. / width
    y = 2. / height
    z = 2. / depth

    a = (right + left) / width
    b = (top + bottom) / height
    c = (far + near) / depth

    return np.array(
        (
            [x, 0, 0, -a],
            [0, y, 0, -b],
            [0, 0, -z, -c],
            [0, 0, 0, 1.],
        ),
    )


class Test(mglw.WindowConfig):
    gl_version = (3, 3)
    window_size = (1920, 1080)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        vertices = np.array([
            200., 300., 0.,
            400., 600., 0.,
            600., 300., 0.
        ], dtype='f4')

        self.ctx.enable(moderngl.PROGRAM_POINT_SIZE)
        self.ctx.enable(moderngl.BLEND)
        # self.ctx.blend_func = (
        #     moderngl.SRC_ALPHA,
        #     moderngl.ONE_MINUS_SRC_ALPHA,
        #     moderngl.ONE,
        #     moderngl.ONE,
        # )
        self.ctx.wireframe = False
        
        self.prog = self.ctx.program(**shaders_source)
        self.prog['segments'] = 14
        self.prog['width'] = 0.025

        model_mat = np.eye(4)
        proj_mat = frustum(0., 800., 0., 600., -10., 10.)

        self.translate_by(model_mat, x=100, y=50.)

        self.prog['projection'] = tuple(proj_mat.T.ravel())
        self.prog['model'] = tuple(model_mat.T.ravel())
        # self.prog['uBlendFactor'] = 6.1

        self.vbo = self.ctx.buffer(vertices.astype('f4').tobytes())
        self.vao = self.ctx.simple_vertex_array(self.prog, self.vbo, 'point')


    def translate_by(self, model: np.ndarray, x=0., y=0., z=0.):
        model[0][3] += x
        model[1][3] += y
        model[2][3] += z

    def render(self, time, frametime):
        self.ctx.clear(1.0, 1.0, 1.0)
        self.vao.render(moderngl.TRIANGLES)

if __name__ == "__main__":
    mglw.run_window_config(Test)