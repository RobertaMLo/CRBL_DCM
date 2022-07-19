function visuomotor_DCM(protDir, init_subj, nsubj, A_filename, B_filename, C_filename, DCM_filename, estimate)
% =========================================================================
% Protocol to run a DCM analaysis
% =========================================================================
%   @author: roberta &  gokce
%   creation date: Apr 13th, 2022
%   -----------------------------------------------------------------------
%   Input
%   my_folder_path:  String. Parent directory, containing subjs dir
%
%   init:       Int. Initialization of the for loop on Subjects
%               (i.e. to start from subject 1: in=1)
%
%   nsub:       Int. Number of Subjects icluded in the analysis.
%               N.B.: Keep separated input because when operation = 2 two
%               different models are needed
%
%   mod_ind:    Int. Index for the modulation to include.
%               1 = linear; 2 = quadratic; 3 = cubic 
%
%   estimate:   Logical. true to specify DCM, false to estimate DCM    
%   -----------------------------------------------------------------------

%   -----------------------------------------------------------------------

%% MODEL SPECIFICATION
disp('====================================================================')
disp('Hello!!! I am a super cute DCM protocol to investigate CRBL modulation effect')
disp('====================================================================')

% 1) Acquisition parameters ===============================================
TR = 2.5;   % Repetition time (secs)
TE = 0.035;  % Echo time (secs) --> Chech if they are ok!

% 2) Indexing for code flexibility ========================================
% VOI: CRBL_R, M1_L, PMC_L, SMA_L, V1_BIL
nregions    = 6; %change according to how many regions

% Two input
% driving and 1 modulatory >> different model = different modul.
nconditions = 5;

% Index of each condition in the DCM
% set 1 if yhou want to include the effect, 0 otherwise
include = zeros(1,nconditions);

AE=1; AEf1=1; AEf2=1; AEf3 =1; AEf4 = 0;

% 3) DCM matrices specification ===========================================
% Added comments:
%For each matrix:
%   row = incoming connections (TO)
%   col = outgoing connections (FROM)

% 3.1) A MATRIX: EFFECTIVE CONNECTIVITY ===================================
% Load from a txt file
% A-matrix (on / off)
% A=df/dx with u = 0 -> Fixed nodes coupling.
% 0 = switched off connection --> FIXED TO PRIOR!

a = importdata(fullfile(protDir,'DCM_A_matrix_files',A_filename));

% 3.2) B MATRIX: MODULATION TO THE EFFECTIVE CONNECTIVITY =================

% ====== Specify B matrix according to the hp ===============================

%B-matrix
%B = df/dxdu -> change due to external input u.
% u = Force Modulation

if strcmp(B_filename,'')
    b = zeros(nregions,nregions,nconditions);
else
    b = importdata(fullfile(protDir,'DCM_B_matrix_files',B_filename));
end


% 3.3) C-matrix ===========================================================
% fixed prior: it's known that
if strcmp(C_filename,'')
    c = zeros(nregions,nconditions);
    c(end,AE) = 1;
else
    c = importdata(fullfile(protDir,'DCM_C_matrix_files',C_filename));
end
    
    
% D-matrix (disabled but must be specified)
d = zeros(nregions,nregions,0);


for subject = init_subj:nsubj
    
    disp('*********************    Specifying...    *********************')
    name = sprintf('S%d',subject)
    
    if isfolder( fullfile(protDir,name,'Functional/stats') )
        
        mkdir(fullfile(protDir,name,'Functional/stats/DCM_models') )
        
        % Load SPM matrix. It provides the TIMING for the TASKS
        glm_dir = fullfile(protDir,name,'Functional/stats');
        SPM     = load(fullfile(glm_dir,'SPM.mat'));
        SPM     = SPM.SPM;
        
        % Load ROIs. It provides the EXPERIMENTAL TIME SERIES
        f = {
            fullfile(glm_dir,'VOI_M1_BA131_L_1.mat');
            fullfile(glm_dir,'VOI_SMAPMC_BA122_L_1.mat');
            fullfile(glm_dir,'VOI_SPL_138_L_1.mat');
            fullfile(glm_dir,'VOI_CC_BA117_L_1.mat');
            fullfile(glm_dir,'VOI_CRBL_R_1.mat')
            fullfile(glm_dir,'VOI_V1_BA15115_RL_1.mat')
            };
        % Take timeseries from the VOI .mat file
        for r = 1:length(f)
            XY = load(f{r});
            xY(r) = XY.xY;
        end
        
        % Move to output directory
        disp('Output directory: ')
        cd(fullfile(glm_dir,'DCM_models'))
        
        % Select whether to include each condition from the design matrix
        % (AE, AE^force1, AE^force2, AE^force3, AE^force4)
        include(1) = AE;
        include(2) = AEf1;
        include(3) = AEf2;
        include(4) = AEf3;
        include(5) = AEf4;

        % Specify ========================================================= 
        % This Corresponds to the series of questions in the GUI.
        % TIP: IF YOU MUST ANSWER QUESTIONS IN GUI, CREATE A STRUCTURE IN
        % SCRIPT WITH THE ANSWER AND CALL FUNCTION _SPECIFY TO KEEP 
        % THE SCRIPT COMPLETELY AUTHOMATIC.
        
        %DCM.mat filename will start with dcm_id :yyyymmdd_hXX_mYY
        id = clock;
        dcm_id = horzcat(num2str(id(1)),num2str(id(2)),num2str(id(3)),...
                         '_h',num2str(id(4)),'m',num2str(id(5)));
        dcm_fullname = horzcat(dcm_id,'_',DCM_filename);
        
                     % Define a MATLAB structure as required         
        s = struct();
        s.name       = dcm_fullname;                                        % FULL name of .mat file
        s.u          = include;                                             % Conditions used to make Hp on matrix A
        s.delays     = repmat(TR,1,nregions);                               % Slice timing for each region
        s.TE         = TE;
        s.nonlinear  = false;
        s.two_state  = false;
        s.stochastic = false;
        s.centre     = true;                                                % mean center the input!
        s.induced    = 0;
        s.a          = a;
        s.b          = b;
        s.c          = c;
        s.d          = d;
        
        % Ready to call specify function.
        % Input: SPM matrix, VOIs timeseries, GUI fields
        DCM = spm_dcm_specify(SPM,xY,s);
        
        
        if estimate
            disp('*********** Estimating ... ***********')
            DCM = spm_dcm_estimate(horzcat('DCM_',dcm_fullname,'.mat'))
        end
       
        % Return to script directory
        cd(protDir);
        
    else
        disp('***************** No Data No Party **********************')
    end
end

cd('~') %back to the root directory