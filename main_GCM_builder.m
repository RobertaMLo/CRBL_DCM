% Run the routine for building a GCM

clc
clear
close

start_dir = pwd ;

parent_path = "/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj" %bcc;

init_subj = 1;
n_subj = 6;

DCM_name = 'DCM_26_Oct_2021_FULL_FIXED_CONN.mat';

GCM = GCM_builder (parent_path, DCM_name, init_subj, n_subj);

cd(start_dir)