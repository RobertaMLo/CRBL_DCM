% code to run first level spec and/or estimate.
% STRUCTURE IS FIXED IN .m FUNCTION

clear

start_dir = pwd
parent_path = "/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj"

init_subj = 1;
n_subj = 6;

% Use GCM builder to estimate DCM for all subjects!
% Fastere cause parallel run is included!
% 1 = true; 0 = false
estimate = 0;

disp("I'm doing DCM: ")
dcm_ID = '5MROI_drivingC_1ord_toCRBL_fromV1'

DCM_spec_estim_crbl2(parent_path, dcm_ID, init_subj, n_subj, estimate) 

cd(pwd)