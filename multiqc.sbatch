#!/bin/bash
#SBATCH --mem=50G
#SBATCH --time=01:00:00
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=12
#SBATCH --error=%x.err
#SBATCH --output=%x.out
#SBATCH -J gallo_multiqc
#SBATCH --mail-type=END
#SBATCH --mail-user=jchancel@usc.edu

# usage: sbatch scripts/multiqc.sbatch

wd="/project/noujdine_61/jchancel/mussel_16s/gallo"
# outdir="${wd}/fastqc_raw/"
outdir="${wd}/fastqc_trimmed/"

# load environment
module load conda
source /spack/conda/miniconda3/23.3.1/etc/profile.d/conda.sh
conda activate multiqc

# run multiqc on fastqc results in output directory

multiqc --version
if [[ $? -ne 0 ]]
then
	echo "Error - check MultiQC installation."
fi

# If input directory exists, run MultiQC
if [[ -d $outdir ]]
then
	multiqc -o $outdir $outdir
else
	echo "Error - input directory to MultiQC, \
${outdir}, not found."
fi

echo "MultiQC done."