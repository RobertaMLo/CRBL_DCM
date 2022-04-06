function []= fMRI_smooth_DCM_job(protDir, input_vols, fwhm_width)
% =========================================================================
% SMOOTHING - spm based protocol.
% =========================================================================
%-----------------------------------------------------------------------
% Job saved on 21-Mar-2022 12:40:52 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

cd(input_vols)
!gunzip -f *.nii.gz

fnames = dir('*.nii');                                                      
vols = {fnames.name};

scans = cell(length(vols), 1);
for ivol = 1:length(vols)
    scans{ivol} = horzcat(fullfile(pwd,vols{ivol}), ',1');
end

cd ../..


matlabbatch{1}.spm.spatial.smooth.data = scans ;
matlabbatch{1}.spm.spatial.smooth.fwhm = fwhm_width;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';


spm_jobman('run', matlabbatch);

mkdir('Preproc_fMRI/swsplits_mni2mm');
!mv Preproc_fMRI/wsplits_mni2mm/sw*.nii Preproc_fMRI/swsplits_mni2mm

% !gzip -f Preproc_fMRI/swsplits_mni2mm/*.nii
% !gzip -f Preproc_fMRI/wsplits_mni2mm/*.nii

 cd(protDir)

