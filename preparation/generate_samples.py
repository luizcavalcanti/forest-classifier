import os
import sys
import cv2 as cv
import numpy as np

def load_image_files(img_folder, seg_folder):
    file_list = {}
    for path, subdirs, files in os.walk(img_folder):
        for name in files:
            if name.endswith(".jpg"):
                key = name[0:-4]
                file_list[key] = {}
                file_list[key]['original'] = os.path.join(path, key+'.jpg')
                file_list[key]['segmented'] = os.path.join(seg_folder, key+'.ppm')
    return file_list

def generate_samples(key, original_image, segmentation_image, output_dir):
    original = cv.imread(original_image)
    image = cv.imread(segmentation_image, cv.IMREAD_GRAYSCALE)
    labels = np.unique(image)
    idx = 1
    for label in labels:
        segment = np.zeros(original.shape, np.uint8)
        mask = np.zeros(image.shape, np.uint8)
        indexes = image[:,:] == label
        mask[indexes] = 255
        segment[indexes] = original[indexes]
        filename = key + '.' + str(idx)
        cv.imwrite(('%s/%s.ppm' % (output_dir, filename)), segment)
        cv.imwrite(('%s/%s_mask.ppm' % (output_dir, filename)), mask)
        idx += 1

images_dir = sys.argv[1]
segmnt_dir = sys.argv[2]
output_dir = sys.argv[3]

file_list = load_image_files(images_dir, segmnt_dir)
total_files = len(file_list)

for key in file_list.keys():
    f = file_list[key]
    generate_samples(key, f['original'], f['segmented'], output_dir)
    sys.stdout.write('\rExtracting samples: {} of {}'.format(int(key), total_files))
    sys.stdout.flush()

sys.stdout.write('\n')
sys.stdout.flush()
