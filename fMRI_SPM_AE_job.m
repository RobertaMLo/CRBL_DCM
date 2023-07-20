function [] = fMRI_SPM_AE_job(input_vols, output_dir, units, TR, slice_num, ref_slice)
% =========================================================================
% Specify FIRST LEVEL SPM.mat with batch procedure.
% =========================================================================
%
%   Input:
%   fMRI_nii:   Name of fMRI. It should be the OUTPUT OF PREPROCESSING
%   units:      String. 'scans' for Block Design, 'secs' for Event Related
%   TR:         Float. Repetition Time
%   slice_num:  Int. Number of slices (z-directions)
%   ref_slice:  Int. Reference slice. Set the same used for time-slicing
%                    according to acquisition type
%   
%   Output:
%   First level SPM.mat
% -------------------------------------------------------------------------
% 
% author: robertalorenzi
% Job saved on 09-Mar-2022 09:48:37 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
%
% version: rev.00 - Mar 09 2022
% revised by: 
% -------------------------------------------------------------------------

%cd(input_vols)

!gunzip *.nii.gz

fnames = dir('swfMRI*');                                                      
vols = {fnames.name};

scans = cell(length(vols), 1);
for ivol = 1:length(vols)
    scans{ivol} = horzcat(fullfile(pwd,vols{ivol}), ',1');
end

cd ../..


disp('I am computing the SPM.mat')
matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile(pwd, output_dir)};          % Directory where SPM.mat will be saved
matlabbatch{1}.spm.stats.fmri_spec.timing.units = units;
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = slice_num;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = ref_slice;

matlabbatch{1}.spm.stats.fmri_spec.sess.scans = scans;

matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {fullfile(output_dir,'cond4SPM.mat')};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {fullfile('Preproc_fMRI','rp_avol0000.txt')};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';


spm_jobman('run', matlabbatch);

