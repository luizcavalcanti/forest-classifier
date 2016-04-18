import sys

param_num = len(sys.argv) - 1

# weight of each class in voting
weights = {
    'forest-ocsvm': 1,
    'forest-ocsvm-cfs': 0,
    'forest-rpt': 0,
    'forest-rpt-cfs': 0,
    'water-ocsvm': 1,
    'water-ocsvm-cfs': 0,
    'water-rpt': 0,
    'water-rpt-cfs': 0,
    'grass-ocsvm': 1,
    'grass-rpt-cfs': 0,
    'grass-rpt': 0,
    'grass-ocsvm-cfs': 0,
    'dirty-ocsvm': 0,
    'dirty-ocsvm-cfs': 1,
    'dirty-rpt': 0,
    'dirty-rpt-cfs': 0
    }

arff_file = open(sys.argv[1],'r')
arff_content = arff_file.read().split('\n')

data = {}
for line in arff_content:
    if len(line) > 0 and line[0] != '@':
        fields = line.split(',')
        sample = fields[0]
        label = fields[-1]
        data[sample] = {}
        data[sample]['label'] = label

for i in range(3, param_num+1):
    result_file = open(sys.argv[i], 'r')
    lines = result_file.read().split('\n')[5:-2]

    # MY EYES!!!!! AAARRRRHHHGGGG
    filename = '-'.join(sys.argv[i].split('/')[-1].split('-')[1:]).split('.')[0]
    for line in lines:
        fields =  line.split()
        sample_id = fields[-1][1:-1]
        label = fields[1].split(':')[1]
        if 'target' in fields[2]:
            value = float(fields[-2])
        else:
            value = float(0)
        if sample_id not in data:
            data[sample_id] = {}
        data[sample_id][filename] = value * weights[filename]

for sample in data.values():
    winner = max(sample['forest-ocsvm'], sample['forest-rpt'], sample['forest-ocsvm-cfs'], sample['forest-rpt-cfs'],
                 sample['water-ocsvm'], sample['water-rpt'], sample['water-ocsvm-cfs'], sample['water-rpt-cfs'],
                 sample['grass-ocsvm'], sample['grass-rpt'], sample['grass-ocsvm-cfs'], sample['grass-rpt-cfs'], 
                 sample['dirty-ocsvm'], sample['dirty-rpt'], sample['dirty-ocsvm-cfs'], sample['dirty-rpt-cfs'])
    winner_class = ''
    for key in sample.keys():
        if sample[key] == winner:
            winner_class = key
            break
    if winner == 0:
        sample['prediction'] = 'human-made'
    else:
        sample['prediction'] = winner_class

hm_fntp = len([data[x] for x in data if data[x]['label'] == 'human-made'])
hm_tpfp = len([data[x] for x in data if data[x]['prediction'] == 'human-made'])
hm_tp = len([data[x] for x in data if (data[x]['label'] == 'human-made' and data[x]['prediction'] == 'human-made')])
hm_fp = [data[x]['label'] for x in data if (data[x]['label'] != 'human-made' and data[x]['prediction'] == 'human-made')]
hm_fn = [data[x]['prediction'] for x in data if (data[x]['label'] == 'human-made' and data[x]['prediction'] != 'human-made')]

hm_precision = float(hm_tp)/float(hm_tpfp)
hm_recall = float(hm_tp)/float(hm_fntp)
hm_f1 = 2*((hm_precision*hm_recall)/(hm_precision+hm_recall))

print("\nRESULTS:")
print("total human-made samples: %d" % hm_fntp)
print("total human-made preditions: %d" % hm_tpfp)
print("correct human-made preditions: %d" % hm_tp)
print("-----------------------------------------")
print("human-made precision: %f" % hm_precision)
print("human-made recall: %f" % hm_recall)
print("human-made F1 measure: %f" % hm_f1)
# print("False positives: ")
# print(hm_fp)
# print("False negatives: ")
# print(hm_fn)

## generate output file
csv_content = 'id'#'id,label,forest,water,dirty,grass,human-made'
for label in data['1'].keys():
    csv_content += ',' + label

for key in data.keys():
    line = key
    for label in data['1'].keys():
        line += ',' + str(data[key][label])
    csv_content += '\n'+line

output = open(sys.argv[2], 'w')
output.write(csv_content)
