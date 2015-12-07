import os
import sys

samples_dir = sys.argv[1]
arff_file = sys.argv[2]

def load_image_files(img_folder):
    file_list = []
    for path, subdirs, files in os.walk(img_folder):
        for name in files:
            if name.endswith(".ppm") and not name.endswith('_mask.ppm'):
                key = name[0:-4]
                file_list.append(key)
    return file_list

def get_header():
    header = ""
    header += '@RELATION amazon\n\n'
    header += '@ATTRIBUTE id string\n'
    header += '@ATTRIBUTE class {forest,water,grass,dirty,human-made}\n'
    header += '\n'
    header += '@DATA'
    return header

print('Generating arff file...')
output_file = open(arff_file, "w")
output_file.write(get_header())
files = load_image_files(samples_dir)
for key in files:
    output_file.write("\n")
    output_file.write("\'%s\'," % (key))
    output_file.write("?")
output_file.close()