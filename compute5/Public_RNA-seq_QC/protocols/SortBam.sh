#MOLGENIS walltime=23:59:00 nodes=1 mem=8gb ppn=4

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string platform
#string picardVersion
#string toolDir
#string filteredBamDir
#string sortedBamDir
#string sortedBam
#string sortedBai
#string uniqueID
#string jdkVersion
#string filteredBam


#Load modules
${stage} picard/${picardVersion}

#check modules
${checkStage}

mkdir -p ${sortedBamDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

java -Xmx6g -XX:ParallelGCThreads=4 -jar $EBROOTPICARD/picard.jar SortSam \
  INPUT=${filteredBam} \
  OUTPUT=${sortedBam} \
  SO=coordinate \
  CREATE_INDEX=true \
  TMP_DIR=${TMPDIR}

sortBamReturnCode=$?

echo "SortBam return code: ${sortBamReturnCode}"

if [ $sortBamReturnCode -eq 0 ]
then
    echo "Bam sorted succesfuly"
else
    echo "ERROR: Bam not sorted successfully"
    exit 1;
fi

echo "## "$(date)" ##  $0 Done "

