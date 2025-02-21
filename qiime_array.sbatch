#!/bin/bash
#SBATCH --mem=100GB
#SBATCH --time=1-0
#SBATCH --partition=gpu
#SBATCH --error=%x_%a.err
#SBATCH --output=%x_%a.out
#SBATCH -J qiime_array_deblur
#SBATCH --mail-type=END
#SBATCH --mail-user=jchancel@usc.edu

# usage: sbatch --array=1-48 scripts/qiime_array.sbatch

wd="/project/noujdine_61/jchancel/mussel_16s/gallo"
samples_file="${wd}/samples_file.txt"
sample_id=$(cat $samples_file | sed -n ${SLURM_ARRAY_TASK_ID}p)
qiime_dir="${wd}/qiime_array/"
manifest="${wd}/manifests/${sample_id}_manifest.tsv"

# load environment
module load conda
source /spack/conda/miniconda3/23.3.1/etc/profile.d/conda.sh
conda activate qiime2

# make output directory (if necessary)
if [[ ! -d $qiime_dir ]]
then
	printf "Creating output directory ${qiime_dir}.\n\n"
	mkdir $qiime_dir 
fi

import reads into qiime2
echo "Importing reads for ${sample_id} into Qiime2..."
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path ${manifest} \
  --output-path ${qiime_dir}/${sample_id}.qza \
  --input-format SingleEndFastqManifestPhred33V2

# quality filter reads with Deblur
echo "Quality filtering with Deblur..."
qiime quality-filter q-score \
 --i-demux ${qiime_dir}/${sample_id}.qza \
 --o-filtered-sequences ${qiime_dir}/${sample_id}_filtered.qza \
 --o-filter-stats ${qiime_dir}/${sample_id}_filtered_stats.qza

# denoise reads with Deblur
echo "Denoising reads with Deblur..."
qiime deblur denoise-16S \
  --i-demultiplexed-seqs ${qiime_dir}/${sample_id}_filtered.qza \
  --p-trim-length 130 \
  --p-jobs-to-start 48 \
  --o-representative-sequences ${qiime_dir}/${sample_id}_rep_seqs.qza \
  --o-table ${qiime_dir}/${sample_id}_table.qza \
  --o-stats ${qiime_dir}/${sample_id}_deblur_stats.qza
