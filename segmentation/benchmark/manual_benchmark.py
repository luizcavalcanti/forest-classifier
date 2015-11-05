import os
import sys
import matplotlib.pyplot as plt
import numpy as np
import bench_common as bench

dat_folder = sys.argv[1]

def run_benchmark():
    file_list = bench.load_dat_files(dat_folder)
    all_results = {}
    for key in file_list.keys():
        file_count = len(file_list[key])
        if file_count > 2:
            results = _run_for_image(file_list[key])
            all_results[key] = results
    bench.render_graphs('manual', 'Segmentacao Manual', all_results)
    bench.print_results(all_results)

def _run_for_image(file_array):
    imgs = []
    for f in file_array:
        dat = open(f, 'r').read()
        img = bench.convert_dat_to_image(dat, 640, 480)
        imgs.append(img)

    results = []
    lces = []
    gces = []
    for i in range(0, len(imgs)-1):
        for j in range(i+1, len(imgs)):
            gce, lce = bench.calculate_consistency_error(imgs[i], imgs[j])
            gces.append(gce)
            lces.append(lce)

    results.append(gces)
    results.append(lces)
    return results

run_benchmark()