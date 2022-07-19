clear
clc
close all

start_dir = pwd ;
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5';

init_subj = 1; nsubj = 23; estimate = 0;

A_filename = {'A_full.txt'};
B_filename = '';
C_filename = {'C_SMA.txt', 'C_CRBL.txt'};

DCM_filename = {'full_conn_SMA', 'full_conn_CRBL'};

GCM_name = 'GCM_fixedconn.mat';

n_dcm = 0;
for a = 1:length(A_filename)
    
    n_dcm = n_dcm + 1;
    
    for c = 1:length(C_filename)
        
        visuomotor_DCM(protDir, init_subj, nsubj, A_filename{a}, B_filename,...
            C_filename{c}, DCM_filename{n_dcm}, estimate)
        
        n_dcm = n_dcm + 1;
        
    end
end


DCM_name = 'DCM_*';

GCM = GCM_builder(protDir,fullfile(protDir,'GCM_models'), GCM_name, ...
    DCM_name, init_subj, nsubj);

cd(start_dir)
