#!/bin/bash

###########################################################################
##
## Script to take backup of RDS instance and
## push it to S3 bucket....it creates the directories on s3 of current date
##
###########################################################################

INSTANCE='mydb'
BUCKET='db-logs-backup'

mkdir -p ${INSTANCE} && cd ${INSTANCE}
for i in `aws rds describe-db-log-files --db-instance-identifier ${INSTANCE} --output text | awk '{print $3}' | tail -n 10` ; do
	FILE=`basename ${i}`
	ARCHIVE=${FILE}.tar.gz
	if [ ! -e ${ARCHIVE} ]; then
		echo "-----------------------------------------------"
		echo "Downloading ${i} ........."
		`which aws` rds download-db-log-file-portion --db-instance-identifier ${INSTANCE} --log-file-name ${i} --starting-token 0 --output text > ${FILE}
		tar -cvzf ${ARCHIVE} ${FILE}
		echo "-----------------------------------------------"
		echo "Uploading to S3 bucket ${BUCKET}........"
		`which aws` s3 mv ${ARCHIVE} s3://${BUCKET}/$(date +%d-%m-%Y)/
		echo "-----------------------------------------------"
		rm ${FILE}
	fi
done
