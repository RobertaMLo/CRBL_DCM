function [] = fMRI_SPM_AE_GLMestim_job(output_dir)
% =========================================================================
% Estimate FIRST LEVEL GLM with batch procedure.
% =========================================================================
%   GLM: Yi = const + beta*X
%   Output:
%   beta_XXX.nii: nii image for each weight beta.
% -------------------------------------------------------------------------
% 
% author: robertalorenzi
%-----------------------------------------------------------------------
% Job saved on 17-Mar-2022 17:51:36 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% version: rev.00 - Mar 17 2022
% revised by: 
% -------------------------------------------------------------------------


matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(output_dir,'SPM.mat')};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run', matlabbatch);
