import moderngl_window as mglw, moderngl
import numpy as np

shaders_source = {}

with open("bezier_vert.glsl", "r") as f:
    shaders_source['vertex_shader'] = f.read()

with open("bezier_geom.glsl", "r") as f:
    shaders_source['geometry_shader'] = f.read()

with open("bezier_frag.glsl", "r") as f:
    shaders_source['fragment_shader'] = f.read()

K = 0.5522847498

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
            350., 500., 0.,
            450., 500., 0.,
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
        self.detail = 3
        self.segments_per_render = 15
        
        self.prog = self.ctx.program(**shaders_source)
        self.prog['width'] = 0.1
        self.prog['segments'] = self.detail * self.segments_per_render
        self.prog['start_segment'] = 0
        self.prog['end_segment'] = 15

        model_mat: np.ndarray = np.eye(4)
        view_mat: np.ndarray = np.eye(4)
        proj_mat: np.ndarray = frustum(0., 800., 0., 600., -10., 10.)

        # self.translate_by(model_mat, x=100, y=50.)

        self.prog['projection'] = tuple(proj_mat.T.ravel())
        self.prog['view'] = tuple(view_mat.T.ravel())
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

        for i in range(0, self.prog['segments'].value, self.detail):
            self.prog['start_segment'] = i
            self.prog['end_segment'] = i + self.detail
            self.vao.render(moderngl.LINES_ADJACENCY)

if __name__ == "__main__":
    mglw.run_window_config(Test)