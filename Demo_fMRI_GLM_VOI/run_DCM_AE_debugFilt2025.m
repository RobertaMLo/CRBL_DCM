% % Pipeline to run the fMRI first and second level analysis for DCM
% % N.B.: Name of input image is fMRI_CovRegressed.nii.gz

% %

%% 1 -  PARAMS DEFINITION
clc
clear

%work_dir = '/home/bcc/matlab/Roberta/CRBL_DCM'; %folder where I am working

disp('Here is my protocol director')
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND'; %protocol directory where subject data are stored

tcontrast_name = 'AE_actionvsrest'; %name of the contrast I am going to define
% 
subj_vec = [2 7 8 9 10 11 12 13 14]; %% observation
%% 2 - FIRST LEVEL ANALYSIS

% % =======================================================================
% % ======================= START THE DEBUG BABE ==========================
% % =======================================================================

for i = 1:length(subj_vec)
    disp('*************************  Working on: *************************')
    subject = subj_vec(i);
    sub_id = sprintf('S%d',subj_vec(i))
    
    sub_folder = fullfile(protDir, sub_id);

    % % Need to recompute the GLM and SPM matrix --- fMRI first level
    % analysis
    %DCM_AE(protDir, sub_id, 2)

    % % Need to recompute the contrast T --- still first level analysis and
    % % needed to compute the second level fMRI analysis
    DCM_AE(protDir, sub_id, 3)
    
%     cd(sub_folder)
%     !gzip -f Preproc_fMRI/swsplits_mni2mm_25/*.nii

end

%% 3 -  SECOND LEVEL fMRI ANALYSIS -- NEEDED FOR GROUP MASK
disp('=================== Second level analysis ===================')
% % Computation of GROUP SPM.mat out of the for loop because group SPM is one
% % for all.
folderName = 'Group_analysis_25'; %where to save the output of this code. It will be created a folder into protocol direcotry

% % Upload the contrasts activation vs rest for all the subjects
sub_cont_path =  fullfile('Functional', 'stats_2025'); % relative path
sub_cont_name = 'con_0001.nii'; %name .nii -- a contrast using spm MUST have been defined

cont = 1;
for i=1:length(subj_vec)

    subject = subj_vec(i);
    sub_id = sprintf('S%d',subj_vec(i))
    sub_folder = fullfile(protDir,sub_id)
    
    if isfile( fullfile(sub_folder,sub_cont_path, sub_cont_name) )  
        contrast{cont,1} = horzcat(fullfile(sub_folder,sub_cont_path, sub_cont_name),',1');
        cont = cont+1;
    end
end

outputDir = fullfile(protDir, folderName);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

fMRI_SPM2ndLevel_jobfun_25(outputDir, contrast, tcontrast_name)

%% 4 - VOI EXTRACTION

work_dir = pwd; %matlab folder

% % OUTPUT MASK from group level mask
mask_dir = '/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND/Group_analysis_25';

VOI_name_vec = {'V1_15115_RL', 'SPL_138_L', 'CC_117_L', 'M1_131_L', 'SMAPMC_122_L', 'CRBL_R'};

contr4adj = NaN;
contr4act = 1;
center = [0 0 0];
%centerv = [-14 -94   2; -28 -52  56; -12  26  24; -40 -10  48; -28   0  50; 34 -62 -20; ] %%if non zero needed

tot_voi = length(VOI_name_vec);

%AE:
%thrs_vec = [0.01 0.001 0.01 0.001 0.001 0.001]; 

%AO:
thrs_vec = [0.05 0.001 0.05 0.05 0.05 0.001]; 

dim_sphere = [10 10 15 10 15];

         
for i = 1:length(subj_vec)
   disp('**********************************  Working on: *****************************')
    subject = subj_vec(i);
    sub_id = sprintf('S%d',subj_vec(i))
    disp ('****************************************************************************')
    stats_dir = fullfile(sub_id,'Functional/stats_2025');
    
    i_sph = 1;
    
    for i_voi=1:tot_voi
    
       VOI_name = VOI_name_vec{i_voi}
       
       %mask_name = horzcat('VOI_',VOI_name_vec{i_voi},'_mask.nii');
       if  contains('CRBL_R', VOI_name)
           mask_abs_path = fullfile(mask_dir, ['VOI_SUIT_mask_LobuleI_IVbin_' VOI_name '_mask.nii'])
       else
           mask_abs_path = fullfile(mask_dir, ['VOI_BAM_mask_' VOI_name '_mask.nii'])
       end

       unix(horzcat('gunzip ',fullfile(protDir,sub_id, 'Functional/Preproc_fMRI/swsplits_mni2mm_25/sw*')))
       
       disp('Using this mask:')
       %mask_abs_path = (fullfile(mask_dir, mask_name));
       
       disp('=============================================================')
       disp('threshold: ')
       thrs = thrs_vec(i_voi)
       
       disp('=============================================================')
       disp('geometry and dimension: ')
       
       if i_voi==1
           geometry = 'box'
           dimension = [90 90 90]
           
       else
           dimension = dim_sphere(i_sph)
           geometry = 'sphere'
            i_sph = i_sph+1;
       end

        
        %center = centerv(i_voi, :)
        VOI_extraction(fullfile(protDir, stats_dir), VOI_name, contr4adj, contr4act, ...
            thrs, mask_abs_path, geometry, center, dimension)
       
        cd(work_dir)

    end
    unix(horzcat('gzip ',fullfile(protDir,sub_id, 'Functional/Preproc_fMRI/swsplits_mni2mm_25/sw*')));
    disp ('****************************************************************************')
end




