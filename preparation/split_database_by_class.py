import os
import sys

arff_path = sys.argv[1]
basename = sys.argv[2]

arff_file = open(arff_path, 'r')
lines = arff_file.read().split('\n')

curr_line = 0
classes_declaration = 0

while (lines[curr_line]!='@data'):
    if lines[curr_line][:16] == '@attribute class':
        classes_declaration = curr_line
    curr_line += 1
curr_line += 1

header = lines[0:curr_line]
# replace classes declaration for a unary class
header[classes_declaration] = '@ATTRIBUTE class {target,outlier}'

data = {}
for line in lines[curr_line:]:
    classname = line.split(',')[-1]
    if len(line) < 1 or classname == '?':
        continue
    if classname not in data.keys():
        data[classname] = []
    if classname == 'human-made':
        new_line = line.replace(classname, 'outlier')
    else:
        new_line = line.replace(classname, 'target')
    data[classname].append(new_line)

for key in data.keys():
    output_file = open('%s-%s.arff' % (basename, key), 'w')
    for line in header:
        output_file.write('%s\n' % line)
    for line in data[key]:
        output_file.write('%s\n' % line)
    for line in data['human-made']:
        output_file.write('%s\n' % line)
