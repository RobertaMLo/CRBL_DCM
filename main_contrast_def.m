% =========================================================================
% Protocol to run the code for definition of F_contrast acros the subjects
% 
% =========================================================================
%   @author: robertalorenzi
%   creation date: Oct 20th, 2021
%   -----------------------------------------------------------------------
%   Last update:
%   -----------------------------------------------------------------------
clc
clear
close all

current_dir = pwd;

% 
parent_dir = '/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj'
% contr_name = 'F_AE_3mod';
% contr_mat = eye(4);
% del_contr = 1;
% start_subj = 1;
% nsubj = 6;
% 
% F_contrast_def(parent_dir, start_subj, nsubj, contr_name, contr_mat, del_contr)

contr_name = 'T_AE';
contr_mat = [1 0 0 0 0 0 0 0 0 0 0 0];
del_contr = 0;
start_subj = 1;
nsubj = 6;

T_contrast_def(parent_dir, start_subj, nsubj, contr_name, contr_mat, del_contr)

cd(pwd)

