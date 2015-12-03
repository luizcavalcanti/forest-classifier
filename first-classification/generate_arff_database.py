import os
import sys
import cv2 as cv
import numpy as np
# stuff for LBP
from skimage.feature import local_binary_pattern
from skimage import data

samples_dir = sys.argv[1]
arff_file = sys.argv[2]

def load_image_files(img_folder):
    file_list = {}
    for path, subdirs, files in os.walk(img_folder):
        for name in files:
            if name.endswith(".ppm") and not name.endswith('_mask.ppm'):
                key = name[0:-4]
                file_list[key] = {}
                file_list[key]['image_file'] = os.path.abspath(os.path.join(path, key+'.ppm'))
                file_list[key]['mask_file'] = os.path.abspath(os.path.join(path, key+'_mask.ppm'))
    return file_list

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
    n_bins = 16 #lbp.max() + 1
    hist, _ = np.histogram(lbp, normed=True, bins=n_bins, range=(0, n_bins))
    features['lbp_histogram'] = hist
    return features

print('Generating arff file...')
output_file = open(arff_file, "w")
output_file.write(get_header())
files = load_image_files(samples_dir)
for key in files.keys():
    sample = files[key]

    cf = get_color_features(sample)
    tf = get_texture_features(sample)

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
    output_file.write("?")
output_file.close()