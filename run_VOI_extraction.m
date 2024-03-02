clc
clear

%directory where the .m file is stored
%work_dir = pwd; %matlab folder
work_dir = '/home/bcc/matlab/Roberta/CRBL_DCM'
disp('Here is my protocol director')

% % protcol DIR....
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND_BAR';

% % OUTPUT MASK ===========================================================
% % mask dir : uncomment the right option
% % Subject-specific mask

mask_dir = '/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND/Group_analysis';
%VOI_name_vec = {'VOI_BAM_mask_V1_15115_RL_mask.nii', 'VOI_BAM_mask_SPL_138_L_mask.nii', 'VOI_BAM_mask_CC_117_L_mask.nii', 'VOI_BAM_mask_M1_131_L_mask.nii', 'VOI_BAM_mask_SMAPMC_122_L_mask.nii', 'VOI_SUIT_mask_LobuleI_IVbin_CRBL_R_mask.nii'};

% % Group - level mask
%mask_dir = '/media/bcc/Volume/Analysis/Roberta/Atlases/BAM';
VOI_name_vec = {'VOI_V1_BA15115_RL_mask.nii', 'VOI_SPL_BA138_L_mask.nii', 'VOI_CC_BA117_L_mask.nii', 'VOI_M1_BA131_L_mask.nii', 'VOI_SMAPMC_BA122_L_mask.nii', 'VOI_CRBL_R_mask.nii'};
%VOI_name_vec = {'BAM_mask_V1_15115_RL.nii', 'BAM_mask_SPL_138_L.nii', 'BAM_mask_CC_117_L.nii', 'BAM_mask_M1_131_L.nii', 'BAM_mask_SMAPMC_122_L.nii', 'SUIT_mask_LobuleI_IVbin_CRBL_R.nii'};


% subject to analyse
subj_vec = [2 7 8 10:14];

contr4adj = 0;
contr4act = 1;
center = [0 0 0];
%centerv = [-14 -94   2; -28 -52  56; -12  26  24; -40 -10  48; -28   0  50; 34 -62 -20; ] %%if non zero needed

tot_voi = length(VOI_name_vec);

thrs_vec = [0.05 0.001 0.05 0.05 0.05 0.001]; %[0.05 0.01 0.05 0.05 0.05 0.01] %[0.3 0.3 0.3 0.3 0.3 0.3]; %[0.05 0.001 0.05 0.05 0.05 0.001];
dim_sphere = [10 10 15 10 15];

         
for i = 1:length(subj_vec)
   disp('**********************************  Working on: *****************************')
    subject = subj_vec(i);
    sub_id = sprintf('S%d',subj_vec(i))
    disp ('****************************************************************************')
    stats_dir = fullfile(sub_id,'Functional/stats');
    
    i_sph = 1;
    
    for i_voi=1:tot_voi
    
       VOI_name = VOI_name_vec{i_voi}
       
       %mask_name = horzcat('VOI_',VOI_name_vec{i_voi},'_mask.nii');
       mask_abs_path = fullfile(mask_dir, VOI_name)
       
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
        VOI_extraction(protDir, stats_dir, VOI_name, contr4adj, contr4act, ...
            thrs, mask_abs_path, geometry, center, dimension)
        
        cd(work_dir)

    end
    disp ('****************************************************************************')
    
end