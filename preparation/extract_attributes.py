import os
import sys
import cv2
import numpy as np
import pandas as pd
from skimage.feature import local_binary_pattern


def extract_mean_rgb(color_image, mask):
    mean = cv2.mean(color_image, mask=mask)
    return mean[2], mean[1], mean[0]


def extract_mean_intensity(gray_image, mask):
    return cv2.mean(gray_image, mask=mask)[0]


def extract_intensity_histogram(gray_image, mask):
    gray_hist = cv2.calcHist([gray_image], [0], mask, [16], [0,256])
    cv2.normalize(gray_hist, gray_hist)
    return gray_hist


def extract_lbp_histogram(gray_image):
    radius = 3
    n_points = 8 * radius
    lbp = local_binary_pattern(gray_image, n_points, radius, 'uniform')
    n_bins = int(lbp.max() + 1)
    lbp_hist, _ = np.histogram(lbp, normed=True, bins=n_bins, range=(0, n_bins))
    return lbp_hist


def extract_hough_features(mask):
    edges = cv2.Canny(mask, 0, 10)
    lines = cv2.HoughLines(edges, 1, np.pi/180, 80)

    if lines is not None:
        hough_max_rho = int(max(abs(lines[:,:,0]))[0])
        hough_length = len(lines[:,:,0])
    else:
        hough_max_rho = 0
        hough_length = 0

    return hough_max_rho, hough_length


samples_dir = sys.argv[1]
csv_file = sys.argv[2]

dataset = pd.read_csv(csv_file, dtype={'id': object})

features = pd.DataFrame(columns=['mean_r',
                                 'mean_g',
                                 'mean_b',
                                 'mean_intensity',
                                 'gray_histogram_0',
                                 'gray_histogram_1',
                                 'gray_histogram_2',
                                 'gray_histogram_3',
                                 'gray_histogram_4',
                                 'gray_histogram_5',
                                 'gray_histogram_6',
                                 'gray_histogram_7',
                                 'gray_histogram_8',
                                 'gray_histogram_9',
                                 'gray_histogram_10',
                                 'gray_histogram_11',
                                 'gray_histogram_12',
                                 'gray_histogram_13',
                                 'gray_histogram_14',
                                 'gray_histogram_15',
                                 'lbp_histogram_0',
                                 'lbp_histogram_1',
                                 'lbp_histogram_2',
                                 'lbp_histogram_3',
                                 'lbp_histogram_4',
                                 'lbp_histogram_5',
                                 'lbp_histogram_6',
                                 'lbp_histogram_7',
                                 'lbp_histogram_8',
                                 'lbp_histogram_9',
                                 'lbp_histogram_10',
                                 'lbp_histogram_11',
                                 'lbp_histogram_12',
                                 'lbp_histogram_13',
                                 'lbp_histogram_14',
                                 'lbp_histogram_15',
                                 'lbp_histogram_16',
                                 'lbp_histogram_17',
                                 'lbp_histogram_18',
                                 'lbp_histogram_19',
                                 'lbp_histogram_20',
                                 'lbp_histogram_21',
                                 'lbp_histogram_22',
                                 'lbp_histogram_23',
                                 'lbp_Histogram_24',
                                 'lbp_histogram_25',
                                 'hough_max_rho',
                                 'hough_length'])

dataset = dataset.join(features)

total_size = len(dataset)

for index, sample in dataset.iterrows():
    sys.stdout.write('\rExtracting features: {} of {}'.format(index+1, total_size))
    sys.stdout.flush()

    image_file = os.path.abspath(os.path.join(samples_dir, sample['id']+'.ppm'))
    mask_file = os.path.abspath(os.path.join(samples_dir, sample['id']+'_mask.ppm'))

    color_image = cv2.imread(image_file)
    gray_image = cv2.imread(image_file, cv2.IMREAD_GRAYSCALE)
    mask = cv2.imread(mask_file, cv2.IMREAD_GRAYSCALE)


    mean_intensity = extract_mean_intensity(gray_image, mask)
    intensity_histogram = extract_intensity_histogram(gray_image, mask)
    mean_b, mean_g, mean_r = extract_mean_rgb(color_image, mask)
    hough_max_rho, hough_length = extract_hough_features(mask)
    lbp_histogram = extract_lbp_histogram(gray_image)

    new_sample = [index,
                  sample['id'],
                  sample['class'],
                  float(mean_r),
                  float(mean_g),
                  float(mean_b),
                  float(mean_intensity)] + \
                  [float(n) for n in intensity_histogram] + \
                  [float(n) for n in lbp_histogram] + \
                  [float(hough_max_rho), float(hough_length)]

    dataset.loc[index] = new_sample


dataset.to_csv(csv_file)
sys.stdout.write('\n')
sys.stdout.flush()
