# import os
import sys
import cv2
# import matplotlib.pyplot as plt
# import numpy as np
import bench_common as bench

dat_folder = sys.argv[1]
mseg_folder = "segmentation/mseg/out"
jseg_folder = "segmentation/jseg/out"
meanshift_folder = "segmentation/meanshift/out"
srm_folder = "segmentation/srm/out"

dat_files = bench.load_dat_files(dat_folder)

manual_results = {}
mseg_results = {}
jseg_results = {}
meanshift_results = {}
srm_results = {}


for i, key in enumerate(dat_files.keys()):
    print("%s (%d of %d)" % (key, i, len(dat_files)))
    # MANUAL
    file_count = len(dat_files[key])
    if file_count > 2:
        manual_results[key] = bench.run_validation_for_dats(dat_files[key])

    # MSEG
    img_mseg = cv2.imread(mseg_folder + "/" + key[0:-4] + ".ppm")
    edg_mseg = bench.find_edges(img_mseg)
    mseg_results[key] = bench.run_validation_for_image(edg_mseg, dat_files[key])

    # JSEG
    img_jseg = cv2.imread(jseg_folder + "/" + key[0:-4] + ".jpg", cv2.IMREAD_GRAYSCALE)
    jseg_results[key] = bench.run_validation_for_image(img_jseg, dat_files[key])

    # MEANSHIFT
    img_meanshift = cv2.imread(meanshift_folder + "/" + key[0:-4] + ".pnm", cv2.IMREAD_GRAYSCALE)
    meanshift_results[key] = bench.run_validation_for_image(img_meanshift, dat_files[key])

    # SRM
    img_srm = cv2.imread(srm_folder + "/" + key[0:-4] + ".ppm", cv2.IMREAD_GRAYSCALE)
    img_srm = (255-img_srm)
    srm_results[key] = bench.run_validation_for_image(img_srm, dat_files[key])

bench.render_graphs('manual', 'Segmentacao Manual', manual_results)
print("\nManual")
bench.print_results(manual_results)

bench.render_graphs('mseg', 'MSEG', mseg_results)
print("\nMSEG")
bench.print_results(mseg_results)

bench.render_graphs('jseg', 'JSEG', jseg_results)
print("\nJSEG")
bench.print_results(jseg_results)

bench.render_graphs('meanshift', 'Meanshift', meanshift_results)
print("\nMeanshift")
bench.print_results(meanshift_results)

bench.render_graphs('srm', 'SRM', srm_results)
print("\nSRM")
bench.print_results(srm_results)
