#MOLGENIS walltime=23:59:00 mem=12gb ppn=2

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string starVersion
#string WORKDIR
#string projectDir

#string gatkVersion
#string dbsnpVcf
#string dbsnpVcfIdx
#string onekgGenomeFasta
#string indelRealignmentBam
#string indelRealignmentBai

#string haplotyperDir
#string haplotyperGvcf
#string haplotyperGvcfIdx


echo "## "$(date)" ##  $0 Started "

for file in "${indelRealignmentBam[@]}" "${indelRealignmentBai[@]}" "${dbsnpVcf}" "${dbsnpVcfIdx}" "${onekgGenomeFasta}"; do
	echo "getFile file='$file'"
	getFile $file
done

#Load gatk module
${stage} GATK/${gatkVersion}
${checkStage}

#sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
bams=($(printf '%s\n' "${indelRealignmentBam[@]}" | sort -u ))

inputs=$(printf ' -I %s ' $(printf '%s\n' ${bams[@]}))

mkdir -p ${haplotyperDir}

java -Xmx12g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${haplotyperDir} -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T HaplotypeCaller \
 -R ${onekgGenomeFasta} \
 --dbsnp ${dbsnpVcf}\
 $inputs \
 -dontUseSoftClippedBases \
 -stand_call_conf 10.0 \
 -stand_emit_conf 20.0 \
 -o ${haplotyperGvcf} \
 --emitRefConfidence GVCF

putFile ${haplotyperGvcf}
putFile ${haplotyperGvcfIdx}

echo "## "$(date)" ##  $0 Done "