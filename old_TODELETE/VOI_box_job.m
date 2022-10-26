%-----------------------------------------------------------------------
% Job saved on 06-Apr-2022 13:00:45 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.voi.spmmat = {'/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5/Group_analysis/SPM.mat'};
matlabbatch{1}.spm.util.voi.adjust = NaN;
matlabbatch{1}.spm.util.voi.session = 1;
matlabbatch{1}.spm.util.voi.name = 'V1_BA15115_RL22';
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.01;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {'/media/bcc/Volume/Analysis/Roberta/DCM/BAM/BAM_mask_V1_15115_RL.nii,1'};
matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.01;
matlabbatch{1}.spm.util.voi.roi{3}.box.centre = [0 0 0];
matlabbatch{1}.spm.util.voi.roi{3}.box.dim = [90 90 90];
matlabbatch{1}.spm.util.voi.roi{3}.box.move.global.spm = 1;
matlabbatch{1}.spm.util.voi.roi{3}.box.move.global.mask = 'i2';
matlabbatch{1}.spm.util.voi.expression = 'i1&i2&i3';
spm_jobman('run',matlabbatch);
