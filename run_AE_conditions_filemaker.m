% Executable to test AE_conditions_filemaker, AO_condition_filemaker

clc
clear


work_dir  = pwd
%protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/S2_trial4SPM'
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND_BAR'



cd(fullfile(protDir))
dir_content = dir;
fnames = {dir_content.name};
%fnames = fnames(endsWith(fnames ,{'.mat'}));
fnames        = fnames(~strncmp(fnames, '.', 1));
file_mat = fnames{1};
% 
% cd(pwd)
AE_conditions_filemaker(file_mat)