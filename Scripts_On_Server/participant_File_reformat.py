### 5/20
import os
import sys
import pandas as pd
import numpy as np

folder='/data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS'
for site in ['MRN']:
    if site == ".DS_Store":
        continue
    print(site)
    file=folder + '/' + site + '/participants.tsv'
    #file='All_New_May_2020/ABIDE/RawDataBIDS/Caltech/participants_orig.tsv'
    df=pd.read_csv(file,sep='\t')
    df.to_csv(folder + '/' + site + '/participants.tsv',sep='\t',na_rep='n/a',index=False)
