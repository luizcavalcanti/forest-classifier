import cv2
import os
import sys
import bench_common as bench

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
    im_seg = cv2.imread(img_file)
    height, width, depth = im_seg.shape
    im_dat = bench.convert_dat_to_image(dat, width, height)

    e_mseg = bench.find_edges(im_seg)
    current_error = bench.calculate_edge_error(im_dat, e_mseg);

    count += 1
    total_error += current_error

    print img_file, current_error

print "Average edge error:", (total_error/count)
