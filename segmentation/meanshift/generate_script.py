import os

# EDS script template
tf = open('model.eds', 'r')
template = tf.read()
tf.close()

# (re)creating EDS script to be created/inflated
temp_path = 'out/temp.eds'
temp_script = open(temp_path, 'w')

for dirname, dirnames, filenames in os.walk('out/images'):
    for filename in filenames:
        filepath = os.path.join(dirname, filename)
        output = os.path.join('out/segment', filename.replace(".ppm", ".pnm"))
        entry = template.replace("$IMAGE_PATH", filepath);
        entry = entry.replace("$OUTPUT_PATH", output);
        temp_script.write(entry)

# Closing eds files
temp_script.close()