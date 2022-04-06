% =========================================================================
% SECOND LEVEL ANALYSIS FOR DCM AE_UCL PROTOCOL
% =========================================================================
% % Executable file.
% % Tested Effect : Action vs Rest
% % Input:  Subject-to-start; number of subjects to analyse; T1 contast
% %         image.
% % Output: SPM.mat
%--------------------------------------------------------------------------
% Job saved on 28-Mar-2022 11:56:22 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%--------------------------------------------------------------------------
clc; clear; close all

start_subj = 1;
nsubj = 23;

protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5';
outputDir = fullfile(protDir,'Group_analysis');

cont = 1;

for subject=start_subj:nsubj
    
    name = sprintf('S%d',subject);
    
    if isfolder( fullfile(protDir,name,'Functional','stats') )  
        contrast{cont,1} = horzcat(fullfile(protDir,name,'Functional','stats','con_0001.nii'),',1');
        cont = cont+1;
    end
end

% % MODEL SPECIFICATION ----------------------------------------------------
matlabbatch{1}.spm.stats.factorial_design.dir = {outputDir};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = contrast;

% optios set at standard values
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};

% leave these options as they are because they are for PET and VBM - NOT
% for fMRI
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;


% % MODEL ESTIMATION ------------------------------------------------------
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(outputDir, 'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


% % GROUP CONTRAST DEFINITION ---------------------------------------------
matlabbatch{3}.spm.stats.con.spmmat = {fullfile(outputDir,'SPM.mat')};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'AE_vs_rest_group';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0; %don't delete pre-existent contrast

spm_jobman('run',matlabbatch);
