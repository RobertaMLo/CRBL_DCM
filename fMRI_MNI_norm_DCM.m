function []= fMRI_MNI_norm_DCM(protDir, matlab_folder, native_fMRI)
% =========================================================================
% NORMALISATION - spm based protocol from Native Space to MNI Space 2mm.
% =========================================================================
% General Info:
% % warping into mni space 2 mm
% % 
% -------------------------------------------------------------------------
% Job saved on 18-Mar-2022 16:55:34 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
% -------------------------------------------------------------------------

cd('Functional')
input_split = fullfile(pwd, native_fMRI)

disp('I am splitting volumes')

mkdir('Preproc_fMRI/splits'); cd('Preproc_fMRI/splits')
unix(horzcat('fslsplit ',input_split,' ',native_fMRI))
!gunzip *.nii.gz


fnames = dir('fMRI*');                                                      
vols = {fnames.name};

scans = cell(length(vols), 1);
for ivol = 1:length(vols)
    scans{ivol} = horzcat(fullfile(pwd,vols{ivol}), ',1');
end

ref_vol = fullfile(pwd,vols{1});

cd ../..


matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {ref_vol};         %first splitted volume
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = scans;        % all splitted volumes

matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {horzcat(matlab_folder,'/spm12/tpm/TPM.nii')};
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;

%standard
% matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-80  -112  -68;
%                                                             80 76 88];                                                         


%mni 2mm
% set the bounded box of the mni reference you use
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-90 -126 -72;
                                                           90 90 108];
                                                        
%BB                                                         
% matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-94.6216  -87.1897  -15.3272;
%                                                            96.4025  110.1403  133.1264];


matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';
spm_jobman('run', matlabbatch);

mkdir('Preproc_fMRI/wsplits_mni2mm');
!mv Preproc_fMRI/splits/w*.nii Preproc_fMRI/wsplits_mni2mm
!gzip -f Preproc_fMRI/splits/f*.nii
 cd(protDir)
