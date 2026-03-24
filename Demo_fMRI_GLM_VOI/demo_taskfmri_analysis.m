% % ===================================================================
% % DEMO FOR TASK-FMRI ANALYSIS
% % Pipeline is based on MATLAB - SPM12.
% %
% % --- N.B. The pipleine required the data paths constructed as MARE LAB fmri
% %              preprocessing does (but you can easly extend to your data path) ----
% %              E.g.: /protDir/sub_dir/Functional/Preproc_fMRI
% %
% % Sections:
% % 1) Preprocessing (** not mandatory **)
% %     1.1) Normalization to MNI space
% %     1.2) Smoothing
% % 2) GLM modeling - first level analysis (subject-specific)
% %     2.1) GLM definition - definition of SPM.mat
% %     2.2) GLM estimation - estimation of SPM.mat
% % 3) Contrast definition
% % 4) GLM modeling - second level (group-level)
% % 5) Time-series extractions -- intended to be done as double constrained:
% %      mask (either funct or anat && geometrical restriction around the peak)
% % 6) BOLD PSD analysis
% %
% % authors: Dr. Roberta M. Lorenzi & Dr. Gokce Korkmaz.
% % ref: "Cerebellar control over inter-regional excitatory/inhibitory dynamics discriminates
% %        execution from observation of an action" doi: 10.1007/s12311-025-01863-6
% % link:
% % ===================================================================

%% Parameters set up
% Nice to have: work directory (where m file are stored) to go back here:
work_dir = '/home/bcc/matlab/Roberta/DCM_glm_and_VOI_extraction_validated8Oct25';

% Always needed
protDir = '/home/bcc/taskfmri_demo';                                   %parent folder (protocol directory)
sub_id = 'S2';                                                                        %subject ID
native_fMRI = 'fMRI_CovRegressed';                                  %pre-proessed fmri

% Defined for fMRI_MNI_norm_DCM
matlab_folder = '/home/bcc/matlab';                                     %needed for TPM files

% Defined for GLM and all task-fMRI analysis output
output_glm = 'stats';                                                   %where GLM output will be saved
units = 'secs';                                                                         % Design and preproc parameters
TR = 2.5;
slice_num = 46;
ref_slice = 23;

% For group level analysis
sub_vec  = ['S1', 'S2'];                                                            %list of sibjects ids
outputDir = 'Group level';                                                        %where GROUP GLM output will be saved
sub_cont_name = 'con_0001.nii';                                           %contrast defined in 3)


% For time-series extraction
mask_dir = '/home/bcc/taskfmri_demo/Group_analysis';        %folder of mask - full path
% name of the masks for constraining the VOI extraction
VOI_name_vec = {'V1_15115_RL', 'SPL_138_L', 'CC_117_L', 'M1_131_L', 'SMAPMC_122_L', 'CRBL_R'};

sub_dir = fullfile(protDir,sub_id);
%% 1) fMRI normalization & smoothing
cd(fullfile(sub_dir, "Functional")) % put at the beginning of each session just to be sure to start from the same point

disp('I am working in:')
pwd

%Normalise the data
disp('I am Normalizing fMRI 2 MNI 2mm space')

fMRI_MNI_norm_DCM(protDir, matlab_folder, native_fMRI)

%Smooth the data
disp('I am doing smoothing')
input_vols = 'Preproc_fMRI/wsplits_mni2mm_25';                          %output from preprocessing
fwhm_width = [6 6 6];                                                                       %usually fwhm =>3x dim voxels
fMRI_smooth_DCM_job(protDir, input_vols, fwhm_width)

cd(work_dir)

%% 2) GLM Modeling
cd(fullfile(sub_dir, "Functional"))

disp('Computing SPM.mat ................')

if ~isfolder(output_glm)
    mkdir(output_glm)
end

input_vols = 'Preproc_fMRI/swsplits_mni2mm_25'; %Must have: smoothed data see 1)
cd (input_vols)
fMRI_SPM_AE_job(input_vols, output_glm, units, TR, slice_num, ref_slice)            %Definition

disp('Estimating GLM model .................')
fMRI_SPM_AE_GLMestim_job(output_glm)                                                              %Estimation

