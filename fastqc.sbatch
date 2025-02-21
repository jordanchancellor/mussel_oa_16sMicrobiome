#!/bin/bash
#SBATCH --mem=50G
#SBATCH --time=01:00:00
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=12
#SBATCH --error=%x_%a.err
#SBATCH --output=%x_%a.out
#SBATCH -J gallo_fastqc
#SBATCH --mail-type=END
#SBATCH --mail-user=jchancel@usc.edu

# usage: sbatch --array=1-48 scripts/fastqc.sbatch

wd="/project/noujdine_61/jchancel/mussel_16s/gallo"
samples_file="${wd}/samples_file.txt"
sample_id=$(cat $samples_file | sed -n ${SLURM_ARRAY_TASK_ID}p)
# reads="${wd}/raw_reads"
# outdir="${wd}/fastqc_raw/"
# read1="${reads}/${sample_id}_CKDL240035587-1A_22VLHVLT3_L8_1.fq.gz"
# read2="${reads}/${sample_id}_CKDL240035587-1A_22VLHVLT3_L8_2.fq.gz"
reads="${wd}/trimmed_reads"
outdir="${wd}/fastqc_trimmed/"
read1="${reads}/${sample_id}_F_trimmed_paired.fq.gz"
read2="${reads}/${sample_id}_R_trimmed_paired.fq.gz"

if [[ ! -d $outdir ]]
then
	printf "Creating output directory ${outdir}.\n\n"
	mkdir $outdir 
fi

# Load fastqc
module load conda
source /spack/conda/miniconda3/23.3.1/etc/profile.d/conda.sh
conda activate fastqc

# fastqc checkpoint
fastqc --version
if [[ $? -ne 0 ]]
then
	printf "Error - check FASTQC installation.\n"
	exit 1
fi

# run fastqc
echo "Running FASTQC on read files associated with ${sample_id}."

fastqc -t $SLURM_CPUS_PER_TASK -o $outdir $read1 $read2

conda deactivate

echo "fastqc done."