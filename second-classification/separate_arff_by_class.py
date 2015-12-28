import os
import sys

arff_path = sys.argv[1]

arff_file = open(arff_path, 'r')
content = arff_file.read()
arff_lines = content.split('\n')

header = []
data = {}

# getting header
i = 0
while arff_lines[i] != "@DATA":
    i += 1
i += 1
header = arff_lines[0:i]

# getting content
for line in arff_lines[i:]:
    params = line.split(',')
    sample_class = params[-1]
    if sample_class not in data.keys():
        data[sample_class] = []
    data[sample_class].append(line)

for sample_class in data.keys():
    if sample_class != '?':
        lines = data[sample_class]
        output = open('second-%s.arff' % sample_class, 'w')
        for line in header:
            output.write(line + '\n')
        for line in lines:
            output.write(line + '\n')
