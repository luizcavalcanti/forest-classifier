import sys

param_num = len(sys.argv) - 1
data = {}

w_forest = 1.5
w_water = 1.1
w_dirty = 1.1
w_grass = 1
w_humanmade = 2

arff_file = open(sys.argv[1],'r')
arff_content = arff_file.read().split('\n')
for line in arff_content:
    if len(line) > 0 and line[0] != '@':
        fields = line.split(',')
        sample = fields[0][1:-1]
        label = fields[-1]
        data[sample] = {}
        data[sample]['label'] = label

for i in range(2, param_num+1):
    result_file = open(sys.argv[i], 'r')
    lines = result_file.read().split('\n')[5:-2]

    filename = sys.argv[i].split('/')[-1].split('-')[-1].split('.')[0]

    for line in lines:
        fields =  line.split()
        sample_id = fields[-1][1:-1]
        label = fields[1].split(':')[1]
        if 'target' in fields[2]:
            value = float(fields[-2])
        else:
            value = float(0)
        data[sample_id][filename] = value

## generate output file
csv_content = 'id,label,forest,water,dirty,grass,human-made'

for key in data.keys():
    label = data[key]['label']
    forest = data[key]['forest'] * w_forest
    water = data[key]['water'] * w_water
    dirty = data[key]['dirty'] * w_dirty
    grass = data[key]['grass'] * w_grass
    humanmade = data[key]['made'] * w_humanmade
    csv_content += '\n%s,%s,%s,%s,%s,%s,%s' % (key,label,forest,water,dirty,grass,humanmade)

print(csv_content)
