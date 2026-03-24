function []=fMRI_preproc_corr_DCMAE(TR, acquisition, nvol, num_fette, T1path, fmri_filename, CSFmask, cost_fun_fMRI2T1)

%fMRI preprocessing is composed by different steps:
%1. MP-PCA: correction of thermal noise
%2. Slice-timing 
%3. Realignment
%4. Coregistration + CSF thresholding/erose with Alvin mask
%5. Nuisance regression & filtering (da DPABI)
%6. Calculation of tSNR and (MAYBE) SFNR 

% FORMAT []=fMRI_preproc_corr(TR,nvol,num_fette,T1path,CSFmask)
% _________________________________________________________________________
% INPUT:
%   TR               - Repetition Time in seconds
%   acquisition      - Type of acquisition (1 = interleaved; 2 = ascending;
%                      3 = descending)
%   nvol             - Phase-encoding direction of the DWI images
%   num_fette        - Number of slices of fMRI data
%   T1path           - full path of the T1 image
%   fmri_filename    - full path of fmri image
%   CSFmask          - full path of the CSF mask that must be in T1 space
%   cost_fun_fMRI2T1 - string. FSL cost function name for fMRI 2 T1 reg.
% 
% OUTPUT:
%   Preproc_fMRI     - folder containing all results of each step
%   SNR              - folder containing tSNR/SFNR data 



        
% =======================================================================
%     1 - MP-PCA
% =======================================================================
    preproc_folder = 'Preproc_fMRI';                                           % name of new folder to save preproc output

    if ~isfolder(preproc_folder)                                               % CHECK IF PREPROC HAS BEEN ALREADY DONE
        mkdir(preproc_folder)                                                  % new folder to save the prerocessed results
        disp('MP-PCA')                                                         % disp on command window what I'm doing
    
        unix(horzcat('dwidenoise ',fmri_filename,' ',fullfile(preproc_folder,'fMRI_den.nii.gz'),...
        ' -noise ',fullfile(preproc_folder,'noise.nii.gz'),' -force -quiet'))
    
    else
     disp('Preprocessing already done!')
       %exit;
    end
