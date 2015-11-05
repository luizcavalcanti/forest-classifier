import cv2
import sys
import bench_common as bench

dat_folder = sys.argv[1]
seg_folder = "segmentation/mseg/out"

def run_benchmark():
    file_list = bench.load_dat_files(dat_folder)
    all_results = {}
    for key in file_list.keys():
        img_file = seg_folder + "/" + key[0:-4] + ".ppm"
        im_seg = cv2.imread(img_file)
        e_mseg = bench.find_edges(im_seg)
        results = bench.run_validation_for_image(e_mseg, file_list[key])
        all_results[key] = results
    bench.render_graphs('mseg', 'MSEG', all_results)
    bench.print_results(all_results)

run_benchmark()