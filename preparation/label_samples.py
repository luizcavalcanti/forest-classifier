import os
import sys
import cv2
import numpy as np
import pandas as pd


def load_images_from_key(key, original_dir, sample_dir):
    original_filename = key.split('.')[0]+'.jpg'
    mask_path = os.path.join(sample_dir, key+'_mask.ppm')
    original_path = os.path.join(original_dir, original_filename)
    mask = cv2.imread(mask_path, cv2.IMREAD_GRAYSCALE)
    original = cv2.imread(original_path)
    return mask, original


images_dir = sys.argv[1]
segment_dir = sys.argv[2]
csv_path = sys.argv[3]

dataset = pd.read_csv(csv_path, dtype={'id': object})

for index, sample in dataset.iterrows():
    if sample['class']!='?':
        continue

    mask, original = load_images_from_key(sample['id'], images_dir, segment_dir)
    new_mask = np.zeros(original.shape, np.uint8)
    segment = cv2.bitwise_and(original, original, mask=mask)

    cv2.imshow('original', original)
    cv2.imshow('mask', mask)
    cv2.imshow('segment', segment)
    cv2.moveWindow('original', 0, 0)
    cv2.moveWindow('mask', original.shape[0], 0)
    cv2.moveWindow('segment', int(original.shape[0]/2), int(original.shape[1]+45))

    while (True):
        pressed = cv2.waitKey(0)
        if pressed == 27: #ESC key
            break
        elif pressed == ord('f'):
            dataset.set_value(index, 'class', 'forest')
        elif pressed == ord('w'):
            dataset.set_value(index, 'class', 'water')
        elif pressed == ord('g'):
            dataset.set_value(index, 'class', 'grass')
        elif pressed == ord('d'):
            dataset.set_value(index, 'class', 'dirty')
        elif pressed == ord('h'):
            dataset.set_value(index, 'class', 'human-made')
        else:
            dataset.set_value(index, 'class', '?')


dataset.to_csv(csv_file, index=False)
