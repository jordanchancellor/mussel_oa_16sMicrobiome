#!/bin/bash
#SBATCH --mem=200G
#SBATCH --time=1-0
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=12
#SBATCH --error=%x.err
#SBATCH --output=%x.out
#SBATCH -J gallo_figaro
#SBATCH --mail-type=END
#SBATCH --mail-user=jchancel@usc.edu

# usage: sbatch scripts/figaro.sbatch

wd="/project/noujdine_61/jchancel/mussel_16s/gallo"
fastqdir="${wd}/raw_reads/"
outdir="${wd}/figaro/"
figaro_path="/project/noujdine_61/jchancel/software/figaro/figaro"

# load environment
module load conda
source /spack/conda/miniconda3/23.3.1/etc/profile.d/conda.sh
module load gcc/8.3.0
module load python/3.6.8

# unzip files if necessary 

for file in ${fastqdir}/*; do
    if [[ $file = *.gz ]]; then
        gunzip "$file"
    fi
done

# run figaro
python3 ${figaro_path}/figaro.py -i ${fastqdir} -o ${outdir} -a 450 -f 51 -r 53

