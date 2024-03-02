
% % Script to run single-subject VOI extraction
% % included also in the big pipeline run DCM_AE, but here easier to be
% % runned

clc
clear

work_dir = '/home/bcc/matlab/Roberta/CRBL_DCM';

disp('Here is my protocol director')

% % tried with different prptocol and it work properly!!!! :)
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND_BAR';
%protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND'

% subject to analyse
subj_vec = [2 7 8 10 12 13];
%subj_vec = 99;


% Put the name of Group masks (NOT THE ATLAS)
VOI_name_vec = {'V1_BA15115_RL', 'SPL_BA138_L', 'CC_BA117_L', 'M1_BA131_L', 'SMAPMC_BA122_L', 'CRBL_R'};
tot_voi = length(VOI_name_vec);

contr4adj = 0; % Fcontrast index
contr4act = 1; % Tcontrast index

thrs_vec = [0.05 0.001 0.05 0.05 0.05 0.001];
dim_sphere = [10 10 15 10 15];
center = [0 0 0; -34 -45 52; -3 -2 43; -40 -14 56; -6 -9 55; 25 -51 22];

dim_sphere_i = 1;



for i = 1:length(subj_vec)
    disp('*************************  Working on: *************************')
    subject = subj_vec(i);
    sub_id = sprintf('S%d',subj_vec(i))
    sub_folder = fullfile(protDir,sub_id);

    disp('=================== Subject-specific VOI extraction ===================')

    % SINGLE SUBJECT FOLDER FOR SINGLE SUBJECT SPM.mat
    disp('taking SPM.mat from: ')
    sub_folder
    
    for i_voi=1:tot_voi
        disp('VOI name: ')
        VOI_name = VOI_name_vec{i_voi}

        % LOAD THE GROUP MASK
        disp('Loading group activation mask: ')
        mask_abs_path = fullfile(protDir,'Group_analysis',horzcat('VOI_',VOI_name,'_mask.nii'))

        disp('=============================================================')
        disp('threshold: ')
        thrs = thrs_vec(i_voi)

        disp('=============================================================')
        disp('geometry and dimension: ')

        if i_voi==1
            geometry = 'box'
            dimension = [90 90 90]

        else
            dimension = dim_sphere(dim_sphere_i)
            geometry = 'sphere'
            dim_sphere_i = dim_sphere_i +1;
        end

        VOI_extraction_subjects(sub_folder, VOI_name, center(i_voi,:), contr4adj, contr4act, ...
            thrs, mask_abs_path, geometry, dimension)
    end
end
