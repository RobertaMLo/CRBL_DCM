clc
clear

%directory where the .m file is stored
work_dir = pwd; %matlab folder

disp('Here is my protocol director')
%DIR....
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5';

mask_dir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5/Group_analysis';

% subject to analyse
subj_vec1=[1:3];
subj_vec2=[5:20];
subj_vec3=[22:23];
subj_vec = [subj_vec1 subj_vec2 subj_vec3];

tot_voi = 6;
contr4adj = 2;
contr4act = 1;
center = [0 0 0];

VOI_name_vec = {'V1_BA15115_RL', 'SPL_138_L', 'CC_BA117_L', 'M1_BA131_L', 'SMAPMC_BA122_L', 'CRBL_R'};

thrs_vec = [0.01, 0.001, 0.01, 0.001, 0.001, 0.001];
dim_sphere = [10, 10, 15, 10, 15];

         


for i = 1:length(subj_vec)
    disp('**********************************  Working on: *****************************')
    subject = subj_vec(i);
    sub_id = sprintf('S%d',subj_vec(i))
    disp ('****************************************************************************')
    stats_dir = fullfile(sub_id,'Functional/stats');
    
    i_sph = 1;
    
    for i_voi=1:tot_voi
    
       VOI_name = VOI_name_vec{i_voi}
       
       mask_name = horzcat('VOI_',VOI_name_vec{i_voi},'_mask.nii');
       
       disp('Using this mask:')
       mask_abs_path = (fullfile(mask_dir, mask_name));
       
       disp('=============================================================')
       disp('threshold: ')
       thrs = thrs_vec(i_voi)
       
       disp('=============================================================')
       disp('geometry and dimension: ')
       
       if i_voi == 1
           geometry = 'box'
           dimension = [90 90 90]
           
       else
           geometry = 'sphere'
           dimension = dim_sphere(i_sph)
            i_sph = i_sph+1;
       end
          
        VOI_extraction(protDir, stats_dir, VOI_name, contr4adj, contr4act, ...
            thrs, mask_abs_path, geometry, center, dimension)
        
        cd(work_dir)

    end
    disp ('****************************************************************************')
    
end