import moderngl
import moderngl_window as mglw
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
    # window_size = (800, 600)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        vertices = np.array([
            [1., 0., 0.],
            [1., 1. / 3., 0.],
            [1., 2. / 3., 0.],
            [1., 1., 0.],

            [1., 1., 0.],
            [4./3., 1., 0.],
            [5./3., 1., 0.],
            [2., 1., 0.],
        ], dtype='f4')

        # r = 5.
        # theta = np.pi / 2.
        # k = (4./3.) * np.tan(theta/4.)
        #
        # vertices = np.array([
        #     *np.array([r, 0., 0.]),
        #     *np.array([r, r * k, 0.]),
        #     *np.array([r * (np.cos(theta) + k * np.sin(theta)), r * (np.sin(theta) - k * np.cos(theta)), 0.]),
        #     *np.array([r * np.cos(theta), r * np.sin(theta), 0.]),
        # ], dtype='f4')

        self.ctx.enable(moderngl.PROGRAM_POINT_SIZE)
        # self.ctx.enable(moderngl.BLEND)
        # self.ctx.enable(moderngl.DEPTH_TEST)
        # self.ctx.blend_func = (moderngl.SRC_ALPHA, moderngl.ONE_MINUS_SRC_ALPHA)
        # self.ctx.blend_equation = moderngl.MIN
        self.ctx.wireframe = False
        self.detail = 3
        self.segments_per_render = 15

        self.prog = self.ctx.program(**shaders_source)
        self.prog['width'] = .08
        self.prog['aspect_ratio'] = self.aspect_ratio
        self.prog['segments'] = self.detail * self.segments_per_render
        self.prog['start_segment'] = 0
        self.prog['end_segment'] = 15

        model_mat: np.ndarray = np.eye(4)
        view_mat: np.ndarray = np.eye(4)
        proj_mat: np.ndarray = frustum(-5. / 2. * self.aspect_ratio,
                                            5. / 2. * self.aspect_ratio,
                                            -5. / 2, 5. / 2.,
                                            -10., 10.)

        # self.translate_by(model_mat, x=100, y=50.)

        self.prog['projection'] = tuple(proj_mat.T.ravel())
        self.prog['view'] = tuple(view_mat.T.ravel())
        self.prog['model'] = tuple(model_mat.T.ravel())
        # self.prog['uBlendFactor'] = 6.1

        self.vbo = self.ctx.buffer(vertices.astype('f4').tobytes())
        self.vao = self.ctx.simple_vertex_array(self.prog, self.vbo, 'point')

    # def translate_by(self, model: np.ndarray, x=0., y=0., z=0.):
    #     model[0][3] += x
    #     model[1][3] += y
    #     model[2][3] += z

    def render(self, time, frametime):
        self.ctx.clear(1.0, 1.0, 1.0)

        for i in range(0, self.prog['segments'].value, self.segments_per_render):
            self.prog['start_segment'] = i
            self.prog['end_segment'] = i + self.segments_per_render
            self.vao.render(moderngl.LINES_ADJACENCY)


if __name__ == "__main__":
    mglw.run_window_config(Test)
