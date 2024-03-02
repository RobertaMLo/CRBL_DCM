% % =======================================================================
% % FMRI PREPROCESSING - Tutorial 
% % =======================================================================
% %     Please run eacvh section separately and always open the outputs to
% %     to understand what you are doing :)
% %
% %                                HAVE FUN!
% %
% % -----------------------------------------------------------------------
% % authors:    MARE Lab
% % date:       Feb. 2022
% % version:    01
% % -----------------------------------------------------------------------

%% O) Setup
% Change this sections according to your paths and to your fMRI params.

workdir = pwd;                                                             % save the current path. It could be useful :)

%fmri_folder = input(...                                                   % fmri absolute path from keboard
%    'Please type the absolute path of fMRI data directory:\n ', 's');
%cd(fmri_folder)

%fmri_folder = '/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj/S5/AE/data/fMRI';
fmri_folder = '~/Desktop/S14/Functional';
cd(fmri_folder)

% To get information as the number of slices, open img with fsleyes and
% click on "I" button for all informations or use load_nifti func.
num_slices = 46;                                                           % number of slice (z -dim3)
TR = 2.5;                                                                  % Repetition Time [s]
nvol = 200;                                                                % number of volumens (dim4)

%T1path = input('Please insert the absolute path of the T1 file including the name of T1')
T1path = '~/Desktop/S14/Anatomical/T1.nii';


% Intensity correction preformed with freesurfer
T1_nu = regexprep(T1path,'.nii*', '_nu.nii.gz');
unix(horzcat('mri_nu_correct.mni --i ',T1path, ' --o ',T1_nu,' --n 10 --proto-iters 500'))

mkdir('BET')
unix(horzcat('bet ',T1_nu,' BET/T1_nu_brain -B -f 0.2 -g 0'))
delete *_mask.nii*

use_bet = true;

%% 1) MP-PCA
% Delete the noise form the raw image

filelist   = dir(fmri_folder);                                             % list of file in fmri folder
name       = {filelist.name};                                              % list of filename
name       = name(~strncmp(name, '.', 1));                                 % remove hidden files starting with . or ..
fmri_filename = name{1};                                                   % just one file saved, i.e. the fmri .nii file

preproc_folder = 'Preproc_fMRI';                                           % name of new folder to save preproc output

if ~isfolder(preproc_folder)                                               % CHECK IF PREPROC HAS BEEN ALREADY DONE
    mkdir(preproc_folder)                                                  % new folder to save the prerocessed results
    disp('MP-PCA')                                                         % disp on command window what I'm doing

    unix(horzcat('dwidenoise ',fmri_filename,' ',fullfile(preproc_folder,'fMRI_den.nii.gz'),...
            ' -noise ',fullfile(preproc_folder,'noise.nii.gz'),' -force -quiet'))
    
else
    disp('Preprocessing already done!')
end

%% 2) Slice timing
% Remove the T2 Effect.
% Remodulation as all slices were acquired in the same time instant.

cd Preproc_fMRI/
disp('Slice Timing on fMRI.')
!fslsplit fMRI_den.nii.gz vol
!gunzip vol*.nii.gz

lista=dir('vol*.nii');
for n=1:nvol,filename{1,n}=lista(n).name;end

order=[1:2:num_slices 2:2:num_slices];
TA=TR-TR/num_slices;
timing(1)=TA/(num_slices-1);
timing(2)=TR-TA;

if int16(num_slices/2)*2-num_slices==0
    ref_slice=num_slices-1;
else
    ref_slice=num_slices;
end

spm_slice_timing(filename,order,ref_slice,timing);
close all
delete vol*

!fslmerge -t afMRI_den avol*

%% 3 Realignment
% Realignment of all volumes to a mean volume to remove the subject
% movments inside the scanner

disp('Realignment of fMRI data')

lista=dir('avol*.nii');
fnms={};
for i = 1:size(lista,1)
    fnms{i} = strcat(pwd,'/',lista(i).name,',1');
end

matlabbatch{1}.spm.spatial.realign.estwrite.data={fnms'};
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch);

!fslmerge -t rafMRI_den ravol*
delete avol* ravol*

!bet meanavol0000 meanavol0000_brain -B -f 0.22 -g 0 -s

!gzip meanavol0000.nii
!gzip meanavol0000_brain

movefile meanavol0000.nii.gz ..
%movefile meanavol0000_brain.nii.gz ..


%% 4.1 Coregistration fMRI to T1
% Coregistration fMRI to T1

