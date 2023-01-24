% 
clc
clear
%% ============ DCM specify ===============================================
%protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5/';
wDir= pwd;

protDir = '/media/bcc/Volume/Roberta/DCM/AE_P5/';

init_subj = 1;
nsubj = 23;

DCM_filename = 'pp';

estimate_bool = false; 

trial_visuomotor_DCM(protDir, init_subj, nsubj, DCM_filename, estimate_bool)

cd(wDir)

%% ============ GCM builder and estimate ==================================
GCM_name = 'rrtf';
init_subj = 1;
nsubj = 23;

%DCM_name = {'^DCM_2022823_h09m46+'};
DCM_name={'_pp+'};

GCM = GCM_builder(protDir,fullfile(protDir,'GCM_models'), GCM_name, ...
    DCM_name, init_subj, nsubj);
