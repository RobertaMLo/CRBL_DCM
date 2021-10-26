
clc
clear
close
start_dir = pwd
parent_path = "/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj" %bcc;
init_subj = 1;
n_subj = 6;
estimate = false; %Use GCM builder to estimate DCM for all subjects!
% Fastere cause parallel run is included!

disp("I'm doing DCM: ")
dcm_ID = 'FULL_FIXED_CONN'

DCM_spec_estim_crbl(parent_path', dcm_ID, init_subj, n_subj, true)
cd(pwd)