mkdir('Coreg')                                                                % create a folder to save coreg outout
% disp('T13D Coregistration to fMRI')


if use_bet
    disp('=== BET procedure ===')
    
    input_fmri = 'meanavol0000_brain.nii.gz';
    
    unix(horzcat('flirt -in ',input_fmri,' -ref ../BET/T1_nu_brain.nii.gz',...
     ' -o Coreg/meanfMRI2T13D_nu_brain -omat Coreg/meanfMRI2T13D_nu_brain.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12 -bins 256 -cost normmi -interp trilinear'));
 
    !convert_xfm -omat Coreg/T13D2meanfMRI_nu_brain.mat -inverse Coreg/meanfMRI2T13D_nu_brain.mat 

else
    disp('=== ALL MRI procedure ===')
    input_fmri = 'meanavol0000.nii.gz';
    
    unix(horzcat('flirt -in ',input_fmri,' -ref ',T1path,...
     ' -o Coreg/meanfMRI2T13D -omat Coreg/meanfMRI2T13D.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12 -bins 256 -cost normmi -interp trilinear'));
    
    !convert_xfm -omat Coreg/T13D2meanfMRI.mat -inverse Coreg/meanfMRI2T13D.mat
    
end

%% 4.2 T13D Normalization

disp('T13D Normalization')
% Commands to normalize T13D
% flirt = roto traslations operation, fnirt = other non linear transformation,
% invwarp = fnirt function. 
% Check on https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FAST

if use_bet
    disp('======= BET procedure =========')
   
    unix(horzcat('flirt -in ../BET/T1_nu_brain',' -ref $FSLDIR/data/standard/MNI152_T1_1mm_brain -out Coreg/T13D2MNI1mm_nu_brain -omat Coreg/T13D2MNI1mm_nu_brain.mat -bins 256 -cost normmi -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12 -interp sinc -sincwidth 9 -sincwindow hanning'));
    % ALVIN IS 2mm
    unix(horzcat('fnirt --ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain --in=','../BET/T1_nu_brain',' --aff=Coreg/T13D2MNI1mm_nu_brain.mat --config=$FSLDIR/etc/flirtsch/T1_2_MNI152_2mm.cnf --cout=Coreg/T13D_warpcoef_nu_brain.nii.gz --iout=Coreg/T13D2MNI_fnirt_nu_brain'));
    unix(horzcat('invwarp -w Coreg/T13D_warpcoef_nu_brain.nii.gz -o Coreg/MNI_warpcoef_nu_brain.nii.gz -r ../BET/T1_nu_brain'));
    
else
    %Normalisation: registration on T1 on the standard MNI space of FSL. 1 mm
    %MNI because my T1 data are 1mm resolution
    unix(horzcat('flirt -in ',T1path,' -ref $FSLDIR/data/standard/MNI152_T1_1mm -out Coreg/T13D2MNI1mm -omat Coreg/T13D2MNI1mm.mat -bins 256 -cost normmi -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -interp sinc -sincwidth 7 -sincwindow hanning'));
    
    %Non linear Transformation: Normalised image transformed on MNI 2mm
    %resolution because Alvin mask has that resolution
    unix(horzcat('fnirt --ref=$FSLDIR/data/standard/MNI152_T1_2mm --in=',T1path,' --aff=Coreg/T13D2MNI1mm.mat --config=$FSLDIR/etc/flirtsch/T1_2_MNI152_2mm.cnf --cout=Coreg/T13D_nu_warpcoef.nii.gz --iout=Coreg/T13D2MNI_fnirt'));

    unix(horzcat('invwarp -w Coreg/T13D_nu_warpcoef.nii.gz -o Coreg/MNI_warpcoef.nii.gz -r ',T1path));
end


%% 4.3 CSF extraxtion and thresholding
% CSF mask extraction and thresholding on Alvin mask to remove CSF
% pulsations (Alvin mask: ventricles mask)

disp('CSF mask creation')


% % % SEGMENTATION --------------------------------------------------------
% fast command to segment CSF.
% fast segmentations output: csf = T1name_pv0; GM = T1name_pv1;
% WM = T1name_pv2; merged segmentations _pv.

!fast BET/T1_nu_brain.nii.gz

% % % 4.2.3 CSF-ALVIN COREGISTRATION --------------------------------------

copyfile('../BET/T1_nu_brain_pve_0.nii.gz', 'Coreg');                            % copy CSF mask into Coreg folder to have all Coreg files in one directory
CSFmask = 'Coreg/T1_nu_brain_pve_0.nii.gz';                                   % save csf mask name into CSFmask variable

