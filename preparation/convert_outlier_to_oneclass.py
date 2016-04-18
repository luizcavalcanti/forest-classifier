import os
import sys

arff_path = sys.argv[1]
output_path = sys.argv[2]

arff_file = open(arff_path, 'r')
lines = arff_file.read().split('\n')

data = []
for line in lines:
    new_line = line
    new_line = new_line.replace('outlier}', '}')
    new_line = new_line.replace('outlier', '?')
    data.append(new_line)

output_file = open(output_path, 'w')

for line in data:
    output_file.write('%s\n' % line)