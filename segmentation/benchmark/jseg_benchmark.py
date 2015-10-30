import cv2
import os
import sys
import bench_common as bench

dat_folder = sys.argv[1]
seg_folder = "segmentation/jseg/out"

file_list = []
for file in os.listdir(dat_folder):
    if file.endswith(".dat"):
        file_list.append(file)

total_gce = 0
total_lce = 0
count = 0
for i in xrange(0, len(file_list)):
    dat_file = dat_folder + "/" + file_list[i];
    img_file = seg_folder + "/" + file_list[i][0:-4] + ".jpg"

    dat = open(dat_file, 'r').read()
    im_seg = cv2.imread(img_file, cv2.IMREAD_GRAYSCALE)
    height, width = im_seg.shape
    im_dat = bench.convert_dat_to_image(dat, width, height)

    gce, lce = bench.calculate_consistency_error(im_dat, im_seg);

    count += 1
    total_gce += gce
    total_lce += lce

    print(img_file+' %.5f %.5f' % (gce, lce))

print "Average GCE: %.5f" % (total_gce/count)
print "Average LCE: %.5f" % (total_lce/count)