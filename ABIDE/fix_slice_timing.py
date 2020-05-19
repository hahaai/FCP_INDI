import json
import os
import numpy as np
import sys

for site in  os.listdir('ABIDE/RawDataBIDS'):
    if site == '.DS_Store':
        continue
    print(site)
    for file in os.listdir('ABIDE/RawDataBIDS/'+site):
        if file == '.DS_Store':
            continue
        if 'json' in file and 'task' in file:
            jsonfile='ABIDE/RawDataBIDS/' + site + '/' + file
            print(jsonfile)
            with open(jsonfile) as f:
                data = json.load(f)
             
                if data.has_key('SliceTiming') and max(data["SliceTiming"]) > 20:
                    data["SliceTiming"] = [x / 1000 for x in data["SliceTiming"]]
                    with open(jsonfile, 'w') as outfile:
                        json.dump(data, outfile,indent = 4)
