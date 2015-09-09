import cv2
import numpy as np

def convert_dat_to_image(dat):
    lines = dat.split('\n')
    regions = int(lines[0])
    print str(regions) + " regions"
    width = 640
    height = 480
    image = np.zeros((height, width, 1), np.uint8)

    for i in range(1,regions+1):
        index = (2*i)
        region_type = lines[index-1]
        data = lines[index].replace('[','')
        data = data.replace(']', ' ')
        coords = data.split(' ')
        if region_type == 'cr': # Closed region
            start = coords[0].split(',')
            end = coords[len(coords)-2].split(',')
            draw_region_on_image(image, coords)
            cv2.line(image, (int(end[0]), int(end[1])), (int(start[0]), int(start[1])), (255,255,255),1)
        elif region_type == 'pt': # Path/Stroke
            draw_region_on_image(image, coords)
    return image

def draw_region_on_image(image, coords):
    for c in range(0, len(coords)-2):
        c1 = coords[c].split(',')
        c2 = coords[c+1].split(',')
        cv2.line(image, (int(c1[0]), int(c1[1])), (int(c2[0]), int(c2[1])), (255,255,255),1)

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