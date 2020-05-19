## download the dataset
aws s3 sync s3://fcp-indi/data/Projects/ABIDE2/RawData /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/RawData --exclude "*derivative*"


datain='/data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2'
bids_info='/data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/Validate_infor_3'
mkdir -p $bids_info
for site in $(ls $datain'/RawData');do
    echo $site
    docker run -ti --rm -v $datain'/RawData/'$site:/data:ro bids/validator:v1.4.2 /data >> $bids_info'/'$site'.txt'
done



#copy a dataset_description file to site folder, this need to be changed individually.
# need to replace the site name.
## sed is different in mac os and linux.
sample=/data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/dataset_description.json
datain='/data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/RawData'
for i in $(ls $datain);do 
	cp $sample $datain'/'$i/.
	sed -i 's/XXXXXX/'$i'/g' $datain'/'$i'/dataset_description.json'
done


#####3## fix some

# ONRC_2, add .bidsignore - done
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/RawData/ABIDEII-ONRC_2:/data:ro bids/validator:v1.4.2 /data

# SDSU_1.  - done
# renamed readme.txt to README, deleted teh readme.txt in the bucket. Added .bidsignore file
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/RawData/ABIDEII-SDSU_1:/data:ro bids/validator:v1.4.2 /data

# NYU_1 and NYU_2 dwi are very messy, ignore the whole dwi folder - done
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/RawData/ABIDEII-NYU_1:/data:ro bids/validator:v1.4.2 /data
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/RawData/ABIDEII-NYU_2:/data:ro bids/validator:v1.4.2 /data

# IP_1
# removed slidetiming:na from the json file
docker run -ti --rm -v /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/RawData/ABIDEII-IP_1:/data:ro bids/validator:v1.4.2 /data



## update the S3 bucket
aws s3 sync /data3/cdb/FCP_INDI/FIX_Dataset/ABIDE2/RawData s3://fcp-indi/data/Projects/ABIDE2/RawData --acl public-read --profile FCP-INDI --dryrun
