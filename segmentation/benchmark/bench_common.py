import math
import os
import cv2 as cv
import numpy as np
import matplotlib.pyplot as plt

def load_dat_files(dat_folder):
    file_list = {}
    for path, subdirs, files in os.walk(dat_folder):
        for name in files:
            if name.endswith(".dat"):
                if name not in file_list:
                    file_list[name] = []
                file_list[name].append(os.path.join(path, name))
    return file_list

def find_edges(image):
    return cv.Canny(image, 0, 10)

def run_validation_for_image(original_image, dat_array):
    height, width = original_image.shape
    imgs = []
    for f in dat_array:
        dat = open(f, 'r').read()
        img = __convert_dat_to_image(dat, width, height)
        imgs.append(img)

    results = []
    lces = []
    gces = []
    for dat_img in imgs:
        gce, lce = __calculate_consistency_error(original_image, dat_img)
        gces.append(gce)
        lces.append(lce)

    results.append(gces)
    results.append(lces)
    return results

def run_validation_for_dats(file_array):
    imgs = []
    for f in file_array:
        dat = open(f, 'r').read()
        img = __convert_dat_to_image(dat, 640, 480)
        imgs.append(img)

    results = []
    lces = []
    gces = []
    for i in range(0, len(imgs)-1):
        for j in range(i+1, len(imgs)):
            gce, lce = __calculate_consistency_error(imgs[i], imgs[j])
            gces.append(gce)
            lces.append(lce)

    results.append(gces)
    results.append(lces)
    return results

def render_graphs(identifier, title, results):
    gces = []
    lces = []
    for image_file in results.keys():
        result = results[image_file]
        if sum(result[0]) > 0:
            gces += result[0]
            lces += result[1]

    plt.hist(gces, color='r', histtype='stepfilled', edgecolor='none')
    plt.xlim([0,1])
    plt.title('%s - GCE' % title)
    plt.ylabel('Imagens')
    plt.xlabel('Erro')
    plt.savefig("results/%s_dist_gce.jpg" % identifier)
    plt.close()

    plt.hist(lces, color='r', histtype='stepfilled', edgecolor='none')
    plt.xlim([0,1])
    plt.title('%s - LCE' % title)
    plt.ylabel('Imagens')
    plt.xlabel('Erro')
    plt.savefig("results/%s_dist_lce.jpg" % identifier)
    plt.close()

    flat_gces = []
    flat_lces = []
    for key in results.keys():
        if sum(results[key][0]) > 0:
            flat_gces.append(results[key][0])
            flat_lces.append(results[key][1])

    plt.boxplot(flat_gces, showfliers=False)
    plt.ylim([0,1])
    plt.xticks(np.arange(len(flat_gces), 10))
    plt.title('%s - GCE (var.)' % title)
    plt.xlabel('Imagens')
    plt.ylabel('Erro')
    plt.savefig("results/%s_range_gce.jpg" % identifier)
    plt.close()

    plt.boxplot(flat_lces, showfliers=False)
    plt.ylim([0,1])
    plt.xticks(np.arange(len(flat_gces), 10))
    plt.title('%s - LCE (var.)' % title)
    plt.xlabel('Imagens')
    plt.ylabel('Erro')
    plt.savefig("results/%s_range_lce.jpg" % identifier)
    plt.close()

def print_results(results):
    total_gce = 0
    total_lce = 0
    avg_gce = 0
    avg_lce = 0
    var_gce = 0
    var_lce = 0
    count = 0
    for key in results.keys():
        if sum(results[key][0]) > 0:
            total_gce += sum(results[key][0])
            total_lce += sum(results[key][1])
            count += len(results[key][0])

    avg_gce = (total_gce/count)
    avg_lce = (total_lce/count)

    for key in results.keys():
        if sum(results[key][0]) > 0:
            for result in results[key][0]:
                var_gce += (result - avg_gce)**2
                var_lce += (result - avg_lce)**2

    var_gce = var_gce / count;
    var_lce = var_lce / count;

    print "GCE\nAverage: %.5f\nVariance: %.5f\nStandard deviation: %.5f" % (avg_gce, var_gce, math.sqrt(var_gce))
    print "LCE\nAverage: %.5f\nVariance: %.5f\nStandard deviation: %.5f" % (avg_lce, var_lce, math.sqrt(var_lce))

def __convert_dat_to_image(dat, width, height):
    lines = dat.split('\n')
    regions = int(lines[0])
    image = np.zeros((height, width, 1), np.uint8)

    for i in range(1,regions+1):
        index = (2*i)
        region_type = lines[index-1]
        data = lines[index].replace('[','')
        data = data.replace(']', ' ')
        coords = data.split(' ')
        if region_type == 'cr': # Closed region
            start = coords[0].split(',')
            end = coords[len(coords)-2].split(',')
            __draw_region_on_image(image, coords)
            cv.line(image, (int(end[0]), int(end[1])), (int(start[0]), int(start[1])), (255,255,255),1)
        elif region_type == 'pt': # Path/Stroke
            __draw_region_on_image(image, coords)
    return image

def __draw_region_on_image(image, coords):
    for c in range(0, len(coords)-2):
        c1 = coords[c].split(',')
        c2 = coords[c+1].split(',')
        cv.line(image, (int(c1[0]), int(c1[1])), (int(c2[0]), int(c2[1])), (255,255,255),1)

def __compare_segmentations(img_a, img_b):
    # image, contours, hierarchy = cv.findContours(image, mode, method[, contours[, hierarchy[, offset]]]) [opencv3]
    # contours, hierarchy = cv.findContours(image, mode, method[, contours[, hierarchy[, offset]]]) [opencv2]
    out_img_a, ct_img_a, h_a = cv.findContours(img_a, cv.RETR_TREE, cv.CHAIN_APPROX_NONE)
    out_img_b, ct_img_b, h_b = cv.findContours(img_b, cv.RETR_TREE, cv.CHAIN_APPROX_NONE)

    error = []

    height, width = img_a.shape[:2]

    for comp_a in ct_img_a:

        mask_a = np.zeros((height, width), np.uint8)
        mask_b = np.zeros((height, width), np.uint8)

        first_point = comp_a[0][0]

        cv.fillConvexPoly(mask_a, comp_a, (255))

        for comp_b in ct_img_b:
            if cv.pointPolygonTest(comp_b, (first_point[0], first_point[1]), False) >= 0:
                cv.fillConvexPoly(mask_b, comp_b, (50))
                break

        set_difference = mask_a - mask_b
        set_difference_count = (set_difference == 255).sum()

        error.append(set_difference_count)

    return error

def __calculate_consistency_error(img_a, img_b):
    height, width = img_a.shape[:2]

    error_ab = __compare_segmentations(img_a, img_b)
    error_ba = __compare_segmentations(img_b, img_a)

    sz_ab = len(error_ab)
    sz_ba = len(error_ba)

    if sz_ab == 0 or sz_ba == 0:
        global_error = 0
        local_error = 0
    else:
        if sz_ab > sz_ba:
            error_ba = np.pad(error_ba, (0, sz_ab - sz_ba), 'constant', constant_values=(1))
        elif sz_ab < sz_ba:
            error_ab = np.pad(error_ab, (0, sz_ba - sz_ab), 'constant', constant_values=(1))

        overall_min = np.minimum(error_ab, error_ba)
        global_error = float(1)/float(width*height) * min(sum(error_ba), sum(error_ab))
        local_error = float(1)/float(width*height) * sum(overall_min)

    return (global_error, local_error)