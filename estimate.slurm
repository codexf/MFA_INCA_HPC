#!/bin/bash --login
#SBATCH --constraint=[intel16|intel18|amd20]
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=4:00:00
#SBATCH --output=slurm-%a.out
echo "SLURM_JOBID: " $SLURM_JOBID
matlab -nosplash -nodesktop -r "single_flux_estimate_hpcc"