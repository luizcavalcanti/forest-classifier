import cv2
import sys
import bench_common as bench

dat_folder = sys.argv[1]
seg_folder = "segmentation/meanshift/out"

def run_benchmark():
    file_list = bench.load_dat_files(dat_folder)
    all_results = {}
    for key in file_list.keys():
        img_file = seg_folder + "/" + key[0:-4] + ".pnm"
        im_seg = cv2.imread(img_file, cv2.IMREAD_GRAYSCALE)
        results = bench.run_validation_for_image(im_seg, file_list[key])
        all_results[key] = results
    bench.render_graphs('meanshift', 'Meanshift', all_results)
    bench.print_results(all_results)

run_benchmark()