cd(work_dir)

%% 3) Contrast defintion
% This is intended to be run for each contrast you want to define, both F
% or T contrast.
cd(fullfile(sub_dir, "Functional"))

% Define contrast:
disp('I am computing a contrast')
con_name = 'action_vs_rest';

con_vect = [1 0 0 0 0 0 0 0 0 0 0 0]; %action vs rest is beta0
delete_bool = 1; %I delete old contrast

T_con_def_demo(output_glm, con_name, con_vect, delete_bool)
%F_con_def(output_GLM, con_name, con_vect, delete_bool

cd(work_dir)

%% 4) GLM Modeling (2nd level analysis)
disp('=================== Second level analysis ===================')
% % Computation of GROUP SPM.mat out of the for loop because group SPM is one
% % for all.

% % Upload the contrasts activation vs rest for all the subjects
sub_cont_path =  fullfile('Functional', stats_dir); % relative path
cont = 1;
for i=1:length(subj_vec)

    sub_id = subj_vec(i)
    sub_folder = fullfile(protDir,sub_id)

    if isfile(fullfile(sub_folder,sub_cont_path, sub_cont_name) )
        contrast{cont,1} = horzcat(fullfile(sub_folder,sub_cont_path, sub_cont_name),',1');
        cont = cont+1;
    end
end

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

outputDir = fullfile(protDir, folderName);

fMRI_SPM2ndLevel_jobfun_25(outputDir, contrast, tcontrast_name)

cd(work_dir)

%% 5) VOI Extraction
 %unix(horzcat('gunzip ',fullfile('/Preproc_fMRI/swsplits_mni2mm_25/sw*') ' -f')); %spm wants .nii

cd(fullfile(sub_dir, "Functional", output_glm))
contr4adj = 1;
contr4act = 1;

center = [0 0 0];

tot_voi = length(VOI_name_vec);

thrs_vec = [0.05 0.001 0.05 0.05 0.05 0.001];
dim_sphere = [10 10 15 10 15];

i_sph = 1;

for i_voi=1:tot_voi

    VOI_name = VOI_name_vec{i_voi}

    if  contains('CRBL_R', VOI_name)
        mask_abs_path = fullfile(mask_dir, ['VOI_SUIT_mask_LobuleI_IVbin_' VOI_name '_mask.nii'])
    else
        mask_abs_path = fullfile(mask_dir, ['VOI_BAM_mask_' VOI_name '_mask.nii'])
    end

    disp('=============================================================')
    disp('threshold: ')
    thrs = thrs_vec(i_voi)

    disp('=============================================================')
    disp('geometry and dimension: ')

    if i_voi==1
        geometry = 'box'
        dimension = [90 90 90]

    else
        dimension = dim_sphere(i_sph)
        geometry = 'sphere'
        i_sph = i_sph+1;
    end

    VOI_extraction_demo(VOI_name, contr4adj, contr4act, thrs, mask_abs_path, ...
        geometry, center, dimension)

end

%unix(horzcat('gzip ',fullfile('/Preproc_fMRI/swsplits_mni2mm_25/sw*'))) %memory saving

%% 6) BOLD PSD Analysis
cd(fullfile(sub_dir, "Functional", output_glm))

fs = 1/TR;

mat_items = dir(fullfile('VOI*.mat'));

for j=1:length(mat_items)

    data = load(mat_items(j).name);
    y=data.Y;
    y=detrend(y,'constant');

    %pwelch(y, window, noverlap, nfft, fs)
    [P, f]=pwelch(y, [],[],[], fs);         %default Hamming N78 and overlap 50%

    P_dB=10*log10(P);
    
    figure(1)
    subplot(2,3,j);
    plot(y);
    set(gcf, 'Color', 'w');
    grid on;
    ylabel('BOLD');
    xlabel('time [TR]');
    title(mat_items(j).name)
    
    figure(2)
    subplot(2,3,j);
    plot(f,P);
    set(gcf, 'Color', 'w');
    area(f,P, 'FaceColor',[0 0.8 0], 'FaceAlpha', 0.1);
    grid on;
    ylabel('PSD');
    xlabel('Frequency [Hz]');
    title(mat_items(j).name)

end








