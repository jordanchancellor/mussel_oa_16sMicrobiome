#!/bin/bash
#SBATCH --mem=0
#SBATCH --time=01:00:00
#SBATCH --partition=htcondor
#SBATCH --error=%x.err
#SBATCH --output=%x.out
#SBATCH -J cluster_qiime
#SBATCH --mail-type=END
#SBATCH --mail-user=jchancel@usc.edu

# usage: sbatch scripts/qiime_clustering_array.sbatch

wd="/project/noujdine_61/jchancel/mussel_16s/gallo"
qiime_dir="${wd}/qiime_array/"
table_files=($(ls ${qiime_dir}/*_table.qza))
repseq_files=($(ls ${qiime_dir}/*_rep_seqs.qza))
METADATA="${wd}/gallo_metadata.tsv"
CLASSIFIER="/project/noujdine_61/jchancel/mussel_16s/training-feature-classifiers/classifier_training/silva_97_classifier.qza"

# load environment
module load conda
source /spack/conda/miniconda3/23.3.1/etc/profile.d/conda.sh
conda activate qiime2

# merge Deblur outputs
echo "Merging Deblur tables..."
qiime feature-table merge \
  $(for table in "${table_files[@]}"; do echo --i-tables "$table"; done) \
  --o-merged-table ${qiime_dir}/merged_table.qza

echo "Merging Deblur sequences..."
qiime feature-table merge-seqs \
  $(for repseq in "${repseq_files[@]}"; do echo --i-data "$repseq"; done) \
  --o-merged-data ${qiime_dir}/merged_rep_seqs.qza

# generate summary of merged FeatureTable frequency artifact
echo "Generating summary of merged FeatureTable frequency artifact..."
qiime feature-table summarize \
  --i-table ${qiime_dir}/merged_table.qza \
  --o-visualization ${qiime_dir}/merged_table.qzv \
  --m-sample-metadata-file $METADATA

# generate summary of merged FeatureTable sequence artifact
echo "Generating summary of merged FeatureTable sequence artifact..."
qiime feature-table tabulate-seqs \
  --i-data ${qiime_dir}/merged_rep_seqs.qza \
  --o-visualization ${qiime_dir}/merged_rep_seqs.qzv

# clustering with VSEARCH (97% OTUs)
echo "Clustering features at 97% similarity with VSEARCH..."
qiime vsearch cluster-features-de-novo \
  --i-sequences ${qiime_dir}/merged_rep_seqs.qza \
  --i-table ${qiime_dir}/merged_table.qza \
  --p-perc-identity 0.97 \
  --o-clustered-table ${qiime_dir}/clustered_table.qza \
  --o-clustered-sequences ${qiime_dir}/clustered_rep_seqs.qza

# assign taxonomy with pre-trained classifier
echo "Assigning taxonomy..."
qiime feature-classifier classify-sklearn \
  --i-classifier $CLASSIFIER \
  --i-reads ${qiime_dir}/clustered_rep_seqs.qza \
  --o-classification ${qiime_dir}/taxonomy.qza

# visualize taxonomic assignments
echo "Creating taxonomy visualization output..."
qiime metadata tabulate \
  --m-input-file ${qiime_dir}/clustered_rep_seqs.qza \
  --m-input-file ${qiime_dir}/taxonomy.qza \
  --o-visualization ${qiime_dir}/taxonomy.qzv

# export files for import into phyloseq
echo "Exporting feature table for phyloseq..."
mkdir -p exported-feature-table
qiime tools export \
  --input-path ${qiime_dir}/clustered_table.qza \
  --output-path ${qiime_dir}/exported-feature-table

# convert feature table to 
biom convert -i ${qiime_dir}/exported-feature-table/feature-table.biom -o ${qiime_dir}/exported-feature-table/feature-table.tsv --to-tsv

# remove first line of .tsv files
sed -i -e "1d" ${qiime_dir}/exported-feature-table/feature-table.tsv

echo "Exporting taxonomy for phyloseq..."
mkdir -p exported-taxonomy
qiime tools export \
  --input-path ${qiime_dir}/taxonomy.qza \
  --output-path ${qiime_dir}/exported-taxonomy
