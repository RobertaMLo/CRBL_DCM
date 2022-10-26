% % =======================================================================
% % PIPELINE FOR DCM ANALYSIS OF VISUOMOTOR TASK
% % =======================================================================
% %   usage
% %     DCM_AE(<complete path of the protocol folder containing data>,<number of the step>)
% %
% %     DATA ORGANIZATION:
% %     - Organize MRI data in folder per subject named with a UNIQUE ID
% %       e.g.: S1
% %     - Inside each subject folder keep the SAME DIRECTORY STRUCTURE
% %       e.g.: S1/Anatomical
% %     - Inside each subfolder save JUST ONE .nii IMAGE
% %       e.g.: S1/Anantomical/T13dimage.nii
% %     
% %     cases
% %      1 - T1 Preprocessing:
% %          Intensity corrections and BET extraction.
% %          input:
% %                 T13D.nii(.gz) image
% %          output: 
% %                 Folder: Preproc_T1 inside "Anatomical" parent directory
% %                         with following images:
% %                             T13D_nu.nii.gz: normalized intensity
% %                             T13D_nu_brain.nii.gz: BET
% %
% %      2 - fMRI Preprocessing: 
% %          code returns three new folders per subject with the structure:
% %          Preproc: results of the preprocessing steps until the creation
% %                   of eddy_corrected_data.nii.gz
% %          DTI: b0/DTI maps in diffusion and T13D space. Also the
% %               registration matrix (nodif2T13D.mat) between diff&T13D 
% %               space is included
% %          CSD_Tract: results of MRtrix preprocessing including T13D
% %                     segmentation (5TT.nii.gz) and fibre orientation 
% %                     distribution (WM_FODs.nii.gz) per voxel
% %      3 - fMRI 1st Level Analysis:
% %      4 - fMRI 2nd Level Analysis ---- TO BE COMPLETED FROM HERE
% %          tracts selection
% %      5 - VOI Definition and Extraction
% %      6 - DCM Models Definition
% %      7 - DCM Models Inversion
% %      8 - DCM Models Analysis (BMS with FFX, RFX, PEB, BPA,... TO BE
% %          DEFINED)
% %
% % =======================================================================
% %________________________________________________________________________
% % Author: Roberta Lorenzi
% % Release: 1.0
% % Date: 9th Feb 2022
% %________________________________________________________________________

function []=DCM_AE(protDir, subject, step)

switch step
    case 0
        %% T1 preprocessing
        % ================================================================%
        cd(protDir)                                                                %parent directory where subject sub dirs where stored
        directory
        szdirlist=size(dirlist,2);                                         
        for pat=1:szdirlist                                                        % loop on directory tree look for anatomical folder called "Anatomic"
            [~,t1,~]=fileparts(dirlist{pat});
            if strcmp(t1,'Anatomical')==1
                cd(dirlist{pat})
                disp(pwd)
                
                filelist    = dir(pwd);                                             % list of file in fmri folder
                name        = {filelist.name};                                      % list of filename
                name        = name(~strncmp(name, '.', 1));                        % remove hidden files starting with . or ..
                t1_filename = name{1};                                              % just one file must be saved here, i.e. T13D.nii.gz
                
                % =========================================================
                % T13D intensity normalization
                % =========================================================
                disp('T13D non-uniform intensity normalization')
                
                mkdir('T1_preproc')
                
                unix(horzcat('mri_nu_correct.mni --i ',...
                    t1_filename,' --o T1_preproc/T13D_nu.nii.gz --n 10 --proto-iters 500'))

                % =========================================================
                % T13D brain extraction
                % =========================================================
                disp('BET Extraction')
                % -f: optimised for these data. bigger vals = smaller bet
                !bet T1_preproc/T13D_nu T1_preproc/T13D_nu_brain -B -f 0.2
                delete T1_preproc/T13D*_mask.nii.gz
                
            end
            
        end
        
    case 1
        %% fMRI preprocessing
        % =================================================================
        cd(protDir)
        directory
        szdirlist=size(dirlist,2);
        for pat=1:szdirlist
            [~,fmri,~]=fileparts(dirlist{pat});
            if strcmp(fmri,'Functional')==1
                cd(dirlist{pat})
                disp(pwd)
                
                filelist    = dir(pwd);
                name        = {filelist.name};
                name        = name(~strncmp(name, '.', 1));
                fmri_filename = name{1}
       
                
                copyfile ../Anatomical/T1_preproc/T13D_nu_brain.nii.gz
                copyfile ../Anatomical/T1_preproc/T13D_nu_brain_seg_0.nii.gz
%                 
%                 % WM,GM and CSF segmentations and CSF mask
%                 disp('...... Computing fast segmentations (actually not very fast :D)' )
%                 !fast -g T13D_nu_brain.nii.gz
                
                % _seg_0 is CSF mask output of fast
                CSF_mask_fast = 'T13D_nu_brain_seg_0.nii.gz';
                
                num_slices = 46;                                           % number of slice (z -dim3)
                TR = 2.5;                                                  % Repetition Time [s]
                nvol = 200;                                                % number of volumes acquired in time (dim 4)  
                acquisition = 3;                                           % acquisition type 3 = descending
 
                
                cost_fun_fMRI2T1 = 'normmi';
                sub_2_check = [2,7,9,12,13,14,22];
                if ismember(subject, sub_2_check)
                    cost_fun_fMRI2T1 = 'corratio'; 
                end
                
                % input: TR, acquisition, n_vol, n_slices, T1_filename,
                % CSFmask, sub_id
                disp('!!!!!! Lets the functional party start babeeeeee !!!!!!! ')
                fMRI_preproc_corr_DCMAE(TR, acquisition, nvol, num_slices,...
                     fullfile(pwd,'T13D_nu_brain.nii.gz'), fmri_filename, fullfile(pwd,CSF_mask_fast), cost_fun_fMRI2T1);
                
                
                
                % move the segmentations into Anatomic folder
                
