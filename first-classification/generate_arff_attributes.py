import os
import sys
import cv2 as cv
import numpy as np
# stuff for LBP
from skimage.feature import local_binary_pattern
from skimage import data

def get_header():
    header = ""
    header += '@RELATION amazon\n\n'
    header += '@ATTRIBUTE id string\n'
    header += '@ATTRIBUTE mean_r numeric\n'
    header += '@ATTRIBUTE mean_g numeric\n'
    header += '@ATTRIBUTE mean_b numeric\n'
    header += '@ATTRIBUTE mean_intensity numeric\n'
    header += '@ATTRIBUTE gray_histogram_0 numeric\n'
    header += '@ATTRIBUTE gray_histogram_1 numeric\n'
    header += '@ATTRIBUTE gray_histogram_2 numeric\n'
    header += '@ATTRIBUTE gray_histogram_3 numeric\n'
    header += '@ATTRIBUTE gray_histogram_4 numeric\n'
    header += '@ATTRIBUTE gray_histogram_5 numeric\n'
    header += '@ATTRIBUTE gray_histogram_6 numeric\n'
    header += '@ATTRIBUTE gray_histogram_7 numeric\n'
    header += '@ATTRIBUTE gray_histogram_8 numeric\n'
    header += '@ATTRIBUTE gray_histogram_9 numeric\n'
    header += '@ATTRIBUTE gray_histogram_10 numeric\n'
    header += '@ATTRIBUTE gray_histogram_11 numeric\n'
    header += '@ATTRIBUTE gray_histogram_12 numeric\n'
    header += '@ATTRIBUTE gray_histogram_13 numeric\n'
    header += '@ATTRIBUTE gray_histogram_14 numeric\n'
    header += '@ATTRIBUTE gray_histogram_15 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_0 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_1 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_2 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_3 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_4 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_5 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_6 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_7 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_8 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_9 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_10 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_11 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_12 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_13 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_14 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_15 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_16 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_17 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_18 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_19 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_20 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_21 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_22 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_23 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_24 numeric\n'
    header += '@ATTRIBUTE lbp_histogram_25 numeric\n'
    header += '@ATTRIBUTE hough_max_rho numeric\n'
    header += '@ATTRIBUTE hough_length numeric\n'
    header += '@ATTRIBUTE class {forest,water,grass,dirty,human-made}\n'
    header += '\n'
    header += '@DATA'
    return header

def get_color_features(sample):
    features = {}
    image = cv.imread(sample['image_file'])
    gray_image = cv.imread(sample['image_file'], cv.IMREAD_GRAYSCALE)
    mask = cv.imread(sample['mask_file'], cv.IMREAD_GRAYSCALE)
    hist = cv.calcHist([gray_image], [0], mask, [16], [0,256])
    cv.normalize(hist, hist)
    features['mean_color'] = cv.mean(image, mask=mask)
    features['mean_intensity'] = cv.mean(gray_image, mask=mask)
    features['gray_histogram'] = hist
    return features

def get_texture_features(sample):
    features = {}
    image = cv.imread(sample['image_file'], cv.IMREAD_GRAYSCALE)
    radius = 3
    n_points = 8 * radius
    lbp = local_binary_pattern(image, n_points, radius, 'uniform')
    n_bins = lbp.max() + 1
    hist, _ = np.histogram(lbp, normed=True, bins=n_bins, range=(0, n_bins))
    features['lbp_histogram'] = hist
    return features

def get_shape_features(sample):
    features = {}
    mask = cv.imread(sample['mask_file'], cv.IMREAD_GRAYSCALE)
    edges = cv.Canny(mask, 0, 10)
    lines = cv.HoughLines(edges, 1, np.pi/180, 80)
    if lines is not None:
        max_value = int(max(abs(lines[:,:,0]))[0])
        features['hough_length'] = len(lines[:,:,0])
        features['hough_max_rho'] = max_value
    else:
        features['hough_length'] = 0
        features['hough_max_rho'] = 0
    return features

def parse_arff_content(file_content):
    parsed_content = {}
    lines = file_content.split('\n')
    curr_line = 0

    # skip to data section
    while (lines[curr_line]!="@DATA"):
        curr_line += 1
    curr_line += 1

    for line in lines[curr_line:len(lines)-1]:
        parsed_line = parse_line(line)
        key = parsed_line['id']
        parsed_content[key] = parsed_line

    return parsed_content

def parse_line(line):
    parsed_line = {}
    attrs = line.split(',')
    key = attrs[0].replace('\'', '')
    parsed_line['id'] = key
    parsed_line['class'] = attrs[len(attrs)-1]
    parsed_line['image_file'] = os.path.abspath(os.path.join(samples_dir, key+'.ppm'))
    parsed_line['mask_file'] = os.path.abspath(os.path.join(samples_dir, key+'_mask.ppm'))
    return parsed_line

samples_dir = sys.argv[1]
arff_file = sys.argv[2]

input_file = open(arff_file, "r")
content = input_file.read()
input_file.close()
data = parse_arff_content(content)

output_file = open(arff_file, "w")
output_file.write(get_header())

sys.stdout.write('Extracting sample attributes...')
sys.stdout.flush()
for key in data.keys():
    sample = data[key]

    cf = get_color_features(sample)
    tf = get_texture_features(sample)
    sf = get_shape_features(sample)

    output_file.write("\n")
    output_file.write("\'%s\'," % (key))
    output_file.write("%f," % (cf['mean_color'][2]))
    output_file.write("%f," % (cf['mean_color'][1]))
    output_file.write("%f," % (cf['mean_color'][0]))
    output_file.write("%f," % (cf['mean_intensity'][0]))
    for hist_bin in cf['gray_histogram']:
        output_file.write("%f," % hist_bin)
    for hist_bin in tf['lbp_histogram']:
        output_file.write("%f," % hist_bin)
    output_file.write("%d," % (sf['hough_max_rho']))
    output_file.write("%d," % (sf['hough_length']))
    output_file.write("%s" % (sample['class']))
    sys.stdout.write('.')
    sys.stdout.flush()
output_file.close()