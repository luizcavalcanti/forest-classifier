import os
import sys

arff_path = sys.argv[1]
basename = sys.argv[2]

arff_file = open(arff_path, 'r')
lines = arff_file.read().split('\n')

curr_line = 0
classes_declaration = 0

while (lines[curr_line].upper() != '@DATA'):
    if lines[curr_line][:16].upper() == '@ATTRIBUTE CLASS':
        classes_declaration = curr_line
    curr_line += 1
curr_line += 1

header = lines[0:curr_line]
# replace classes declaration for a unary class
header[classes_declaration] = '@ATTRIBUTE class {target}'

classes = ['forest', 'water', 'grass', 'dirty', 'human-made']
data = {}

for cls in classes:
    data[cls] = []
    for line in lines[curr_line:]:
        if len(line) == 0:
            continue
        new_line = line.replace(cls, 'target')
        if 'target' not in new_line:
            other_class = new_line.split(',')[-1]
            new_line = new_line.replace(other_class, '?')
        data[cls].append(new_line)

for key in data.keys():
    output_file = open('%s-%s.arff' % (basename, key), 'w')
    for line in header:
        output_file.write('%s\n' % line)
    for line in data[key]:
        output_file.write('%s\n' % line)
