import os
import sys
import matplotlib.pyplot as plt
import numpy as np
import bench_common as bench

dat_folder = sys.argv[1]

def run_benchmark():
    file_list = _load_files()
    all_results = {}
    for key in file_list:
        file_count = len(file_list[key])
        if file_count > 2:
            results = _run_for_image(file_list[key])
            all_results[key] = results
    _render_graphs(all_results)

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

def _render_graphs(results):
    gces = []
    lces = []
    for image_file in results.keys():
        for result in results[image_file]:
            gces.append(result[0])
            lces.append(result[1])

    plt.hist(gces, histtype='stepfilled', color='b', edgecolor='none', bins=100)
    plt.xlim([0,0.2])
    plt.title('Segmentacao Manual - GCE')
    plt.ylabel('Imagens')
    plt.xlabel('Erro')
    plt.savefig("results/manual_gce.jpg")
    plt.close()

    plt.hist(lces, histtype='stepfilled', color='b', edgecolor='none', bins=100)
    plt.xlim([0,0.2])
    plt.title('Segmentacao Manual - LCE')
    plt.ylabel('Imagens')
    plt.xlabel('Erro')
    plt.savefig("results/manual_lce.jpg")
    plt.close()

    flat_gces = []
    flat_lces = []
    for key in results.keys():
        flat_gces.append(results[key][0])
        flat_lces.append(results[key][1])

    plt.boxplot(flat_gces, showfliers=False)
    plt.ylim([0,1])
    plt.xticks(np.arange(len(flat_gces), 10))
    plt.title('Segmentacao Manual - GCE')
    plt.xlabel('Imagens')
    plt.ylabel('Erro')
    plt.savefig("results/manual_dist_gce.jpg")
    plt.close()

    plt.boxplot(flat_lces, showfliers=False)
    plt.ylim([0,1])
    plt.xticks(np.arange(len(flat_gces), 10))
    plt.title('Segmentacao Manual - LCE')
    plt.xlabel('Imagens')
    plt.ylabel('Erro')
    plt.savefig("results/manual_dist_lce.jpg")
    plt.close()

run_benchmark()

