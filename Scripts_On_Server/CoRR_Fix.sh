aws s3 sync s3://fcp-indi/data/Projects/CORR/RawDataBIDS /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS --exclude "*derivative*"

# bids validate

datain='/data3/cdb/FCP_INDI/FIX_Dataset/CORR'
bids_info='/data3/cdb/FCP_INDI/FIX_Dataset/CORR/Validate_infor_1'
mkdir -p $bids_info
for site in $(ls $datain'/RawDataBIDS');do
    echo $site
    docker run -ti --rm -v $datain'/RawDataBIDS/'$site:/data:ro bids/validator:v1.4.2 /data >> $bids_info'/'$site'.txt'
done



#copy a dataset_description file to site folder, this need to be changed individually.
# need to replace the site name.
## sed is different in mac os and linux.
sample=/data3/cdb/FCP_INDI/FIX_Dataset/CORR/dataset_description.json
datain='/data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS'
for i in $(ls $datain);do 
    cp $sample $datain'/'$i/.
    sed -i 's/XXXXXX/'$i'/g' $datain'/'$i'/dataset_description.json'
done


### fix the slice timing unit problem by running
python /data3/cdb/FCP_INDI/FIX_Dataset/Scripts/fix_slice_timing.py

############## Fix individual sites:

# BNU_2 - done
# the json files defined in the top level and not the right name, problem is it has two sessions. Cope the json files into each session
func1='/data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/BNU_2/ses-1_task-rest_bold.json'
func2='/data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/BNU_2/ses-2_task-rest_bold.json'
anat1='/data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/BNU_2/ses-1_T1w.json'
anat2='/data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/BNU_2/ses-2_T1w.json'
datain='/data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/BNU_2'
for i in $(find $datain -iname '*bold.nii.gz*');do
    if [[ $i == *"ses-1"* ]];then
        cp $func1 ${i/.nii.gz/.json}
    fi
    if [[ $i == *"ses-2"* ]];then
        cp $func2 ${i/.nii.gz/.json}
    fi
done

# anat
for i in $(find $datain -iname '*T1w.nii.gz*');do
    if [[ $i == *"ses-1"* ]];then
        cp $anat1 ${i/.nii.gz/.json}
    fi
    if [[ $i == *"ses-2"* ]];then
        cp $anat2 ${i/.nii.gz/.json}
    fi
done

docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/BNU_2:/data:ro bids/validator:v1.4.2 /data

# HNU_1 - done
# has asl cbf folder, put them into ta .bidsignore file
echo */*/asl >> /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/HNU_1/.bidsignore
echo */*/cbf >> /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/HNU_1/.bidsignore

docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/HNU_1:/data:ro bids/validator:v1.4.2 /data


# IBA_TRT - done
# Repetition time not match
# has some behavior.txt and logfile.txt in the func folder
datain='/data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS'
for site in IBA_TRT;do
    echo $site
    for i in $(find $datain'/'$site -iname '*bold.nii.gz*');do
        echo $i 
        tr=$(3dinfo -tr $i)
        i_json=${i/.nii.gz/.json}
        echo $i_json
        echo { >> $i_json
        echo '    "RepetitionTime": '${tr:0:5} >> $i_json
        echo } >> $i_json
    done
done
echo */*/func/*.txt >> /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/IBA_TRT/.bidsignore

docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/IBA_TRT:/data:ro bids/validator:v1.4.2 /data

# IPCAS_3 - done
# some func files doen't have TR in the herader.
for i in $(find /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/IPCAS_3 -iname '*bold.nii.gz*'); do 
    tr=$(3dinfo -tr $i);
    if [[ $tr == '1.000000' ]];then 
        echo $i; 3drefit -TR 2 $i; 
    fi;
done
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/IPCAS_3:/data:ro bids/validator:v1.4.2 /data


# LMU_1 - done
# some func files doen't have TR in the herader.
for i in $(find /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/LMU_1 -iname '*bold.nii.gz*'); do 
    tr=$(3dinfo -tr $i);
    if [[ $tr == '42.500000' ]];then 
        echo $i; 
        3drefit -TR 2.5 $i; 
    fi;
done
# also this one's TR is 2.49, change to 2.5
3drefit -TR 2.5 /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/LMU_1/sub-0025359/ses-1/func/sub-0025359_ses-1_task-rest_run-6_bold.nii.gz

docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/LMU_1:/data:ro bids/validator:v1.4.2 /data



# LMU_2 - done
# some func files doen't have TR in the herader.
for i in $(find /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/LMU_2 -iname '*bold.nii.gz*'); do 
    tr=$(3dinfo -tr $i);
    if [[ $tr != '3.000000' ]];then 
        echo $i; 
        echo $tr
        3drefit -TR 3 $i; 
    fi;
done
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/LMU_2:/data:ro bids/validator:v1.4.2 /data


# MRN - done
# tsv file chagned by participant_file_reformat.py
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/MRN:/data:ro bids/validator:v1.4.2 /data


# NKI_TRT - done
rm /data3/cdb/FCP_INDI/FIX_Dataset/CORR/tmp.txt
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/NKI_TRT:/data:ro bids/validator:v1.4.2 /data --verbose >> /data3/cdb/FCP_INDI/FIX_Dataset/CORR/tmp.txt
# one of json file named incorrectly.
# change task-breathholding_acq-tr1400ms_bold.json to task-breathhold_acq-tr1400ms_bold.json
# Slice timing are larger than the TR in most json file. deleted slice timing form it. put the old files in a zip file, bids ignore the zip file.
echo Old_bold.json.tar.gz >> /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/NKI_TRT/.bidsignore


# SWU_4  - done
# ./sub-0025754/ses-1/dwi/sub-0025754_ses-1_run-1_dwi.nii.gz does not have bvec and bval, put in into ignorefile
echo '# the dwi file does not have  bval and bvec file'>> /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/SWU_4/.bidsignore
echo sub-0025754/ses-1/dwi/sub-0025754_ses-1_run-1_dwi.nii.gz >> /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/SWU_4/.bidsignore
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/SWU_4:/data:ro bids/validator:v1.4.2 /data


# UM - done
# TR not match, some nifti headers have empty tr and give it 1. mri_info can check. 
for i in $(find /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/UM -iname '*bold.nii.gz*'); do 
    tr=$(3dinfo -tr $i);
    if [[ $tr != '2.000000' ]];then 
        echo $i; 
        echo $tr
        3drefit -TR 2 $i; 
    fi;
done
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/UM:/data:ro bids/validator:v1.4.2 /data


# 


# MPG_1
for i in $(find /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/MPG_1 -iname '*bold.nii.gz*'); do 
    tr=$(3dinfo -tr $i);
    if [[ $tr != 'a3.000000' ]];then 
        echo $i; 
        echo $tr
        #3drefit -TR 3 $i; 
    fi;
done





## update the S3 bucket
aws s3 sync /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/RawData s3://fcp-indi/data/Projects/ABIDE2/RawData --acl public-read --profile FCP-INDI --dryrun




###########3
rm /data3/cdb/FCP_INDI/FIX_Dataset/CORR/tmp.txt
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/CORR/RawDataBIDS/LMU_1:/data:ro bids/validator:v1.4.2 /data --verbose >> /data3/cdb/FCP_INDI/FIX_Dataset/CORR/tmp.txt