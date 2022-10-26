% 
clc
clear

protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5/';
GCM_name = 'GCM_modRL_BF.mat';
init_subj = 1;
nsubj = 23;

%DCM_name = {'^DCM_2022823_h09m46+'};
DCM_name={'^DCM_20221011_+'};

GCM = GCM_builder(protDir,fullfile(protDir,'GCM_models'), GCM_name, ...
    DCM_name, init_subj, nsubj);
