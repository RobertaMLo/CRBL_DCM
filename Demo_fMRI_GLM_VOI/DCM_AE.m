% % =======================================================================
% % PIPELINE FOR DCM ANALYSIS OF VISUOMOTOR TASK
% % 
% % By using this pipeline you agree:
% %
% % i)  to cite our work: Lorenzi RM, Korkmaz G, Alahmadi AAS, Monteverdi A, Casiraghi L, 
% % D'Angelo E, Palesi F, Gandini Wheeler-Kingshott CAM. 
% % Cerebellar control over inter-regional excitatory/inhibitory dynamics discriminates execution
% % from observation of an action. 
% % Cerebellum. 2025 Jun 16;24(4):115. doi: 10.1007/s12311-025-01863-6.
% %
% % ii) to collaborate with Dr. Roberta M. Lorenzi, Dr. Gokce Korkmaz, Prof. Fulvia Palesi, 
% %     Prof. Egidio D'Angelo, and  Prof. Claudia Gandini Wheeler Kingshott
% %
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
% %     cases:
% %     --------------------------------------------------------------
% %      0 - T1 Preprocessing:
% %          Intensity corrections and BET extraction.
% %          input:
% %                 T13D.nii(.gz) image
% %          output: 
% %                 Folder: Preproc_T1 inside "Anatomical" parent directory
% %                         with following images:
% %                             T13D_nu.nii.gz: normalized intensity
% %                             T13D_nu_brain.nii.gz: BET
% %
% %      --------------------------------------------------------------
% %      1 - fMRI Preprocessing: 
% %          code returns three new folders per subject with the structure:
% %          Preproc: results of the preprocessing steps until the creation
% %                   of eddy_corrected_data.nii.gz
% %          DTI: b0/DTI maps in diffusion and T13D space. Also the
% %               registration matrix (nodif2T13D.mat) between diff&T13D 
% %               space is included
% %          CSD_Tract: results of MRtrix preprocessing including T13D
% %                     segmentation (5TT.nii.gz) and fibre orientation 
% %                     distribution (WM_FODs.nii.gz) per voxel
% %
% %     --------------------------------------------------------------
% %      2 - fMRI 1st Level Analysis:
% %           2.1 - Normalization
% %           2.2 - Smoothing
% %           2.3 - GLM
% %           Output: SPM.mat
% %
% %      --------------------------------------------------------------
% %     3 - Contrast definition:
% %         Definition of T and/or F contrast to extract the activation.
% %         Here it is set up for T contrast, for f contrast uncommment the
% %         correspondant matlab function
% %
% %     --------------------------------------------------------------
% %	     4 - fMRI 2nd level analysis.
% %          TO RUN THIS CASE, THE CASE 2 MUST BE RUNNED BEFORE.
% %           Output: group level SPM.mat
% %
% %     --------------------------------------------------------------
% %	     5 - VOI extraction: subject level.
% %         Extraction of Subject specific VOI. N.B. TO RUN THIS CASE IT
% %         MUST BE RUNNED THE GROUP LEVEL VOI EXTRACTION accordingly to
% %         Lorenzi et al., 2025
% %________________________________________________________________________
% % Author: Roberta Lorenzi
% % Release: 1.0
% % Date: 9th Feb 2022 
% % Last update : 9 Oct 2025
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
            
                num_slices = 46;                                      % number of slice (z -dim3)
                TR = 2.5;                                                  % Repetition Time [s]
                nvol = 200;                                               % number of volumes acquired in time (dim 4)  
                acquisition = 3;                                         % acquisition type 3 = descending
 
                
               %cost_fun_fMRI2T1 = 'normmi';
               cost_fun_fMRI2T1 = 'corratio';
                
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

        native_fMRI = 'fMRI_CovRegressed'; 

        
        fMRI_MNI_norm_DCM(protDir, matlab_folder, native_fMRI)
        
        % Smooth the data
        disp('I am doing smoothing')
        input_vols = 'Preproc_fMRI/wsplits_mni2mm_25';
        fwhm_width = [6 6 6];
        fMRI_smooth_DCM_job(protDir, input_vols, fwhm_width)
            

        disp('Computing SPM.mat ................')
        
        %stats_folder = 'stats';
        stats_folder = 'stats_2025'
        if ~isfolder(stats_folder)                                      
            mkdir(fullfile(protDir,'Functional'), stats_folder)
        end

        input_vols = 'Preproc_fMRI/swsplits_mni2mm_25';
 
        output_dir = 'stats_2025'; 
         
        % Design and preproc parameters
        units = 'secs'; 
        TR = 2.5; 
        slice_num = 46; 
        ref_slice = 23;
        
        cd (input_vols)
        fMRI_SPM_AE_job(input_vols, output_dir, units, TR, slice_num, ref_slice)
        
        disp('Estimating GLM model .................')
        fMRI_SPM_AE_GLMestim_job(output_dir)
        cd(protDir)
        
        
    case 3
        %% Contrast definition 4 fMRI second level analysis
        % Contrast Definition for computif the second level SPM.mat
        % !!!!!! Mandatory case to run  fun fMRI_SPM2ndLevel_jobfun.m
        
        protDir = fullfile(protDir,sub_id);
       
        % Define contrast:
        disp('I am computing a contrast')
        con_name = 'action_vs_rest';

        con_vect = [1 0 0 0 0 0 0 0 0 0 0 0]; %action vs rest is beta0
        delete_bool = 1; %I delete old contrast

        stats_dir = 'Functional/stats_2025';

        T_con_def(protDir, stats_dir, con_name, con_vect, delete_bool)
        %F_con_def(sub_Dir, con_name, con_vect, delete_bool

    case 4
        %% fMRI 2nd level analysis: NORMALIZED DATA MNI152
        disp('=================== Second level analysis ===================')
        % % Computation of GROUP SPM.mat out of the for loop because group SPM is one
        % % for all.

        % % Upload the contrasts activation vs rest for all the subjects
        sub_cont_path =  fullfile('Functional', 'stats_2025'); % relative path
        sub_cont_name = 'con_0001.nii'; %name .nii -- a contrast using spm MUST have been defined

        cont = 1;
        for i=1:length(subj_vec)

            subject = subj_vec(i);
            sub_id = sprintf('S%d',subj_vec(i))
            sub_folder = fullfile(protDir,sub_id)

            if isfile( fullfile(sub_folder,sub_cont_path, sub_cont_name) )
                contrast{cont,1} = horzcat(fullfile(sub_folder,sub_cont_path, sub_cont_name),',1');
                cont = cont+1;
            end
        end

        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end

        outputDir = fullfile(protDir, folderName);

        fMRI_SPM2ndLevel_jobfun_25(outputDir, contrast, tcontrast_name)

    case 5
        %% Run Single Subject VOI extraction
       
        disp('=================== Subject-specific VOI extraction ===================')

        % Put the name of Group masks (NOT THE ATLAS)
        VOI_name_vec = {'V1_BA15115_RL', 'SPL_BA138_L', 'CC_BA117_L', 'M1_BA131_L', 'SMAPMC_BA122_L', 'CRBL_R'};
        folder4spm_mat = 'Group_analysis';

        tot_voi = length(VOI_name_vec);

        thrs_vec = [0.05 0.05 0.05 0.05 0.05 0.05];
        dim_sphere = [10 10 15 10 15];

        contr4adj = 1;
        contr4act = 1;
        center = [0 0 0];

        dim_sphere_i = 1;

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
