import cv2
import numpy as np

def convert_dat_to_image(dat):
    lines = dat.split('|')
    width = len(lines)
    height = len(lines[0])
    image = np.zeros((height, width, 1), np.uint8)
    for w in xrange(0, width):
        for h in xrange(0,height):
            image[h,w] = ord(lines[w][h])
    return image

def find_edges(image):
    width, height, depth = image.shape
    output_image = np.zeros((width, height, 1), np.uint8)

    # vertical scan
    for x in xrange(0, width):
        for y in xrange(0, height):
            up = image[x, y-1]
            left = image[x-1, y]
            current = image[x, y]

            if y > 0 and not (up == current).all():
                    output_image[x, y] = 255
            if x > 0 and not (left == current).all():
                    output_image[x, y] = 255

    return output_image

def calculate_edge_error(ground_truth, candidate):
    kernel = np.ones((5,5),np.uint8)
    candidate = cv2.dilate(candidate, kernel, iterations = 1)
    ground_truth = cv2.dilate(ground_truth, kernel, iterations = 0)
    result = ground_truth - candidate
    width, height = result.shape
    non_black = 0
    error_count = 0
    for x in xrange(0, width):
        for y in xrange(0, height):
            if ground_truth[x,y] == 255:
                non_black += 1
            if result[x,y] == 255:
                error_count += 1
    if non_black == 0:
        return 0
    else:
        return float(error_count)/float(non_black)