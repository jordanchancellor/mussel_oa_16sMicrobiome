#!/bin/bash
#SBATCH --mem=50G
#SBATCH --time=01:00:00
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=12
#SBATCH --error=%x_%a.err
#SBATCH --output=%x_%a.out
#SBATCH -J gallo_trim
#SBATCH --mail-type=END
#SBATCH --mail-user=jchancel@usc.edu

# usage: sbatch --array=1-48 scripts/trimmomatic.sbatch

wd="/project/noujdine_61/jchancel/mussel_16s/gallo"
samples_file="${wd}/samples_file.txt"
sample_id=$(cat $samples_file | sed -n ${SLURM_ARRAY_TASK_ID}p)
reads="${wd}/raw_reads"
outdir="${wd}/trimmed_reads/"
read1="${reads}/${sample_id}_CKDL240035587-1A_22VLHVLT3_L8_1.fq.gz"
read2="${reads}/${sample_id}_CKDL240035587-1A_22VLHVLT3_L8_2.fq.gz"

# define desired trimming options
phred="phred33"
ADAPTERS="/home1/jchancel/.conda/envs/trimmomatic/share/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10"
LEADING="3"
TRAILING="3"
SLIDINGWINDOW="4:20"
MINLEN="36"

# load environment

module load conda
source /spack/conda/miniconda3/23.3.1/etc/profile.d/conda.sh
conda activate trimmomatic

# Create output directories (if needed)
if [[ ! -d $outdir ]]
then
	printf "Creating output directory ${outdir}."
	mkdir $outdir 
fi

# trimmomatic checkpoint
trimmomatic -version
if [[ $? -ne 0 ]]
then
	printf "Error - check trimmomatic installation.\n"
	exit 1
fi

# run trimmomatic on paired reads

echo "Running Trimmomatic on paired reads associated with ${sample_id}: ${read1} and ${read2}"

trimmomatic PE -threads 12 -"${phred}" \
"${read1}" "${read2}" \
${outdir}/"${sample_id}"_F_trimmed_paired.fq.gz ${outdir}/"${sample_id}"_F_trimmed_unpaired.fq.gz \
${outdir}/"${sample_id}"_R_trimmed_paired.fq.gz ${outdir}/"${sample_id}"_R_trimmed_unpaired.fq.gz \
ILLUMINACLIP:"${ADAPTERS}" \
LEADING:"${LEADING}" \
TRAILING:"${TRAILING}" \
SLIDINGWINDOW:"${SLIDINGWINDOW}" \
MINLEN:"${MINLEN}"

echo "PE Trimming complete. Trimmed files can be found in ${outdir}."

