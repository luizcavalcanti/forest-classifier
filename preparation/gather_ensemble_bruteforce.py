import sys

param_num = len(sys.argv) - 1

# weight of each class in voting
weights = {
    'forest-ocsvm': 0,
    'forest-ocsvm-cfs': 0,
    'forest-rpt': 0,
    'forest-rpt-cfs': 0,
    'water-ocsvm': 0,
    'water-ocsvm-cfs': 0,
    'water-rpt': 0,
    'water-rpt-cfs': 0,
    'grass-ocsvm': 0,
    'grass-rpt-cfs': 0,
    'grass-rpt': 0,
    'grass-ocsvm-cfs': 0,
    'dirty-ocsvm': 0,
    'dirty-ocsvm-cfs': 0,
    'dirty-rpt': 0,
    'dirty-rpt-cfs': 0
    }

get_bin = lambda x, n: format(x, 'b').zfill(n)

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

csv_content = 'combination,precision,recall,f1\n'
mask_size = len(weights)
for i in range(2**mask_size):

    # set weights
    mask = get_bin(i, mask_size)
    print(mask)

    j = 0
    for m in mask:
        weigth_key = weights.keys()[j]
        weights[weigth_key] = int(m)
        j += 1


    for k in range(3, param_num+1):
        result_file = open(sys.argv[k], 'r')
        lines = result_file.read().split('\n')[5:-2]

        filename = '-'.join(sys.argv[k].split('/')[-1].split('-')[1:]).split('.')[0]
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

    # run experiment
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

    # collect results
    hm_fntp = len([data[x] for x in data if data[x]['label'] == 'human-made'])
    hm_tpfp = len([data[x] for x in data if data[x]['prediction'] == 'human-made'])
    hm_tp = len([data[x] for x in data if (data[x]['label'] == 'human-made' and data[x]['prediction'] == 'human-made')])
    hm_fp = [data[x]['label'] for x in data if (data[x]['label'] != 'human-made' and data[x]['prediction'] == 'human-made')]
    hm_fn = [data[x]['prediction'] for x in data if (data[x]['label'] == 'human-made' and data[x]['prediction'] != 'human-made')]

    if hm_tpfp == 0:
        hm_precision = 0
    else:
        hm_precision = float(hm_tp)/float(hm_tpfp)

    if hm_fntp == 0:
        hm_recall = 0
    else:
        hm_recall = float(hm_tp)/float(hm_fntp)

    if (hm_precision + hm_recall) == 0:
        hm_f1 = 0
    else:
        hm_f1 = 2*((hm_precision*hm_recall)/(hm_precision+hm_recall))

    ## generate output file
    csv_content += '%s,%f,%f,%f\n' % (weights, hm_precision, hm_recall, hm_f1)
    
output = open(sys.argv[2], 'w')
output.write(csv_content)