import json
import os
import numpy as np
import sys

datain='/data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/RawData'
datain='/data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS'
for site in  os.listdir(datain):
    if site == '.DS_Store':
        continue
    print(site)
    for file in os.listdir(datain + '/' + site):
        if file == '.DS_Store':
            continue
        if 'json' in file and 'task' in file:
            jsonfile=datain + '/' + site + '/' + file
            print(jsonfile)
            with open(jsonfile) as f:
                data = json.load(f)
             
                if data.has_key('SliceTiming') and max(data["SliceTiming"]) > 200:
                    if data["SliceTiming"] =='n/a':
                        del data["SliceTiming"]
                    else:
                        data["SliceTiming"] = [x / 1000 for x in data["SliceTiming"]]
                        with open(jsonfile, 'w') as outfile:
                            json.dump(data, outfile,indent = 4)

