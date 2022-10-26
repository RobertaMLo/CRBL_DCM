% Run the routine for building a GCM

clc
clear
close

start_dir = pwd ;

parent_path = "/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj" %bcc;

init_subj = 1;
n_subj = 6;

GCM_name = 'GCM_full_dCRBL_3GF.mat'

DCM_name = '_5                                                                                                  RFMROI_drivingC*'

GCM = GCM_builder(parent_path, GCM_name, DCM_name, init_subj, n_subj);

cd(start_dir)