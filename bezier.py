import matplotlib.pyplot as plt

from linear_ops import *


def quadratic_3_control(p1: np.ndarray, p2: np.ndarray, p3: np.ndarray, t: float):
    term1 = (1 - t)**2 * p1
    term2 = 2 * t * (1 - t) * p2
    term3 = t**2 * p3
    return term1 + term2 + term3


# testing here - https://www.desmos.com/calculator/hoy2jtxhbj
def quadratic_curve(p1: np.ndarray, p2: np.ndarray, along, offset, t: float):
    v1 = np.array([p2[0] - p1[0], p2[1] - p1[1]])
    norm_v1 = normalize(v1)
    perp_v1 = perp_anticlockwise_2d(norm_v1)
    perp_v1 *= offset
    along_point = p1 + along * (p2 - p1)

    ctl_p1 = np.array((perp_v1[0] + along_point[0], perp_v1[1] + along_point[1], 0))

    term1 = (1 - t)**2 * p1
    term2 = 2 * t * (1 - t) * ctl_p1
    term3 = t**2 * p2
    return term1 + term2 + term3


p1 = np.array([2., 2., 0.])
p2 = np.array([4., 6., 0.])

points = np.array([quadratic_curve(p1, p2, 0.5, 1., t) for t in np.linspace(0, 1, 10)])

plt.scatter(x=points[:, :1], y=points[:, 1:2])
plt.axis([-10, 10, -10, 10])
plt.show()
