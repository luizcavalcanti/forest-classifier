import cv2
import os
import sys
import bench_common as bench

dat_folder = sys.argv[1]

def run_benchmark():
    file_list = _load_files()

    for key in file_list:
        file_count = len(file_list[key])
        if file_count > 1:
            results = _run_for_image(file_list[key])
            _print_results(results)

def _load_files():
    file_list = {}
    for path, subdirs, files in os.walk(dat_folder):
        for name in files:
            if name.endswith(".dat"):
                if name not in file_list:
                    file_list[name] = []
                file_list[name].append(os.path.join(path, name))
    return file_list

def _run_for_image(file_array):
    imgs = []
    for f in file_array:
        dat = open(f, 'r').read()
        img = bench.convert_dat_to_image(dat, 640, 480)
        imgs.append(img)

    results = []
    for i in range(0, len(imgs)-1):
        for j in range(i+1, len(imgs)):
            results.append(bench.calculate_consistency_error(imgs[i], imgs[j]));

    return results

def _print_results(results):
    higher_gce = 0
    higher_lce = 0
    lower_gce = 2
    lower_lce = 2

    for result in results:
        gce, lce = result
        higher_gce = gce if gce != 0 and gce > higher_gce else higher_gce
        higher_lce = lce if lce != 0 and lce > higher_lce else higher_lce
        lower_gce = gce if gce != 0 and gce < lower_gce else lower_gce
        lower_lce = lce if lce != 0 and lce < lower_lce else lower_lce

    lower_gce = 0 if lower_gce > 1 else lower_gce
    lower_lce = 0 if lower_lce > 1 else lower_lce

    print('%.5f %.5f %.5f %.5f' % (higher_gce, lower_gce, higher_lce, lower_lce))
    # print('FILE: %s' % key)
    # print results

run_benchmark()

# print file_list

# total_gce = 0
# total_lce = 0
# count = 0
# for i in xrange(0, len(file_list)):
#     dat_file = dat_folder + "/" + file_list[i];
#     img_file = seg_folder + "/" + file_list[i][0:-4] + ".ppm"

#     dat = open(dat_file, 'r').read()
#     im_seg = cv2.imread(img_file)
#     height, width, depth = im_seg.shape
#     im_dat = bench.convert_dat_to_image(dat, width, height)

#     e_mseg = bench.find_edges(im_seg)
#     gce, lce = bench.calculate_consistency_error(im_dat, e_mseg);

#     count += 1
#     total_gce += gce
#     total_lce += lce

#     print(img_file+' %.5f %.5f' % (gce, lce))

# print "Average GCE: %.5f" % (total_gce/count)
# print "Average LCE: %.5f" % (total_lce/count)
