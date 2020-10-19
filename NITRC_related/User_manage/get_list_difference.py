import pandas as pd
pub=pd.read_csv('Public_User_list.txt',sep="(",header=None, names=['Name','ID'])
pub.ID=pub.ID.str.replace(')','')
pub['Name']=pub['Name'].str.strip(' ')

lastname=[]
for i in pub['Name']:
    i=str(i)
    ii=i.split(' ')
    lastname.append(ii[-1])
pub['Last_Name']=lastname



pri=pd.read_csv('Private_User_list.txt',sep="(",header=None, names=['Name','ID'])
pri.ID=pri.ID.str.replace(')','')
pri['Name']=pri['Name'].str.strip(' ')

lastname=[]
for i in pri['Name']:
    i=str(i)
    ii=i.split(' ')
    lastname.append(ii[-1])
pri['Last_Name']=lastname



# user in the pub, but not in the pri
for i in range(0,pub.shape[0]):
    id1=pub['ID'][i]
    s = 0
    for id2 in pri['ID']:
        if id1 == id2:
            s=1
            continue
    if s==0:
        print(id1 + ',' + pub['Last_Name'][i])
