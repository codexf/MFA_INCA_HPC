% Author: Xinyu Fu, fuxinyu2@msu.edu
% Updated on 2021-05-15 for inca_hpcc
% This script submits a slurm job (job array) for parameter continuation of an INCA model.
% Once finished, mat.slurm and the dairy and processin files will be generated in the new subfolder 
% Note: queue.m in inca_hpcc/parallel should be modified to match the current HPCC settings

% Record the path of the current script and .mat model
dir = pwd;

% Change path to INCA with the modified queue.m
cd ~/inca_hpcc;
startup;

% Change path back to the original folder with the current script and .mat model
cd (dir);

% Type the name of your INCA model
matname = 'yuan_CO2np.mat';

% Load model
model= load(matname);
m = model.mod;

% flux estimation
fit = estimate(m);

% Change continuation parameters if needed
% m.options.cont_reltol = 2; % Ma et al 2
% m.options.cont_steps = 5; % Ma et al 5

% Continuation analysis using modified queue.m to generate slurm.mat with a job array
m.options.hpc_on = 1;
m.options.hpc_bg = 1;
m.options.hpc_sched = 'msu';
continuate(fit,m);
