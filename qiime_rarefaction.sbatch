#!/bin/bash
#SBATCH --mem=50GB
#SBATCH --time=7-0
#SBATCH --partition=largemem
#SBATCH --cpus-per-task=12
#SBATCH --error=%x.err
#SBATCH --output=%x.out
#SBATCH -J phylogeny_gallo
#SBATCH --mail-type=END
#SBATCH --mail-user=jchancel@usc.edu

# usage: sbatch scripts/qiime_rarefaction.sbatch

wd="/project/noujdine_61/jchancel/mussel_16s/gallo"
qiime_dir="${wd}/qiime_array/"
table_merged="${qiime_dir}/merged_table.qza"
repseq_merged="${qiime_dir}/merged_rep_seqs.qza"
METADATA="${wd}/gallo_metadata.tsv"
# CLASSIFIER="/project/noujdine_61/jchancel/mussel_16s/training-feature-classifiers/classifier_training/silva_97_classifier.qza"
reference_db="/project/noujdine_61/jchancel/mussel_16s/SILVA_ref/sepp-refs-silva-128.qza"

# load environment
module load conda
source /spack/conda/miniconda3/23.3.1/etc/profile.d/conda.sh
conda activate qiime2

# make output directory (if necessary)
if [[ ! -d ${qiime_dir}/phylogeny ]]
then
	printf "Creating phylogeny directory in ${qiime_dir}.\n\n"
	mkdir ${qiime_dir}/phylogeny 
fi

# generate phylogenetic tree
qiime fragment-insertion sepp \
  --i-representative-sequences ${repseq_merged} \
  --i-reference-database ${reference_db} \
  --o-tree ${qiime_dir}/phylogeny/tree.qza \
  --o-placements ${qiime_dir}/phylogeny/tree_placements.qza \
  --p-threads 12

# rarefaction
# qiime diversity alpha-rarefaction \
#   --i-table ${table_merged} \
#   --m-metadata-file ${METADATA} \
#   --o-visualization ${qiime_dir}/alpha_rarefaction_curves.qzv \
#   --p-min-depth 10 \
#   --p-max-depth 11500000

  
