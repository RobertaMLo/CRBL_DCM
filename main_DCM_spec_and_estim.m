
clc
clear
close
start_dir = pwd
parent_path = "/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj" %bcc;
init_subj = 1;
n_subj = 6;
estimate = true;

disp("I'm doing DCM: ")
dcm_ID = 'GF4'

DCM_spec_estim_crbl(parent_path', dcm_ID, init_subj, n_subj, true)
cd(pwd)