import os
import sys

arff_path = sys.argv[1]
output_path = sys.argv[2]

arff_file = open(arff_path, 'r')
lines = arff_file.read().split('\n')

curr_line = 0
classes_declaration = 0

while (lines[curr_line]!='@DATA'):
    if lines[curr_line][:16] == '@ATTRIBUTE class':
        classes_declaration = curr_line
    curr_line += 1
curr_line += 1

header = lines[0:curr_line]
# replace classes declaration to a biclass one
header[classes_declaration] = '@ATTRIBUTE class {target, outlier}'

data = []
for line in lines[curr_line:]:
    if '?' in line:
        continue
    new_line = line
    new_line = new_line.replace('forest', 'target')
    new_line = new_line.replace('water', 'target')
    new_line = new_line.replace('grass', 'target')
    new_line = new_line.replace('dirty', 'target')
    new_line = new_line.replace('human-made', 'outlier')
    data.append(new_line)

output_file = open(output_path, 'w')

for line in header:
    output_file.write('%s\n' % line)
    
for line in data:
    output_file.write('%s\n' % line)

