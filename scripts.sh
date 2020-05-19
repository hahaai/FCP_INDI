cd /Users/lei.ai/Dropbox/Work&Study/projects/AWS_INDI_Bucket_Clean/All_New_May_2020

### some usuafull command
## get the site cars
#aws s3 sync s3://fcp-indi/data/Projects/ADHD200/RawDataBIDS/ ./RawDataBIDS --exclude '*nii.gz*'

## updating.
#aws s3 sync ./RawDataBIDS/ s3://fcp-indi/data/Projects/ADHD200/RawDataBIDS/ --acl public-read



#Mount S3 to local file system, note it should be mounted to an existing folder.
# in the current folder
Mkdir S3Mount
goofys fcp-indi:data S3Mount

# umount S3Mount to un-mount

#BIDS Validator on the mounted S3 bucket., nut it seems the docker version does not work on the mounted S3.
#run -ti --rm -v ~/S3Mount/Projects/ADHD200/RawDataBIDS:/data:ro bids/validator /data


#Installed BIDS validator, works.
bids-validator S3Mount/Projects/ADHD200/RawDataBIDS/NYU



############################################################ ADHD200: ALL GOOD
name=ADHD200
mkdir -p $name/Validate_infor
for site in $(ls S3Mount/Projects/$name/RawDataBIDS);do
	echo $site
	  bids-validator 'S3Mount/Projects/'$name'/RawDataBIDS/'$site >> ADHD/Validate_infor/$site'.txt'
done




############################################################## ABIDE - very messy
name=ABIDE
mkdir -p $name/Validate_infor
for site in $(ls S3Mount/Projects/$name/RawDataBIDS);do
	echo $site
	if [[ ! -f $name/Validate_infor/$site'.txt' ]];then
	 bids-validator 'S3Mount/Projects/'$name'/RawDataBIDS/'$site >> $name/Validate_infor/$site'.txt'
	fi
done

# Step 1
# get the site car file to fix
aws s3 sync s3://fcp-indi/data/Projects/ABIDE/RawDataBIDS/ ABIDE/RawDataBIDS --exclude '*nii.gz*'
# after dowload, compress it as an oritinal copy just in case.

# Step 2
# maek a fake nifti file for bids-validator locally
name=ABIDE
for site in $(ls S3Mount/Projects/$name/RawDataBIDS);do
    datain='S3Mount/Projects/ABIDE/RawDataBIDS/'$site
    dataout='ABIDE/RawDataBIDS/'$site
    filesample=sample.nii.gz
    for i in $(find $datain -type f ! -iname '*json*' ! -iname '*tsv*' -path '*anat*');do
    	echo $i
	    i_new=${i/$datain/$dataout}
	    mkdir -p $(dirname $i_new)
	    cp $filesample $i_new
    done
done

# Step 3
#copy a dataset_description file to site folder, this need to be changed individually.
# need to replace the site name.
sample=ABIDE/dataset_description.json
for i in $(ls ABIDE/RawDataBIDS);do 
	cp $sample ABIDE/RawDataBIDS/$i/.
	sed -i '' -e 's/XXXXXX/'$i'/g' ABIDE/RawDataBIDS/$i/dataset_description.json
done

# Step4
# handle the participant file
# rename the original one.
for i in $(find ABIDE/RawDataBIDS  -iname '*participants*'); do 
	mv $i ${i/.tsv/_orig.tsv}; 
done

# Step5:
# fix the slice timing unit
# fix_slice_timing.py

## run the python scripts to read in and save out the participant file
# python participant_File_reformat.py

# rmeove the participant_orig.tsv
rm $(find ABIDE/RawDataBIDS  -iname '*participants_orig.tsv*')



# do the BIDS validator locally:
for site in $(ls ABIDE/RawDataBIDS);do
	echo $site
	bids-validator ABIDE/RawDataBIDS/$site
done


## remove the folder, and then ready to upload.
rm -r $(find ABIDE/RawDataBIDS  -iname '*sub-*' -type d)


# sync to 
aws s3 sync ABIDE/RawDataBIDS s3://fcp-indi/data/Projects/ABIDE/RawDataBIDS/ --acl public-read


