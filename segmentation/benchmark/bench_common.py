import cv2 as cv
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
            cv.line(image, (int(end[0]), int(end[1])), (int(start[0]), int(start[1])), (255,255,255),1)
        elif region_type == 'pt': # Path/Stroke
            draw_region_on_image(image, coords)
    return image

def draw_region_on_image(image, coords):
    for c in range(0, len(coords)-2):
        c1 = coords[c].split(',')
        c2 = coords[c+1].split(',')
        cv.line(image, (int(c1[0]), int(c1[1])), (int(c2[0]), int(c2[1])), (255,255,255),1)

def find_edges(image):
    return cv.Canny(image, 200, 255)

def calculate_consistency_error(img_a, img_b):
    height, width = img_a.shape[:2]

    error_ab = _compare_segmentations(img_a, img_b)
    error_ba = _compare_segmentations(img_b, img_a)

    sz_ab = len(error_ab)
    sz_ba = len(error_ba)

    if sz_ab == 0 or sz_ba == 0:
        global_error = 0
        local_error = 0
    else:
        if sz_ab > sz_ba:
            error_ba = np.pad(error_ba, (0, sz_ab - sz_ba), 'constant', constant_values=(1))
        elif sz_ab < sz_ba:
            error_ab = np.pad(error_ab, (0, sz_ba - sz_ab), 'constant', constant_values=(1))

        overall_min = np.minimum(error_ab, error_ba)
        global_error = float(1)/float(width*height) * min(sum(error_ba), sum(error_ab))
        local_error = float(1)/float(width*height) * sum(overall_min)

    return (global_error, local_error)

def _compare_segmentations(img_a, img_b):
    # contours, hierarchy = cv.findContours(image, mode, method[, contours[, hierarchy[, offset]]])
    ct_img_a, h_a = cv.findContours(img_a, cv.RETR_TREE, cv.CHAIN_APPROX_NONE)
    ct_img_b, h_b = cv.findContours(img_b, cv.RETR_TREE, cv.CHAIN_APPROX_NONE)

    error = []

    height, width = img_a.shape[:2]

    for comp_a in ct_img_a:

        mask_a = np.zeros((height, width), np.uint8)
        mask_b = np.zeros((height, width), np.uint8)

        first_point = comp_a[0][0]

        cv.fillConvexPoly(mask_a, comp_a, (255))

        for comp_b in ct_img_b:
            if cv.pointPolygonTest(comp_b, (first_point[0], first_point[1]), False) >= 0:
                cv.fillConvexPoly(mask_b, comp_b, (50))
                break

        set_difference = mask_a - mask_b
        set_difference_count = (set_difference == 255).sum()

        error.append(set_difference_count)

    return error