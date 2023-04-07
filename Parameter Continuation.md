# Parameter Continuation

## 1. Preparing files to be uploaded to HPCC

### 1.1 Go to the INCA **`parallel`** subdirectory and edit the INCA `queue.m` source file to submit jobs to the MSU HPCC

- Replace lines 97-112 with the following code:

```matlab
case 'msu', % Submit jobs to the MSU cluster
            delete('slurm*');
            fid = fopen('mat.slurm','w');
            fprintf(fid,'#!/bin/bash --login\n');
            fprintf(fid,'#SBATCH --constraint=[intel16|intel18|amd20]');	
            fprintf(fid,'#SBATCH --ntasks=1\n');
            fprintf(fid,'#SBATCH --time=%s\n','24:00:00');
            fprintf(fid,'#SBATCH --mem=%s\n','2G');
            fprintf(fid,'#SBATCH --array=1-%u\n',K);
            fprintf(fid,'#SBATCH --output=slurm-%%a.out\n');
            fprintf(fid,'echo "SLURM_JOBID: " $SLURM_JOBID\n');
            fprintf(fid,'echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID\n');
            fprintf(fid,'echo "SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID\n');
            fprintf(fid,'matlab -nosplash -nodesktop -nojvm -r "cd(''~/inca_hpcc'');startup;serve(${SLURM_ARRAY_TASK_ID},''%s'')"',pwd);
            fclose(fid);
            !sbatch mat.slurm
```

- Note: If your jobs can not be finished in 24 hours, you can increase the time in the `#SBATCH --time=%s\n','24:00:00'` to up to `168:00:00`.

### 1.2 Rename your INCA package to `inca_hpcc` and transfer it to your HPCC home directory

It's important to do so in order to match the code `matlab -nosplash -nodesktop -nojvm -r "cd(''~/inca_hpcc'')` as defined in section 1.1.

### 1.3 Transfer the `scripts_continuate` folder to your HPCC home directory

- The scripts_continuate folder includes `continuate_pre.m` , `continuate_post.m` , and an exemplary model `yuan_CO2np.mat`.
- When you run your own model, be sure to change the `matname` in line 18 of `continuate_pre.m` to the name of your model file.

## 2. Running parameter continuation jobs on HPCC

### 2.1 Submit an interactive job

- `ssh` to one of the dev nodes.
- Submit an interactive job using `salloc` to allocate a job. **DO NOT use intel14** due to issues with MATLAB functions.

```bash
salloc --nodes=1 --ntasks=1 --cpus-per-task=1 --mem=2gb --time=04:00:00 --constraint=amd20
```

The execution will first wait until the job scheduler can provide the resources.

### 2.2 Run `continuate_pre.m` to generate a job script for submission

- `cd` to the `scripts_continuate` folder in your HPCC home directory and run `continuate_pre.m`

```bash
matlab -nodisplay -r "continuate_pre"
```

- You will see flux estimation running in the command line, followed by initiating process: 1 2 3 4 5 ... and submitted the batch job #.

- You will see a batch of input files within the `scripts_continuate` folder named `processin_#.mat`, where ‘#’ is a unique number associated with each job. The jobs will then be distributed to the compute nodes using the job scheduler defined in section 1.1.

### 2.3 Monitor the progress of your submitted jobs

- The jobs will be queued and processed in order of their job number as free compute nodes become available. As they are processed, a batch of text files named `diary_#.txt` and `slurm-#.out`will be created to store any command line outputs.
- Once completed, a batch of output file named `processout_#.mat` will be written to the same directory where the input files are stored.

## 3. Post-processing parameter continuation outputs

### 3.1 Submit an interactive job

- `ssh` to one of the dev nodes.
- Submit an interactive job using `salloc` to allocate a job. **DO NOT use intel14** due to issues with MATLAB functions.

```bash
salloc --nodes=1 --ntasks=1 --cpus-per-task=1 --mem=2gb --time=04:00:00 --constraint=amd20
```

The execution will first wait until the job scheduler can provide the resources.

### 3.2 Run `continuate_post.m` to recover parameter continuation results

- `cd` to the `scripts_continuate` folder in your HPCC home directory and run `continuate_post.m`

```bash
 matlab -nodisplay -r "continuate_post"
```

- You will see flux estimation running in the command line, followed by reading data of #: 1 10 100 101 102 ...

- Once all the parameter continuation jobs have completed, all `processout_#.mat`files will be read, two new text files `fit.txt` and `bestfit.txt` will be written to the same directory.
- `fit.txt` has confidence interval bounds shown in the last two columns.
- If an improved optimal solution was encountered during the parameter continuation, the flux values will be saved to `bestfit.txt`. If the model did not achieve a global best fit solution during the prior flux estimation, the best fit solution could be found during the parameter continuation analysis, otherwise `bestfit.txt` has the same flux values as `fit.txt` .
- Note: The `processout_#.mat`files will be deleted after being read.

