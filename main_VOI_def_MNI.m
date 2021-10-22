% =========================================================================
% Protocol to run the code for subjects' VOI extraction
% 
% =========================================================================
%   @author: robertalorenzi
%   creation date: Oct 20th, 2021
%   -----------------------------------------------------------------------
%   Last update:
%   -----------------------------------------------------------------------
clc
clear
close
%% General Parameters
parent_dir = '/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj';

thr_val = 0.001; %IF some regions not included with this thr, increase!

start_subj = 1;
nsubj = 6;
F_contr_adj = 1;
contr_index  = 2;

sphere_rad = 6;
my_path = pwd;

%% CEREBELLUM
disp('=========================== THE CEREBELLUM ===========================')
VOI_name = 'CRBL_R_A_MNI';

center_vec = [28 -55 -24];

%parent_dir, start_subj, nsubj, VOI_name, ...
%    F_contr_adj, contr_thr, center_vec, thr_val, sphere_rad

VOI_definition_MNI(parent_dir, start_subj, nsubj, VOI_name, F_contr_adj, ...
    contr_index, center_vec, thr_val, sphere_rad)

cd(my_path)


%% MOTOR CORTEX
disp('=========================== MOTOR CORTEX ===========================')
VOI_name = 'M1_L_MNI';

center_vec = [-31 -29 55]; %FSLeyes - Juelich Histological Atlas - BA4aL

VOI_definition_MNI(parent_dir, start_subj, nsubj, VOI_name, F_contr_adj, ...
    contr_index, center_vec, thr_val, sphere_rad)

cd(my_path)

%% SUPPLEMENTARY MOTOR AREA
disp('===================== SUPPLEMENTARY MOTOR AREA =====================')
VOI_name = 'SMA_L_MNI';

center_vec = [-4 -4 58]; %FSLeyes - Juelich Histological Atlas - BA6L / Harvard-OXford cortical structure: 84% SMA

sphere_rad_sma= 4; %superthin

VOI_definition_MNI(parent_dir, start_subj, nsubj, VOI_name, F_contr_adj, ...
    contr_index, center_vec, thr_val, sphere_rad_sma)

cd(my_path)

%% PREMOTOR CORTEX
disp('========================= PREMOTOR CORTEX ==========================')
VOI_name = 'PMC_L_MNI';

center_vec = [-19 -13 72]; %FSLeyes - Juelich Histological Atlas - BA6L

VOI_definition_MNI (parent_dir, start_subj, nsubj, VOI_name, F_contr_adj, ...
    contr_index, center_vec, thr_val, sphere_rad)

cd(my_path)

%% VISUAL CORTEX
disp('=========================== VISUAL CORTEX ===========================')
VOI_name = 'V1_BIL_MNI';

center_vec = [0 -96 7]; %FSLeyes - Harvard Oxford Atlas
sphere_rad_v1 = 12; %Bilateral 

VOI_definition_MNI(parent_dir, start_subj, nsubj, VOI_name, F_contr_adj, ...
    contr_index, center_vec, thr_val, sphere_rad_v1)

cd(my_path)
