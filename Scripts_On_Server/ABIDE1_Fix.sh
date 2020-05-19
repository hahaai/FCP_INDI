## download the dataset
aws s3 sync s3://fcp-indi/data/Projects/ABIDE/RawDataBIDS /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS


datain='/data3/cdb/FCP_INDI/FIX_Dataset/ABIDE'
bids_info='/data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/Validate_infor_final'
mkdir -p $bids_info
for site in $(ls $datain'/RawDataBIDS');do
    echo $site
    docker run -ti --rm -v $datain'/RawDataBIDS/'$site:/data:ro bids/validator:v1.4.2 /data >> $bids_info'/'$site'.txt'
done



#### Fix Leuven_1 and Leuven_2 repitition not consistent problem, creat indivisual TR.
datain='/data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS'
dataout='/data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS_Fix'
for site in Leuven_1 Leuven_2;do
    echo $site
    for i in $(find $datain'/'$site -iname '*bold.nii.gz*');do
        echo $i 
        i_json=${i/.nii.gz/.json}
        #i_json=${i_json/$datain/$dataout}
        echo $i_json
        mkdir -p $(dirname $i_json)
        echo { >> $i_json
        echo '    "RepetitionTime": '$(3dinfo -tr $i) >> $i_json
        echo } >> $i_json
    done
done

# Leuven_1 one func not match TR
aws s3 cp s3://fcp-indi/data/Projects/ABIDE/RawData/Leuven_1/0050702/session_1/rest_1/rest.nii.gz /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS/Leuven_1/sub-0050702/func/sub-0050702_task-rest_run-1_bold.nii.gz

# bids validator
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS/Leuven_1:/data:ro bids/validator:v1.4.2 /data
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS/Leuven_1:/data:ro bids/validator:v1.4.2 /data


### Pitt
#aws s3 cp s3://fcp-indi/data/Projects/ABIDE/RawData/Pitt/0050049/session_1/anat_1/mprage.nii.gz /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS/Pitt/sub-0050049/anat/sub-0050049_T1w.nii.gz
# /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS/Pitt/sub-0050049/anat/sub-0050049_T1w.nii.gz is empty, downloaded from the RawData folder


### OHSU sub-0050170/func/sub-0050170_task-rest_run-1_bold.nii.gz is empty
aws s3 cp s3://fcp-indi/data/Projects/ABIDE/RawData/OHSU/0050170/session_1/rest_1/rest.nii.gz /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS/OHSU/sub-0050170/func/sub-0050170_task-rest_run-1_bold.nii.gz




### update the S3
aws s3 sync /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS s3://fcp-indi/data/Projects/ABIDE/RawDataBIDS --acl public-read --profile FCP-INDI --dryrun

aws s3 sync /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE/RawDataBIDS s3://fcp-indi/data/Projects/ABIDE/RawDataBIDS --acl public-read --profile FCP-INDI
