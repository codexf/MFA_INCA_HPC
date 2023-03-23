% Author: Xinyu Fu, fuxinyu2@msu.edu
% Updated on 2021-05-15 for inca_hpcc
% This script analyzes the outputs for parameter continuation

% Type the name of your INCA model
matname = 'yuan_CO2np.mat';

% Record the path of the current script and .mat model
dir = pwd;

% Change path to INCA
cd ~/inca_hpcc;
startup;

% Change path back to the original folder with the current script and .mat model
cd (dir);

% Load model
model= load(matname);
m = model.mod; 


% Flux estimation
f = estimate(m);

% Set options to extract processout.mat files
m.options.hpc_on = 1;
m.options.hpc_bg = -1;
[FIT, BESTFIT] = continuate(f,m);

% Export parameter information in tabular txt format
diary('fit.txt');
fprintf('Output for the fit and confidence intervals after Parameter Continuation \n')
FIT
FIT.par
diary off;

diary('bestfit.txt');
fprintf('Output for the best fit fluxes after Parameter Continuation \n')
BESTFIT
BESTFIT.par
diary off;