disp('CSF mask thresholding with Alvin mask in fMRI space')

% applywarp: application of already implemented transformation.
% e.g. -w = warp; --inter= interpolation with specified function
unix(horzcat('applywarp -i ~/matlab/Atlases/fMRI/ALVIN_mask_v1 -r ',CSFmask,' -o Coreg/Alvin2CSF -w Coreg/MNI_warpcoef_nu_brain --interp=nn'));

% thresholding and eroding to make the Alvin mask fit to my data
unix(horzcat('fslmaths ',CSFmask,' -mas Coreg/Alvin2CSF -thr 0.99 Coreg/CSF_thr'));
!fslmaths Coreg/CSF_thr -ero Coreg/CSF_thr
!flirt -in Coreg/CSF_thr -ref meanavol0000_brain -o CSF_thr2fMRI -applyxfm -init Coreg/T13D2meanfMRI.mat -interp nearestneighbour

%% 5 Nuisance regression and filtering
% Advance step (upgrade of the standard procedure)
% "Clean" fMRI data by filtering on phyisiological parameters (e.g.
% Friston24 to filter 24 "standard" movments)

disp('Nuisance regression...')
disp(pwd)

disp('1 - Define covariables')
CovariablesDef=[];
load('~/matlab/Lab/only_nuisance.mat')

disp('2 - Polynomial trend')
CovariablesDef.polort = Cfg.Covremove.PolynomialTrend;

disp('3 - Head motion correction using Friston24')
CovariablesDef.CovMat=[];
Q1=load('Preproc_fMRI/rp_avol0000.txt');
CovariablesDef.CovMat = [Q1, [zeros(1,size(Q1,2));Q1(1:end-1,:)], Q1.^2, [zeros(1,size(Q1,2));Q1(1:end-1,:)].^2];

disp('4 - compCor CSF regression')
CompCorMasks = [];
CompCorMasks =[CompCorMasks;{['CSF_thr2fMRI.nii.gz']}];
mkdir('ImgAR')
copyfile Preproc_fMRI/rafMRI_den.nii.gz ImgAR
Datadir=strcat(pwd,'/','ImgAR');

% y_CompCor_PC = DPABI function
% check on y_CompCor_PC that CUTNUMBER = 1. If is not 1, change it !!!!!!!!
[PCs] = y_CompCor_PC(Datadir,CompCorMasks, 'CompCorPCs', Cfg.Covremove.CSF.CompCorPCNum);
CovariablesDef.CovMat = [CovariablesDef.CovMat, PCs];

disp('5 - Regressing out covariates')
CovariablesDef.IsAddMeanBack = Cfg.Covremove.IsAddMeanBack;

[Covariables] = y_RegressOutImgCovariates(Datadir,CovariablesDef,'_Covremoved','');
Covariables = double(Covariables);
y_CallSave('Covariables.txt', Covariables, ' ''-ASCII'', ''-DOUBLE'',''-TABS''');
disp('... End of nuisance regression')


disp('Filtering')

Datadir=strcat(pwd,'/','ImgAR_Covremoved');
y_bandpass(Datadir, TR, Cfg.Filter.ALowPass_HighCutoff, Cfg.Filter.AHighPass_LowCutoff, Cfg.Filter.AAddMeanBack, '');

movefile ImgAR_Covremoved/CovRegressed_4DVolume.nii fMRI_CovRegressed.nii
movefile ImgAR_Covremoved_filtered/Filtered_4DVolume.nii fMRI_Filtered.nii
!gzip *.nii
!rm -r ImgAR
!rm -r ImgAR_Covremoved
!rm -r ImgAR_Covremoved_filtered
copyfile fMRI_Filtered.nii.gz .


%% 6 Compute tSNR
% Compute Temporal Signal to Noise Ratio
cd ..
mkdir SNR

!bet Preproc_fMRI/Filtered_4DVolume SNR/brain -B -f 0.22 -g 0
!fslmaths Preproc_fMRI/Filtered_4DVolume -mas SNR/brain_mask SNR/Filtered_4DVolume_brain

disp('computing tSNR')
!fslmaths SNR/Filtered_4DVolume_brain -Tmean SNR/mean
!fslmaths SNR/Filtered_4DVolume_brain -Tstd SNR/std
!fslmaths SNR/mean -div SNR/std SNR/tsnr_data
