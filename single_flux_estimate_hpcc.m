% Author: Xinyu Fu, fuxinyu2@msu.edu
% Updated on 2021-09-28 for HPCC
% This script is developed for doing a single flux estimation of an INCA model
% and export the parameter results as csv files.

% record the path of the current script and .mat model
dir = pwd;

% Navigate to INCA folder to activate functions
% Note: change the INCA path specific to your HPCC
cd '~/2021_inca_demo/inca2.0'; 
startup % also did the functions of setpath so that MATLAB can call INCA functions

% change path back to the original folder with the current script and .mat model
cd (dir);

% load model
% Note: change the model name to yours
matname = 'model.mat';
model = load(matname);
m = model.mod;

% flux estimatation of the model
fit = estimate(m);

% export parameter object (flux values)
par = fit.par;
type = par.type(:);
id = par.id(:);
eqn = par.eqn(:);
val = par.val(:);
std = par.std(:);
T = table(type, id, eqn, val, std); 
T.Properties.VariableNames = {'Type' 'ID' 'Equation' 'Value' 'SE'};
writetable(T, sprintf('par_%s.csv', matname(1:length(matname)-4)), 'Delimiter', ',');

% export measurement object (individual SSRs)
mnt = fit.mnt;
mnt_expt = mnt.expt(:); 
mnt_type = mnt.type(:);
mnt_id = mnt.id(:);
mnt_sres = mnt.sres(:); % total squared residual of each measurement
mnt_T = table(mnt_expt, mnt_type, mnt_id, mnt_sres); 
mnt_T.Properties.VariableNames = {'Expt' 'Type' 'ID' 'SRES'};
writetable(mnt_T, sprintf('res_%s.csv', matname(1:length(matname)-4)), 'Delimiter', ',');