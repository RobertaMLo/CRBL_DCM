% % =======================================================================
% % runs the CM_AE routine for all subjects
% % Executable file
% % =======================================================================

% DCM_AE function usage:
% DCM_AE(working_directory, subject_id, case)
% case 1 = struct preproc; case2 = funct preproc; case3 = SPM 1st level
%
% -------------------------------------------------------------------------
% If you don't need to execute the whole pipeline,
% comment and/or uncomment the step inside the for-loop
% -------------------------------------------------------------------------
% % =======================================================================

clc
clear

work_dir = '/home/bcc/matlab/Roberta/CRBL_DCM';

disp('Here is my protocol director')
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND_BAR';

% subject to analyse
subj_vec = [2 7 8 10 12 13];

% % =======================================================================
% % ======================= START THE DCM PARTY BABE ======================
% % =======================================================================

for i = 1:length(subj_vec)
    disp('*************************  Working on: *************************')
    subject = subj_vec(i);
    sub_id = sprintf('S%d',subj_vec(i))
    sub_folder = fullfile(protDir,sub_id);
%     
%     cd(fullfile(protDir,sub_id))
%     unix(horzcat('cp Functional/stats/con_0001.nii ../Group_analysis/conn_0001_',sub_id,'.nii'))  
     
 %% --------------------- Structural preprocessing ------------------------
 % % ----------------------------------------------------------------------

%    disp('=================== Structural Preprocessing ===================')
%    DCM_AE(protDir,sub_id,0)
%    cd(protDir)

 %% --------------------- Functional preprocessing ------------------------
 % % ----------------------------------------------------------------------

%    disp('=================== Functional Preprocessing ===================')
%    DCM_AE(protDir,sub_id,1)
%    cd(protDir)

 %% --------------------- First level analysis ----------------------------
%  % % ----------------------------------------------------------------------
%    disp('=================== Creation of Conditions file ===================')
%    AE_conditions_filemaker(sub_folder,'AOb', fullfile(sub_folder,'AO.mat'))
%    cd(protDir)
% 
%    disp('=================== fMRI First level analysis ===================')
%    DCM_AE(protDir,sub_id,2)
%    cd(protDir)

   %% --------------------- Contrast 4 second level analysis -----------------
   % % ----------------------------------------------------------------------
   %      disp('=================== Contrast 4 Second level analysis ===================')
   %      DCM_AE(fullfile(protDir,sub_id),subject,3)
   %

   %% -------------------- Single subject VOI extraction -----------------
   DCM_AE(protDir,sub_id,4)
   cd(protDir)
end

%% ------------------------ Second level analysis -------------------------
% % -----------------------------------------------------------------------

% disp('=================== Second level analysis ===================')
% % Computation of GROUP SPM.mat out of the for loop because group SPM is one
% % for all.
% %Declaration for second level analysis
% outputDir = fullfile(protDir,'Group_analysis');
% start_subj = subj_vec(1); nsubj = subj_vec(end);
% tcontrast_name = 'AOb_actionvsrest';
% fMRI_SPM2ndLevel_jobfun(protDir, outputDir, start_subj, nsubj, tcontrast_name)

%% ------------------------ GROUP VOI EXTRACTION --------------------------
% % -----------------------------------------------------------------------

disp('=================== Group-VOI extraction ===================')
% % Declaration for computing Group-level VOI
mask_dir = '/media/bcc/Volume/Analysis/Roberta/Atlases/BAM';
VOI_name_vec = {'BAM_mask_V1_15115_RL.nii', 'BAM_mask_SPL_138_L.nii', 'BAM_mask_CC_117_L.nii', 'BAM_mask_M1_131_L.nii', 'BAM_mask_SMAPMC_122_L.nii', 'SUIT_mask_LobuleI_IVbin_CRBL_R.nii'};
folder4spm_mat = 'Group_analysis';

tot_voi = length(VOI_name_vec);
thrs_vec = 0.3; %% for group level one threshold and one radius bigger than single subject
dim_sphere = 15;

contr4adj = 0;
contr4act = 1;
center = [0 0 0];
    
for i_voi=1:tot_voi
    disp('VOI name: ')
    VOI_name = VOI_name_vec{i_voi}
    mask_abs_path = fullfile(mask_dir, VOI_name)
    disp('=============================================================')
    disp('threshold: ')
    thrs = thrs_vec

    disp('=============================================================')
    disp('geometry and dimension: ')

    if i_voi==1
        geometry = 'box'
        dimension = [90 90 90]

    else
        dimension = dim_sphere
        geometry = 'sphere'
    end

    VOI_extraction(protDir, folder4spm_mat, VOI_name, contr4adj, contr4act, ...
        thrs, mask_abs_path, geometry, center, dimension)

    cd(work_dir)

end


% % DCM AEO ANALYSIS ------------------------------------------------------
% %
% -------------------------------------------------------------------------

for i = 1:length(subj_vec)
    disp('*************************  Working on: *************************')
    subject = subj_vec(i);
    sub_id = sprintf('S%d',subj_vec(i))
    sub_folder = fullfile(protDir,sub_id);
%% ------------------------ Subject specific VOI extraction ----------------
% % -----------------------------------------------------------------------


end









