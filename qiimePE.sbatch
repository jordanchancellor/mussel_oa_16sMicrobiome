#!/bin/bash
#SBATCH --mem=200G
#SBATCH --time=2-0
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=12
#SBATCH --error=%x.err
#SBATCH --output=%x.out
#SBATCH -J qiime2_PE
#SBATCH --mail-type=END
#SBATCH --mail-user=jchancel@usc.edu

# usage: sbatch scripts/qiimePE.sbatch

wd="/project/noujdine_61/jchancel/mussel_16s/gallo"
qiime_dir="${wd}/qiime_PE"
manifest="${wd}/manifest.tsv"
READS="${qiime_dir}/reads.qza"
# CLASSIFIER="path_to_classifier.qza"
# METADATA="sample_metadata.tsv"

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
echo "Importing reads into qiime2..."
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path ${manifest} \
  --output-path ${qiime_dir}/reads.qza \
  --input-format SingleEndFastqManifestPhred33V2

# denoise reads with Deblur
echo "Running Deblur on reads..."
qiime deblur denoise-16S \
  --i-demultiplexed-seqs $READS \
  --p-trim-length 150 \
  --o-representative-sequences ${qiime_dir}/rep_seqs.qza \
  --o-table ${qiime_dir}/table.qza \
  --o-stats ${qiime_dir}/deblur_stats.qza

# view summary statistics from qiime2 deblur aartifacts
qiime deblur visualize-stats \
  --i-deblur-stats ${qiime_dir}/deblur_stats.qza \
  --o-visualization ${qiime_dir}/deblur_stats.qza

# generate summery of FeatureTable frequency artifact
qiime feature-table summarize \
  --i-table ${qiime_dir}/table.qza \
  --o-visualization ${qiime_dir}/table.qza \
  --m-sample-metadata-file ${qiime_dir}/sample-metadata.tsv

# generate summery of FeatureTable sequence artifact
qiime feature-table tabulate-seqs \
  --i-data ${qiime_dir}/rep_seqs.qza \
  --o-visualization ${qiime_dir}/rep_seqs.qza

# clustering with VSEARCH (97% OTUs)
echo "Clustering features at 97% similarity with VSEARCH..."
qiime vsearch cluster-features-de-novo \
  --i-sequences ${qiime_dir}/rep_seqs.qza \
  --i-table ${qiime_dir}/table.qza \
  --p-perc-identity 0.97 \
  --o-clustered-table ${qiime_dir}/clustered_table.qza \
  --o-clustered-sequences ${qiime_dir}/clustered_rep_seqs.qza

# generate phylogenetic tree 
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences ${qiime_dir}/rep_seqs.qza \
  --o-alignment ${qiime_dir}/aligned_rep_seqs.qza \
  --o-masked-alignment ${qiime_dir}/masked_aligned_rep_seqs.qza \
  --o-tree ${qiime_dir}/unrooted-tree.qza \
  --o-rooted-tree ${qiime_dir}/rooted-tree.qza