import cv2
import numpy as np
import os
import sys

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

def calculate_edge_error(ground_truth, candidade):
    result = ground_truth - candidade
    width, height, depth = result.shape
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


### EXECUTION ###
dat_folder = sys.argv[1]
seg_folder = "segmentation/mseg/out"

file_list = []
for file in os.listdir(dat_folder):
    if file.endswith(".dat"):
        file_list.append(file)

total_error = 0
count = 0
for i in xrange(0, len(file_list)):
    dat_file = dat_folder + "/" + file_list[i];
    img_file = seg_folder + "/" + file_list[i][0:-4] + ".ppm"

    dat = open(dat_file, 'r').read()
    im_dat = convert_dat_to_image(dat)
    im_mseg = cv2.imread(img_file)

    e_mseg = find_edges(im_mseg)
    e_dat = find_edges(im_dat)
    current_error = calculate_edge_error(e_dat, e_mseg)

    count += 1
    total_error += current_error

    print img_file, current_error

print "Average edge error:", (total_error/count)
