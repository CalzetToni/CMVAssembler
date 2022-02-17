# Defaults:
input_dir="./";
ext='fastq';
cores=1

# Usage:
echo " Clean fastq paired end files from human host

 USAGE:
 $(basename $0) -o OUTPUT_DIR -r REFERENCE_GENOME -p CORES [-i INPUT_DIR -e INPUT_EXTENSION]

 Options:
   -i    Input directory (default: $input_dir)
   -o    Output directory (will be created)
   -e    Extension without first dot (default: $ext)
   -r    Reference bowtie2
   -p    Cores
";

while getopts o:i:e:r:p: option
do
        case "${option}"
                in
                i) input_dir=${OPTARG};;
                o) output_dir=${OPTARG};;
                e) ext=${OPTARG};;
                r) ref=${OPTARG};;
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

# Loop files in {input_dir} with extension {ext}
for f in $input_dir/*_R1.$ext
do
        sampleName=${f%%_R1.$ext}
        bowtie2 \
                -p ${cores} \
                -x ${ref} \
                -1 ${sampleName}_R1.${ext} \
                -2 ${sampleName}_R2.${ext} \
                --un-conc $output_dir/${sampleName##*/}_human_removed \
        > SAMPLE_mapped_and_unmapped.sam

        mv $output_dir/${sampleName##*/}_human_removed.1 $output_dir/${sampleName##*/}_human_removed_R1.fastq
        mv $output_dir/${sampleName##*/}_human_removed.2 $output_dir/${sampleName##*/}_human_removed_R2.fastq
        rm SAMPLE_mapped_and_unmapped.sam

        echo " > Generated human_removed fastq for sample ${sampleName##*/}. Saved into ${output_dir}";
done
