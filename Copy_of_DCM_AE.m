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
% %      4 - Contrast definition 4 fMRI second level analysis

% ---- TO BE COMPLETED FROM HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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

function []=DCM_AE(protDir, sub_id, step)

switch step
    case 0
        %% T1 preprocessing
        % ================================================================%
        struct_prot_dir = fullfile(protDir,sub_id,'Anatomical')
        cd(struct_prot_dir)                                                                %parent directory where subject sub dirs where stored
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
                
                %%%%%% CHECK IF THIS COMMAND WORKS ON YOUR PC
                unix(horzcat('mri_nu_correct.mni --i ',...
                    t1_filename,' --o T1_preproc/T13D_nu.nii.gz --n 10 --proto-iters 500'))

                % =========================================================
                % T13D brain extraction
                % =========================================================
                disp('BET Extraction')
                % -f: optimised for these data. bigger vals = smaller bet
                !bet T1_preproc/T13D_nu T1_preproc/T13D_nu_brain -B -f 0.15
                delete T1_preproc/T13D*_mask.nii.gz
                
            end
            
        end
        
    case 1
        %% fMRI preprocessing
        % =================================================================
        funct_prot_dir = fullfile(protDir,sub_id,'Functional');
        cd(funct_prot_dir)
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
       
                
                copyfile ../Anatomical/T1_preproc/T13D_nu_brain.n*
                
                
                % WM,GM and CSF segmentations and CSF mask
                disp('...... Computing fast segmentations (actually not very fast :D)' )
                % -g option to have also binary _seg file (default=_pve)
                !fast -g T13D_nu_brain.nii.gz
                
                %copyfile ../Functional/T1_preproc/T13D_nu_brain_seg_0.nii.gz

                % _seg_0 is CSF mask output of fast
                CSF_mask_fast = 'T13D_nu_brain_seg_0.nii.gz';
            
                num_slices = 46;                                           % number of slice (z -dim3)
                TR = 2.5;                                                  % Repetition Time [s]
                nvol = 200;                                                % number of volumes acquired in time (dim 4)  
                acquisition = 3;                                           % acquisition type 3 = descending
 
                
               %cost_fun_fMRI2T1 = 'normmi';
               cost_fun_fMRI2T1 = 'corratio';
                % for AE data:
%                 sub_2_check = [2,7,9,12,13,14,22];
%                 if ismember(subject, sub_2_check)
%                     cost_fun_fMRI2T1 = 'corratio'; 
%                 end
                
                % input: TR, acquisition, n_vol, n_slices, T1_filename,
                % CSFmask, sub_id
                disp('!!!!!! Lets the functional party start babeeeeee !!!!!!! ')
               
                fMRI_preproc_corr_DCMAE(TR, acquisition, nvol, num_slices, fullfile(pwd,'T13D_nu_brain.nii.gz'), fmri_filename, fullfile(pwd,CSF_mask_fast), cost_fun_fMRI2T1);
                
                
                
                % move the segmentations into Anatomic folder
                %movefile 'T13D_nu_brain_seg_*' '../Anatomical/T1_preproc/'
                % delete un necessary files
                delete *mixeltype*
                delete *_pve*
                delete *_seg.nii.gz

            end
        end
        
    case 2
        %% fMRI 1st level analysis: NORMALIZED DATA MNI152
        sub_dir = fullfile(protDir,sub_id);
        cd(sub_dir)

        disp('I am working in:')
        pwd

        cd('Functional')

        % Normalise the data
        disp('I am Normalizing fMRI 2 MNI 2mm space')
        matlab_folder = '/home/bcc/matlab';
        native_fMRI = 'fMRI_Filtered';

        fMRI_MNI_norm_DCM(protDir, matlab_folder, native_fMRI)

        % Smooth the data
        disp('I am doing smoothing')
        input_vols = 'Preproc_fMRI/wsplits_mni2mm'; fwhm_width = [6 6 6];
        fMRI_smooth_DCM_job(protDir, input_vols, fwhm_width)
%         
        disp('Computing SPM.mat ................')
        
        stats_folder = 'stats';
        if ~isfolder(stats_folder)                                      
            mkdir(fullfile(protDir,'Functional'), stats_folder)
        end

        input_vols = 'Preproc_fMRI/swsplits_mni2mm';
%         
%         input_vols = 'Preproc_fMRI/splits'; %uncomment to use the NOT FILTERED data
%         
%         output_dir = 'stats_native'; %name stats_native if NOT NORMALIZED


        output_dir = stats_folder;
%         
        units = 'secs'; TR = 2.5; slice_num = 46; ref_slice = 23;           % Design and preproc parameters
        
        cd (input_vols)
        fMRI_SPM_AE_job(input_vols, output_dir, units, TR, slice_num, ref_slice)
        
        disp('Estimating GLM model .................')
        fMRI_SPM_AE_GLMestim_job(output_dir)
        cd(protDir)
        
        
    case 3
        %% Contrast definition 4 fMRI second level analysis
        % Contrast Definition for computif the second level SPM.mat
        % !!!!!! Mandatory case to run  fun fMRI_SPM2ndLevel_jobfun.m
        cd(protDir)
        % Define contrast:
        % choose where contrast will be saved (same directory of SPM.mat is
        % a good idea)
        disp('I am computing a contrast')
        con_name = 'action_vs_rest';
        con_vect = [1 0 0 0 0 0 0 0 0 0 0 0]; %action vs rest is beta0
        delete_bool = 1; %I keep the old contrasts
        stats_dir = 'Functional/stats';
        T_con_def(protDir, stats_dir, con_name, con_vect, delete_bool)



    case 4
        %% Run Single Subject VOI extraction
       
        disp('=================== Subject-specific VOI extraction ===================')

        % Put the name of Group masks (NOT THE ATLAS)
        VOI_name_vec = {'V1_BA15115_RL', 'SPL_BA138_L', 'CC_BA117_L', 'M1_BA131_L', 'SMAPMC_BA122_L', 'CRBL_R'};
        folder4spm_mat = 'Group_analysis';

        tot_voi = length(VOI_name_vec);

        thrs_vec = [0.05 0.05 0.05 0.05 0.05 0.05] %[0.05 0.01 0.05 0.05 0.05 0.01] %[0.3 0.3 0.3 0.3 0.3 0.3]; %[0.05 0.001 0.05 0.05 0.05 0.001];
        dim_sphere = [10 10 15 10 15];

        contr4adj = 1;
        contr4act = 1;
        center = [0 0 0; -34 -45 52; -3 -2 43; -40 -14 56; -6 -9 55; 25 -51 22];

        dim_sphere_i = 1

        for i_voi=1:tot_voi
            disp('VOI name: ')
            VOI_name = VOI_name_vec{i_voi}
            mask_abs_path = fullfile(protDir,folder4spm_mat,horzcat('VOI_',VOI_name,'_mask.nii'))
            disp('=============================================================')
            disp('threshold: ')
            thrs = thrs_vec(i_voi)

            disp('=============================================================')
            disp('geometry and dimension: ')

            if i_voi==1
                geometry = 'box'
                dimension = [90 90 90]

            else
                dimension = dim_sphere(dim_sphere_i)
                geometry = 'sphere'
                dim_sphere_i = dim_sphere_i +1;
            end

            VOI_extraction(protDir, folder4spm_mat, VOI_name, contr4adj, contr4act, ...
                thrs, mask_abs_path, geometry, center(i_voi,:), dimension)
        end
                
        
        
        
end
