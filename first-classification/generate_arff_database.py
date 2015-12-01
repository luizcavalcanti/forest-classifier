import os
import sys

samples_dir = sys.argv[1]
arff_file = sys.argv[2]

def load_image_files(img_folder):
    file_list = {}
    for path, subdirs, files in os.walk(img_folder):
        for name in files:
            if name.endswith(".ppm"):
                key = name[0:-4]
                file_list[key] = {}
                file_list[key]['image_file'] = os.path.join(path, key+'.jpg')
    return file_list

def get_header():
    header = ""
    header += '@RELATION amazon\n\n'
    header += '@ATTRIBUTE id string\n'
    header += '@ATTRIBUTE class {forest,water,grass,dirty,man-made}\n'
    header += '\n'
    header += '@DATA\n'
    return header

output_file = open(arff_file, "w")
output_file.write(get_header())
files = load_image_files(samples_dir)
for key in files.keys():
    f = files[key]
    output_file.write("\'%s\',?\n" % key)
output_file.close()