import os
import sys
import cv2 as cv
import numpy as np

def parse_arff_content(file_content):
    parsed_content = {}
    parsed_content['samples'] = {}
    lines = file_content.split('\n')
    curr_line = 0

    # skip to data section
    while (lines[curr_line]!="@DATA"):
        curr_line += 1
    curr_line += 1

    parsed_content['header'] = lines[0:curr_line]

    for line in lines[curr_line:len(lines)-1]:
        parsed_line = parse_line(line)
        key = parsed_line['id']
        parsed_content['samples'][key] = parsed_line

    return parsed_content

def parse_line(line):
    parsed_line = {}
    attrs = line.split(',')
    parsed_line['id'] = attrs[0].replace('\'', '')
    others = ''
    for i in range(1,len(attrs)-1):
        others += attrs[i]+','
    parsed_line['others'] = others
    parsed_line['class'] = attrs[len(attrs)-1]
    return parsed_line

def label_samples(samples, original_dir, sample_dir):
    for key in samples.keys():
        if samples[key]['class']!='?':
            continue
        mask, original = load_images_from_key(key, original_dir, sample_dir)
        new_mask = np.zeros(original.shape, np.uint8)
        segment = cv.bitwise_and(original, original, mask=mask)
        cv.imshow('original', original)
        cv.imshow('mask', mask)
        cv.imshow('segment', segment)
        cv.moveWindow('original', 0, 0)
        cv.moveWindow('mask', 640, 0)
        cv.moveWindow('segment', 320, 525)
        while (True):
            pressed = cv.waitKey(0)
            if pressed == 27:
                return
            elif pressed == ord('f'):
                samples[key]['class'] = 'forest'
                break
            elif pressed == ord('w'):
                samples[key]['class'] = 'water'
                break
            elif pressed == ord('g'):
                samples[key]['class'] = 'grass'
                break
            elif pressed == ord('d'):
                samples[key]['class'] = 'dirty'
                break
            elif pressed == ord('h'):
                samples[key]['class'] = 'human-made'
                break
            elif pressed == ord('?'):
                samples[key]['class'] = '?'
                break

def load_images_from_key(key, original_dir, sample_dir):
    original_filename = key.split('.')[0]+'.jpg'
    mask_path = os.path.join(sample_dir, key+'_mask.ppm')
    original_path = os.path.join(original_dir, original_filename)
    mask = cv.imread(mask_path, cv.IMREAD_GRAYSCALE)
    original = cv.imread(original_path)
    return mask, original

def update_arff_file(data, arff_path):
    arff_file = open(arff_path, 'w')
    header = data['header']
    samples = data['samples']
    for line in header:
        arff_file.write(line+'\n')
    for key in samples.keys():
        sample = samples[key]
        arff_file.write('\'%s\',' % sample['id'])
        if len(sample['others']) > 0:
            arff_file.write("%s" % sample['others'])
        arff_file.write("%s" % sample['class'])
        arff_file.write("\n")

images_dir = sys.argv[1]
segmnt_dir = sys.argv[2]
arff_path = sys.argv[3]

arff_file = open(arff_path, 'r')
content = arff_file.read()
data = parse_arff_content(content)
label_samples(data['samples'], images_dir, segmnt_dir)
update_arff_file(data, arff_path)
