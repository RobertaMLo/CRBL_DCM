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

work_dir = pwd; %matlab folder

disp('Here is my protocol director')
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5';

% subject to analyse
subj_vec1=[1:3];
subj_vec2=[5:20];
subj_vec3=[22:23];
subj_vec = [subj_vec1 subj_vec2 subj_vec3];

for i = 1:length(subj_vec)
    disp('*************************  Working on: *************************')
    subject = subj_vec(i)
    sub_id = sprintf('S%d',subj_vec(i))
%     
%     cd(fullfile(protDir,sub_id))
%     unix(horzcat('cp Functional/stats/con_0001.nii ../Group_analysis/conn_0001_',sub_id,'.nii'))  
%     

%     disp('=================== Structural Preprocessing ===================')
%     struct_prot_dir = fullfile(sub_parent_dir,sub_id,'Anatomical')
%     
%     DCM_AE(struct_prot_dir,subject,0)
%     cd(work_dir)
    
%     disp('=================== Functional Preprocessing ===================')
%     funct_prot_dir = fullfile(sub_parent_dir,sub_id,'Functional')
%     DCM_AE(funct_prot_dir,subject,1)
%     cd(work_dir)
%     
%     disp('=================== fMRI First level analysis ===================')
%     DCM_AE(fullfile(sub_parent_dir,sub_id),subject,2)
%     cd(work_dir)
% 
     disp('=================== fMRI Second level analysis ===================')
     DCM_AE(fullfile(protDir,sub_id),subject,3)
    
end