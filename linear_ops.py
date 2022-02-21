import math

import numpy as np


def norm_2d(vec) -> float:
    return math.sqrt(vec[0]**2 + vec[1]**2)


def normalize(vec) -> np.ndarray:
    norm = norm_2d(vec)
    return np.array(vec / norm)


# Improvement performance when getting the norm of many vectors
def norm_multi_2d(vec) -> np.ndarray:
    return np.sqrt(vec.dot(vec))


def interpolate_points_2d(p1, p2, steps) -> list:
    x_mag = np.abs(p2[0] - p1[0])
    y_mag = np.abs(p2[1] - p1[1])
    start = min(p1, p2)
    return np.array(
        [[start[0] + step * x_mag, start[1] + step * y_mag]
         for step in np.linspace(0, 1, steps)])


def perp_anticlockwise_2d(vec) -> np.ndarray:
    return np.array((-vec[1], vec[0]))


def perp_clockwise_2d(vec) -> np.ndarray:
    return np.array((vec[1], -vec[0]))
