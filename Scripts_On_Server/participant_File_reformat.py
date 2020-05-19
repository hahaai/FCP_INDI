### 5/20
import os
import sys
import pandas as pd
import numpy as np

folder='All_New_May_2020/ABIDE/RawDataBIDS'
for site in os.listdir(folder):
    if site == ".DS_Store":
        continue
    print(site)
    file=folder + '/' + site + '/participants_orig.tsv'
    #file='All_New_May_2020/ABIDE/RawDataBIDS/Caltech/participants_orig.tsv'
    df=pd.read_csv(file,sep='\t')
    df.to_csv(folder + '/' + site + '/participants.tsv',sep='\t',na_rep='n/a',index=False)