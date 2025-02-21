#!/bin/bash
#SBATCH --mem=64G
#SBATCH --time=1-0
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=32
#SBATCH --error=%x.err
#SBATCH --output=%x.out
#SBATCH -J reorient_reads
#SBATCH --mail-type=END
#SBATCH --mail-user=jchancel@usc.edu

# usage: sbatch --array=1-48 scripts/reorientreads.sbatch

wd="/project/noujdine_61/jchancel/mussel_16s/gallo"
samples_file="${wd}/samples_file.txt"
sample_id=$(cat $samples_file | sed -n ${SLURM_ARRAY_TASK_ID}p)
# readsdir="${wd}/trimmed_reads/filtered"
readsdir="${wd}/trimmed_reads"
# reverse_read="${readsdir}/${sample_id}_R_filt.fq.gz"
reverse_read="${readsdir}/${sample_id}_R_trimmed_paired.fq"

# load environment
module load conda
source /spack/conda/miniconda3/23.3.1/etc/profile.d/conda.sh
conda activate seqtk

# reorient reverse reads
echo "Reorienting reverse reads for sample ${sample_id}: ${reverse_read}"

# seqtk seq -r "${reverse_read}" > ${readsdir}/${sample_id}_R_filt_reoriented.fq
seqtk seq -r "${reverse_read}" > ${readsdir}/${sample_id}_R_trimmed_paired_reoriented.fq


# gzip the reads
# gzip ${readsdir}/${sample_id}_R_filt_reoriented.fq
