import cv2
import numpy as np

def convert_dat_to_image(dat, width, height):
    lines = dat.split('\n')
    regions = int(lines[0])
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
    return cv2.Canny(image, 200, 255)

def calculate_edge_error(ground_truth, candidate):
    kernel = np.ones((5,5),np.uint8)
    candidate = cv2.dilate(candidate, kernel, iterations = 1)
    ground_truth = cv2.dilate(ground_truth, kernel, iterations = 0)
    result = ground_truth - candidate

    gt_non_black = (ground_truth == 255).sum()
    cd_non_black = (candidate == 255).sum()
    error_count = (result == 255).sum()

    if gt_non_black == 0 or cd_non_black == 0: # if ground truth or candidate is a single region, error is zero (meh)
        return 0
    else:
        return float(error_count)/float(cd_non_black)
