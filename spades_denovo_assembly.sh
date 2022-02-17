# Defaults:
input_dir="./";
ext='fastq'

# Usage:
echo " Generate de novo assembly from fastq R1/R2 samples

 USAGE:
 $(basename $0) -o OUTPUT_DIR -p CORES [-i INPUT_DIR -e INPUT_EXTENSION]

 Options:
   -i    Input directory (default: $input_dir)
   -o    Output directory (will be created)
   -e    Extension without first dot (default: $ext)
   -p	 Cores
";

while getopts o:i:e:p: option
do
	case "${option}"
		in
		i) input_dir=${OPTARG};;
	        o) output_dir=${OPTARG};;
        	e) ext=${OPTARG};;
		p) cores=${OPTARG};;
         	?) echo " Wrong parameter $OPTARG";;
		esac
done
shift "$(($OPTIND -1))"

# If the directory exists, delete it
if [ -d ${output_dir} ]
then
	rm -r ${output_dir}
pwd
fi

# Create output directory anyway
mkdir $output_dir
mkdir $output_dir/assemblies
mkdir $output_dir/coverage_bam

# Loop files in {input_dir} with extension {ext}
for f in $input_dir/*_R1.$ext
do
	sampleName=${f%%_R1.$ext}
	/home/collesei/Packages/SPAdes-3.15.3-Linux/bin/spades.py \
		--metaviral \
		--pe1-1 ${sampleName}_R1.$ext \
		--pe1-2 ${sampleName}_R2.$ext \
		-k 21,33,55,77,99,127 \
		-o $output_dir/${sampleName##*/} \
		-t ${cores}

	mv $output_dir/${sampleName##*/}/transcripts.fasta $output_dir/${sampleName##*/}/${sampleName##*/}_assembly.fasta
	mkdir $output_dir/assemblies/${sampleName##*/}
	cp $output_dir/${sampleName##*/}/${sampleName##*/}_assembly.fasta $output_dir/assemblies/${sampleName##*/}

	# Alignment to have coverage info
	bwa index $output_dir/assemblies/${sampleName##*/}/${sampleName##*/}_assembly.fasta
	bwa mem \
		$output_dir/assemblies/${sampleName##*/}/${sampleName##*/}_assembly.fasta \
		${sampleName}_R1.$ext ${sampleName}_R2.$ext \
		> $output_dir/coverage_bam/tmp.file.sam
	samtools view -h -b -S $output_dir/coverage_bam/tmp.file.sam > $output_dir/coverage_bam/tmp.file.bam
	samtools view -b -F 4 $output_dir/coverage_bam/tmp.file.bam > $output_dir/coverage_bam/tmp.file.mapped.bam
	samtools sort $output_dir/coverage_bam/tmp.file.mapped.bam -o $output_dir/coverage_bam/${sampleName##*/}.bam
	samtools index $output_dir/coverage_bam/${sampleName##*/}.bam

	rm $output_dir/coverage_bam/tmp.file*

	echo " > Generated assembly de novo for sample ${sampleName##*/}. Folder saved into ${output_dir}";
done
