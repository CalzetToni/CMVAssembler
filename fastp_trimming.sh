# Defaults:
input_dir="./";
ext='fastq.gz'

# Usage:
echo " Launch quality assessment and trimming through Fastp toolkit

 USAGE:
 $(basename $0) -o OUTPUT_DIR [-i INPUT_DIR]

 Options:
   -i    Input directory (default: $input_dir)
   -o    Output directory (will be created)
   -e    Extension without first dot (default: $ext)
";

while getopts o:i:e: option
do
	case "${option}"
		in
		i) input_dir=${OPTARG};;
	        o) output_dir=${OPTARG};;
        	e) ext=${OPTARG};;
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
mkdir "$output_dir"

# Loop files in {input_dir} with extension {ext}
for f in $input_dir/*_R1.$ext
do
	sampleName=${f%%_R1.$ext}
	fastp \
		-i ${sampleName}_R1.$ext \
		-I ${sampleName}_R2.$ext \
		-o $output_dir/${sampleName##*/}_R1.fastq \
		-O $output_dir/${sampleName##*/}_R2.fastq

	echo "Files ${sampleName##*/}_R1.fastq and ${sampleName##*/}_R2.fastq trimmed with fastp"
done

rm fastp.json fastp.html
