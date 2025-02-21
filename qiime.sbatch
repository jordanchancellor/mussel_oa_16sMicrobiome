#!/bin/bash
#SBATCH --mem=0
#SBATCH --time=7-0
#SBATCH --partition=oneweek
#SBATCH --error=%x.err
#SBATCH --output=%x.out
#SBATCH -J qiime2_rev
#SBATCH --mail-type=END
#SBATCH --mail-user=jchancel@usc.edu

# usage: sbatch scripts/qiime.sbatch

wd="/project/noujdine_61/jchancel/mussel_16s/gallo"
qiime_dir="${wd}/qiime"
forward_manifest="${wd}/forward_manifest.tsv"
reverse_manifest="${wd}/reverse_manifest.tsv"
METADATA="${wd}/gallo_metadata.tsv"
CLASSIFIER="/project/noujdine_61/jchancel/mussel_16s/training-feature-classifiers/classifier_training/silva_97_classifier.qza"

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

# import forward reads into qiime2
# qiime tools import \
#   --type 'SampleData[SequencesWithQuality]' \
#   --input-path ${forward_manifest} \
#   --output-path ${qiime_dir}/forward_reads.qza \
#   --input-format SingleEndFastqManifestPhred33V2

# # import reverse reads into qiime2
# qiime tools import \
#   --type 'SampleData[SequencesWithQuality]' \
#   --input-path ${reverse_manifest} \
#   --output-path ${qiime_dir}/reverse_reads.qza \
#   --input-format SingleEndFastqManifestPhred33V2

# # quality filter reads with Deblur
# echo "Quality filtering with Deblur on forward reads..."
# qiime quality-filter q-score \
#  --i-demux ${qiime_dir}/forward_reads.qza \
#  --o-filtered-sequences ${qiime_dir}/forward_reads_filtered.qza \
#  --o-filter-stats ${qiime_dir}/forward_reads_filtered_stats.qza

# echo "Quality filtering with Deblur on reverse reads..."
#  qiime quality-filter q-score \
#  --i-demux ${qiime_dir}/reverse_reads.qza \
#  --o-filtered-sequences ${qiime_dir}/reverse_reads_filtered.qza \
#  --o-filter-stats ${qiime_dir}/reverse_reads_filtered_stats.qza

# # denoise forward and reverse reads separately with Deblur
# echo "Denoising forward reads with Deblur..."
# qiime deblur denoise-16S \
#   --i-demultiplexed-seqs ${qiime_dir}/forward_reads_filtered.qza \
#   --p-trim-length 130 \
#   --p-jobs-to-start 48 \
#   --o-representative-sequences ${qiime_dir}/rep_seqs_forward.qza \
#   --o-table ${qiime_dir}/table_forward.qza \
#   --o-stats ${qiime_dir}/deblur_stats_forward.qza

echo "Denoising reverse reads with Deblur..."
qiime deblur denoise-16S \
  --i-demultiplexed-seqs ${qiime_dir}/reverse_reads_filtered.qza \
  --p-trim-length 130 \
  --p-jobs-to-start 48 \
  --o-representative-sequences ${qiime_dir}/rep_seqs_reverse.qza \
  --o-table ${qiime_dir}/table_reverse.qza \
  --o-stats ${qiime_dir}/deblur_stats_reverse.qza

# # merge Deblur outputs
# echo "Merging Deblur tables... and sequences..."
# qiime feature-table merge \
#   --i-tables ${qiime_dir}/table_forward.qza \
#   --i-tables ${qiime_dir}/table_reverse.qza \
#   --o-merged-table ${qiime_dir}/merged_table.qza

# echo "Merging Deblur sequences..."
# qiime feature-table merge-seqs \
#   --i-data ${qiime_dir}/rep_seqs_forward.qza \
#   --i-data ${qiime_dir}/rep_seqs_reverse.qza \
#   --o-merged-data ${qiime_dir}/merged_rep_seqs.qza

# # generate summary of merged FeatureTable frequency artifact
# echo "Generating summary of merged FeatureTable frequency artifact..."
# qiime feature-table summarize \
#   --i-table ${qiime_dir}/merged_table.qza \
#   --o-visualization ${qiime_dir}/merged_table.qzv \
#   --m-sample-metadata-file $METADATA

# # generate summary of merged FeatureTable sequence artifact
# echo "Generating summary of merged FeatureTable sequence artifact..."
# qiime feature-table tabulate-seqs \
#   --i-data ${qiime_dir}/merged_rep_seqs.qza \
#   --o-visualization ${qiime_dir}/merged_rep_seqs.qzv

# # clustering with VSEARCH (97% OTUs)
# echo "Clustering features at 97% similarity with VSEARCH..."
# qiime vsearch cluster-features-de-novo \
#   --i-sequences ${qiime_dir}/merged_rep_seqs.qza \
#   --i-table ${qiime_dir}/merged_table.qza \
#   --p-perc-identity 0.97 \
#   --o-clustered-table ${qiime_dir}/clustered_table.qza \
#   --o-clustered-sequences ${qiime_dir}/clustered_rep_seqs.qza

# # assign taxonomy with pre-trained classifier
# echo "Assigning taxonomy..."
# qiime feature-classifier classify-sklearn \
#   --i-classifier $CLASSIFIER \
#   --i-reads ${qiime_dir}/clustered_rep_seqs.qza \
#   --o-classification ${qiime_dir}/taxonomy.qza

# echo "Creating taxonomy visualization output..."
# visualize taxonomic assignments
# qiime metadata tabulate \
#   --m-input-file ${qiime_dir}/taxonomy.qza \
#   --o-visualization ${qiime_dir}/taxonomy.qzv

# # export files for import into phyloseq
# echo "Exporting feature table for phyloseq..."
# mkdir -p exported-feature-table
# qiime tools export \
#   --input-path ${qiime_dir}/clustered_table.qza \
#   --output-path ${qiime_dir}/exported-feature-table

# echo "Exporting taxonomy for phyloseq..."
# mkdir -p exported-taxonomy
# qiime tools export \
#   --input-path ${qiime_dir}/taxonomy.qza \
#   --output-path ${qiime_dir}/exported-taxonomy

# echo "All steps completed. Data is ready for import into phyloseq."

# Additional note for the user:
# The exported-feature-table directory will contain a feature-table.biom file.
# The exported-taxonomy directory will contain a taxonomy.tsv file.
