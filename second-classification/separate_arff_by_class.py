import os
import sys

results_path = sys.argv[1]

results_file = open(results_path, 'r')
content = results_file.read()
lines = content.split('\n')[5:-2] #remove stupid empty or header lines

data = {}
for line in lines:
    cols = line.split()
    classname = cols[2].split(':')[1]
    id = cols[-1].replace('(', '').replace(')', '')
    if classname not in data.keys():
        data[classname] = []
    data[classname].append(id)

for key in data.keys():
    output = open('second-%s.dat' % key, 'w')
    for entry in data[key]:
        output.write('%s\n' % entry)
    output.close()
