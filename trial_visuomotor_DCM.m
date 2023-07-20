function trial_visuomotor_DCM(protDir, init_subj, nsubj, DCM_filename, estimate)
% =========================================================================
% Protocol to run a DCM analaysis
% =========================================================================
%   @author: roberta &  gokce
%   creation date: Apr 13th, 2022
%   -----------------------------------------------------------------------
%   Input
%   protDir:  String. Parent directory, containing subjs dir
%
%   init_subj:  Int. Initialization of the for loop on Subjects
%               (i.e. to start from subject 1: in=1)
%
%   nsub:       Int. Number of Subjects icluded in the analysis.
%               N.B.: Keep separated input because when operation = 2 two
%               different models are needed
%
%   DCM_filename: String. DCM_YYYYDDMM_DCM_filename.mat. DCM_YYY...
%                 authomatic.
%
%   estimate:   Logical. true to estimate  
%   -----------------------------------------------------------------------

%   -----------------------------------------------------------------------

%% MODEL SPECIFICATION
disp('====================================================================')
disp('Hello!!! I am a super cute DCM protocol to investigate CRBL modulation effect')
disp('====================================================================')
pback =pwd;
% 1) Acquisition parameters ===============================================
TR = 2.5;   % Repetition time (secs)
TE = 0.035;  % Echo time (secs) --> Chech if they are ok!

% 2) Indexing for code flexibility ========================================
% VOI: CRBL_R, M1_L, PMC_L, SMA_L, V1_BIL
nregions    = 6; %change according to how many regions

% Two input
% driving and 1 modulatory >> different model = different modul.
nconditions = 3;

% Index of each condition in the DCM
% set 1 if yhou want to include the effect, 0 otherwise
include = zeros(1,nconditions);
AE_bool=1; AEf1_bool= 1; AEf2_bool= 1; AEf3_bool=0; AEf4_bool = 0;

% Select whether to include each condition from the design matrix
% (AE, AE^force1, AE^force2, AE^force3, AE^force4)
include(1) = AE_bool;
include(2) = AEf1_bool;
include(3) = AEf2_bool;
include(4) = AEf3_bool;
include(5) = AEf4_bool;

%define the position!!! of conditions in vector include
AE=1; %fixed always at 1 because it is the driving input and the first col of SPM.mat 
AEf1 = 2; AEf2 = 3; AEf3 = 4; AEf4 = 5; %numbers are the SPM.mat columns but
%ignore them for the moment :)

% Define the order of the VOI
m1 = 1;
smapmc =2;
spl = 3;
cc= 4;
crbl = 5;
v1 = 6;


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

a = ones(nregions); %% SET 0 THE CONN BASED on REDUCED MODEL 4
a(cc,m1) = 0
a(smapmc,smapmc) = 0
a(spl,smapmc) = 0
a(smapmc,spl) = 0
a(spl,spl)= 0
a(cc,spl) = 0
a(crbl,spl) = 0
a(v1,spl) = 0
a(m1,cc) = 0
a(spl,cc) = 0
a(cc,cc) = 0
a(crbl,cc) = 0
a(v1,cc) = 0
a(spl,crbl) = 0
a(cc,crbl) = 0
a(smapmc, v1) = 0
a(spl,v1) = 0
a(cc,v1) = 0

% a(smapmc,smapmc)= 0
% a(spl,smapmc) = 0
% a(v1,smapmc) = 0
% a(smapmc,spl) = 0
% a(spl,spl) = 0
% a(cc,spl) = 0
% a(crbl,spl) = 0
% a(v1,spl) = 0
% a(smapmc,cc) = 0
% a(spl,cc) = 0
% a(cc,cc) = 0
% a(crbl, cc) = 0
% a(v1,cc) = 0
% a(spl,crbl) = 0
% a(cc,crbl) = 0
% a(v1,crbl) = 0
% a(m1,v1) = 0
% a(smapmc,v1)= 0
% a(spl,v1) = 0
% a(cc,v1) = 0
% a(crbl,v1) = 0

% uncomment to import matrix A from a file .txt
%a = importdata(fullfile(protDir,'DCM_A_matrix_files',A_filename));

% 3.2) B MATRIX: MODULATION TO THE EFFECTIVE CONNECTIVITY =================

% ====== Specify B matrix according to the hp ===============================

%B-matrix
%B = df/dxdu -> change due to external input u.
% u = Force ModulationDCM_filename

%n conditions is the number of conditions included (not which conditions!)
%n conditions MUST BE the same of "1" you put in AEXXX_bool
%see the vector "include" for the order.

%b = zeros(nregions,nregions,nconditions);
% ATTENTION!!!! b(TO, FROM, TYPE_OF_MOD)
b = zeros(nregions);

%forward
% b(crbl,v1,AEf3) =1;
% b(v1,v1,AEf1) =1;
% b(smapmc,v1,AEf3) =1;


% b(crbl,crbl,AEf1) =1;
% 
% b(smapmc,cc,AEf2) =1;

%backward
%b(crbl,m1,AEf1) =1;
%b(smapmc,m1,AEf2) =1;

% 3.3) C-matrix ===========================================================
% fixed prior: it's known that
c = zeros(nregions, nconditions);

c(v1,AE)=1;    
    
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
            fullfile(glm_dir,'VOI_SPL_BA138_L_1.mat');
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
        s.delays     = [0, 0, 0, 0, 0, 0];                                  % Slice timing for each region
        s.TE         = TE;
        s.nonlinear  = false;
        s.two_state  = false;
        s.stochastic = false;
        s.centre     = false; %true;                                               % mean center the input!
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

cd(pback)
%cd('~') %back to the root directory