%                 movefile 'T13D_nu_brain_seg_*' '../Anatomical/T1_preproc/'
%                 % delete un necessary files
%                 delete *mixeltype*
%                 delete *_pve*
%                 delete *_seg.nii.gz

%%%% ADD GROUP SPM.mat CASE 4: include NORM!!!!!!
%                 % fMRI Normalization to MNI space.
%                 % OUTPUT: Coreg/T13D2MNI2mm
%                 unix(horzcat('flirt -in ',fmri,' -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain -out Coreg/T13D2MNI1mm -omat Coreg/T13D2MNI1mm.mat -bins 256 -cost normmi -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12 -interp nearestneighbours'));
%                 % Coregistration on 2mm MMI because Alvin is a 2 mm atlas.
%                 unix(horzcat('fnirt --ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain --in=',fmri,' --aff=Coreg/T13D2MNI1mm.mat --config=$FSLDIR/etc/flirtsch/T1_2_MNI152_2mm.cnf --cout=Coreg/T13D_nu_warpcoef.nii.gz --iout=Coreg/T13D2MNI_fnirt --interp=nn'));
% 
%                 % fMRI Normalization to MNI space.
%                 % OUTPUT: Coreg/T13D2MNI2mm
%                 unix(horzcat('flirt -in ',fmri,' -ref ',T1path,' -o Coreg/FilteredfMRI2T13D -applyxfm -init Coreg/meanfMRI2T13D.mat -interp trilinear'));
%                 applywarp -i meanfMRI2T13D -o aaaaa -r /usr/share/fsl/6.0/data/standard/MNI152_T1_2mm -w T13D_nu_warpcoef --interp=nn

            end
        end
        
    case 2
        %% fMRI 1st level analysis
        cd(protDir)
        
%         % Normalise the data
%         disp('I am Normalizing fMRI 2 MNI 2mm space')
%         matlab_folder = '/home/bcc/matlab';
%         native_fMRI = 'fMRI_Filtered.nii';
%         fMRI_MNI_norm_DCM(protDir, matlab_folder, native_fMRI)
%         
%         % Smooth the data
%         disp('I am doing smoothing')
%         input_vols = 'Functional/Preproc_fMRI/wsplits_mni2mm'; fwhm_width = [6 6 6];
%         fMRI_smooth_DCM_job(protDir, input_vols, fwhm_width)
        
%         % Create a conditions file to compute the SPM.mat
%         disp('Creating a conditions file for SPM computation ')
%         
%         file_mat = dir('*.mat');                                           % raw condition file MUST be the only .mat file saved 
%                                                                            % inside the subject folder
%         
%         disp('Loading task file................')
%         file_mat = file_mat.name
% 
%         load(file_mat);
%         
%         %MAYBE THIS PART DELETE FROM THE PIPELINE. SPECIFIC FOR ADNAN AND
%         %LETI DATA. FROM NOW I USE THE NEW FILES 4 CONDITIONS
%         %Leti data: from 1 to 14
%         %Adnan data: from 15 to end
%         % 13: typo Error
%         % 15 & 16 different names
%         if subject <= 12 || subject == 14 || subject >= 18 || subject == 21                                              
%             AE_conditions_filemaker(file_mat, cue.SqueezeANDHOLD)
%         elseif subject == 13
%             AE_conditions_filemaker(file_mat, cue.SqueezeANHOLD)
%         elseif subject == 15
%             AE_conditions_filemaker(file_mat, SqueezeANDHOLD_S1_P5R)
%         elseif subject == 16
%             AE_conditions_filemaker(file_mat, SqueezeANDHOLD_S2_P5R)
%         else                                                               
%            AE_conditions_filemaker(file_mat, SqueezeANDHOLD)
%         end
%         
% %         stats_folder = 'Functional/stats'
% %         if ~isfolder(stats_folder):                                      
% %             mkdir(fullfile(prot_dir,'Functional'), stats_folder)
% %         end
 
        
        disp('Computing SPM.mat ................')
        %input_vols = 'Functional/Preproc_fMRI/swsplits_mni2mm';
        cd('Functional')
        
        input_vols = 'Preproc_fMRI/splits';
        output_dir = 'stats_native';
        
        units = 'secs'; TR = 2.5; slice_num = 46; ref_slice = 23;           % Design and preproc parameters
        
        fMRI_SPM_AE_job(input_vols, output_dir, units, TR, slice_num, ref_slice)
        
        disp('Estimating GLM model .................')
        fMRI_SPM_AE_GLMestim_job(output_dir)
        
        
    case 3
        %% fMRI second level analysis
        cd(protDir)
        % Define contrast:
        % choose where contrast will be saved (same directory of SPM.mat is
        % a good idea)
        disp('I am computing a contrast')
        con_name = 'action_vs_rest';
        con_vect = [1 0 0 0 0 0 0 0 0 0 0 0]; %action vs rest is beta0
        delete_bool = 1; %I keep old contrasts
        stats_dir = 'Functional/stats';
        T_con_def(stats_dir, con_name, con_vect, delete_bool)
        

    end
        
        
        
        
%                cond_name = AE
%                num_slices = 46;                                           % number of slice (z -dim3)
%                TR = 2.5;                                                  % Repetition Time [s]
%                ref_slice = 23;
%                SPMmat4DCM(protDir, TR, num_slices, ref_slice, cond_name)  
                
        
        
        
end
