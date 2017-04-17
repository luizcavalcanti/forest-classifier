import os
import sys
import pandas as pd

samples_dir = sys.argv[1]
csv_file = sys.argv[2]

def load_image_files(img_folder):
    file_list = []
    for path, subdirs, files in os.walk(img_folder):
        for name in files:
            if name.endswith(".ppm") and not name.endswith('_mask.ppm'):
                key = name[0:-4]
                file_list.append(key)
    return file_list

print('Loading images...')
files = load_image_files(samples_dir)

print('Generating dataframe file...')
data = {}

df = pd.DataFrame(columns=['id', 'class'])
for key in files:
    df.loc[df.size] = [key, '?']

df.to_csv(csv_file)