% % =======================================================================
% %     2. - Slice-timing 
% % =======================================================================
    cd Preproc_fMRI/
    disp('Slice Timing on fMRI.')
    !fslsplit fMRI_den.nii.gz vol
    !gunzip -f vol*.nii.gz

    lista=dir('vol*.nii');
    for n=1:nvol,filename{1,n}=lista(n).name;end
    TA=TR-TR/num_fette;
    tempo(1)=TA/(num_fette-1);
    tempo(2)=TR-TA;

    switch acquisition
        case 1 % interleaved
            disp('Acquisition type = interleaved')
            
            % slices order
            ordine =[1:2:num_fette 2:2:num_fette];
            
            % reference slice = last slice (even #slice = last-1, odd
            % #slice = last)
            if rem(num_fette,2) == 0
                ref_fetta=num_fette-1;
            else
                ref_fetta=num_fette;
            end

        case 2 % ascending
            disp('Acquisition type = ascending')
            
            %slice order
            ordine = 1:num_fette;
            
            %reference slice = middle slice
            ref_fetta = round(num_fette/2);
            
        case 3 % descending
            disp('Acquisition type = descending')
            
            %slice order
            ordine = num_fette:-1:1;
            
            %reference slice = middle slice
            ref_fetta = round(num_fette/2);      
    end

    spm_slice_timing(filename,ordine,ref_fetta,tempo); 
    close all  
    delete vol*

    !fslmerge -t afMRI_den avol*                 
% 
% % =======================================================================
% %     3. - Realignment
% % =======================================================================
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
    
    mkdir splits
    movefile ravol* splits
    
    delete avol*
    !gzip -f meanavol0000.nii
    movefile meanavol0000.nii.gz ..
% 
% =======================================================================
%     4. - Coregistration + CSF thresholding/erose with Alvin mask
% =======================================================================
   mkdir Coreg
    disp('Coregistration of fMRI on T1')
    
    % BET-based procedure. Compute also the BET of the fMRI meanvol
     if strfind(T1path,'_brain')~=0
         disp('no bet!!! I compute it')
        
        % Extract the BET from the meanavol of fMRI.
        % OUTPUT: betted fMRI mean volume
         !bet ../meanavol0000 meanavol0000_brain -f 0.22 -g 0
        
        % Coregistratuon fMRI on T1.
        % OUTPUT: Coreg/meanfMRI2T13D --> fmri co-registered onto T1

       unix(horzcat('flirt -in meanavol0000_brain.nii.gz -ref ',...
            T1path,' -o Coreg/meanfMRI2T13D -omat Coreg/meanfMRI2T13D.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12 -bins 256 -cost ',cost_fun_fMRI2T1,' -interp trilinear'));
        !convert_xfm -omat Coreg/T13D2meanfMRI.mat -inverse Coreg/meanfMRI2T13D.mat
        
        disp('T13D Normalization')
%       Normalization on MNI space.
%       OUTPUT: Coreg/T13D2MNI1mm
        unix(horzcat('flirt -in ',T1path,' -ref $FSLDIR/data/standard/MNI152_T1_1mm_brain -out Coreg/T13D2MNI1mm -omat Coreg/T13D2MNI1mm.mat -bins 256 -cost normmi -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12 -interp sinc -sincwidth 7 -sincwindow hanning'));
%       Coregistration on 2mm MMI because Alvin is a 2 mm atlas.
        unix(horzcat('fnirt --ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain --in=',T1path,' --aff=Coreg/T13D2MNI1mm.mat --config=$FSLDIR/etc/flirtsch/T1_2_MNI152_2mm.cnf --cout=Coreg/T13D_nu_warpcoef.nii.gz --iout=Coreg/T13D2MNI_fnirt'));
%       Transformation field to go back to the Native space
        unix(horzcat('invwarp -w Coreg/T13D_nu_warpcoef.nii.gz -o Coreg/MNI_warpcoef.nii.gz -r ',T1path));
    
   % All-MRI procedure. Use the whole T1 and fMRI (Steps commented above)
    else
        unix(horzcat('flirt -in ../meanavol0000.nii.gz -ref ',T1path,' -o Coreg/meanfMRI2T13D -omat Coreg/meanfMRI2T13D.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12 -bins 256 -cost normmi -interp trilinear'));
        !convert_xfm -omat Coreg/T13D2meanfMRI.mat -inverse Coreg/meanfMRI2T13D.mat
        disp('T13D Normalization')
        unix(horzcat('flirt -in ',T1path,' -ref $FSLDIR/data/standard/MNI152_T1_1mm -out Coreg/T13D2MNI1mm -omat Coreg/T13D2MNI1mm.mat -bins 256 -cost normmi -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12 -interp sinc -sincwidth 7 -sincwindow hanning'));
        unix(horzcat('fnirt --ref=$FSLDIR/data/standard/MNI152_T1_2mm --in=',T1path,' --aff=Coreg/T13D2MNI1mm.mat --config=$FSLDIR/etc/flirtsch/T1_2_MNI152_2mm.cnf --cout=Coreg/T13D_nu_warpcoef.nii.gz --iout=Coreg/T13D2MNI_fnirt'));
        unix(horzcat('invwarp -w Coreg/T13D_nu_warpcoef.nii.gz -o Coreg/MNI_warpcoef.nii.gz -r ',T1path));
    end

    disp('CSF mask thresholding with Alvin mask in fMRI space')
    unix(horzcat('applywarp -i ~/matlab/Atlases/fMRI/ALVIN_mask_v1 -r ',CSFmask,' -o Coreg/Alvin2CSF -w Coreg/MNI_warpcoef --interp=nn'));
    unix(horzcat('fslmaths ',CSFmask,' -mas Coreg/Alvin2CSF -thr 0.99 Coreg/CSF_thr'));
    !fslmaths Coreg/CSF_thr -ero Coreg/CSF_thr
    !flirt -in Coreg/CSF_thr -ref ../meanavol0000 -o CSF_thr2fMRI -applyxfm -init Coreg/T13D2meanfMRI.mat -interp nearestneighbour

% =======================================================================
%      5 - Nuisance regression & Filtering
% =======================================================================
    disp('Nuisance regression...')
    disp(pwd) 

    disp('1 - Define covariables')
    CovariablesDef=[];
    load('~/matlab/Lab/only_nuisance.mat')

    disp('2 - Polynomial trend')
    CovariablesDef.polort = Cfg.Covremove.PolynomialTrend;

    disp('3 - Head motion correction using Friston24')
    CovariablesDef.CovMat=[];
    Q1=load('rp_avol0000.txt');
    CovariablesDef.CovMat = [Q1, [zeros(1,size(Q1,2));Q1(1:end-1,:)], Q1.^2, [zeros(1,size(Q1,2));Q1(1:end-1,:)].^2];

    disp('4 - compCor CSF regression')
    CompCorMasks = [];
    CompCorMasks =[CompCorMasks;{['CSF_thr2fMRI.nii.gz']}];
    mkdir('ImgAR')
    copyfile rafMRI_den.nii.gz ImgAR
    Datadir=strcat(pwd,'/','ImgAR');
    %y_CompCor from DPABI
    % check on y_CompCor_PC that CUTNUMBER = 1. If is not 1, change it !!!!!!!!
    disp('-------------------------------------------ATTENTION!!!! If Error in y_CompCor, please change CUTNUMBER =1 ')
    disp('IF CUTNUMBER = 1, CHECK THE COREGISTRATIONS, SOMETHING COULD BE WRONG (EMPTY IMAGES)')
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
    !gzip -f *.nii
    !rm -r ImgAR
    !rm -r ImgAR_Covremoved
    !rm -r ImgAR_Covremoved_filtered
    copyfile fMRI_Filtered.nii.gz ..
   
% =======================================================================
%     6 - Computing tSNR and SFNR
% =======================================================================
    cd ..
    mkdir SNR

    !bet Preproc_fMRI/fMRI_Filtered SNR/brain -B -f 0.22 -g 0
    !fslmaths Preproc_fMRI/fMRI_Filtered -mas SNR/brain_mask SNR/Filtered_4DVolume_brain 

    disp('computing tSNR')       
    !fslmaths SNR/Filtered_4DVolume_brain -Tmean SNR/mean 
    !fslmaths SNR/Filtered_4DVolume_brain -Tstd SNR/std
    !fslmaths SNR/mean -div SNR/std SNR/tsnr_data 

%                  disp('computing SFNR') 
%                  !fslmeants -i SNR/Filtered_4DVolume_brain -o SNR/average.txt          
%                  %modificare in modo appropriato design.fsf e incollarlo
%                  %nella directory d'interesse prima di lanciare lo script
%                  !feat SNR/design.fsf
%                  !fslmaths ../ImgAR_Covremoved_filtered.feat/mean_func.nii.gz -mul ../ImgAR_Covremoved_filtered.feat/mean_func.nii.gz -div ../ImgAR_Covremoved_filtered.feat/stats/sigmasquareds.nii.gz -sqrt SNR/SFNR_data                 
            
end
