function model_crbl_modulation(my_folder_path,init,nsub, mod_ind, estimate)
% =========================================================================
% Protocol to run a DCM analaysis
% =========================================================================
%   @author: robertalorenzi
%   creation date: Oct 18th, 2021
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
%   Last update: 07 Sept 2021;
%   -----------------------------------------------------------------------

%% MODEL SPECIFICATION
disp('====================================================================')
disp('Hello!!! I am a super cute DCM protocol to investigate CRBL modulation effect')
disp('====================================================================')

% 1) Acquisition parameters ===============================================
TR = 1.25;   % Repetition time (secs)
TE = 0.04;  % Echo time (secs) --> Chech of they are ok!

% 2) Indexing for code flexibility ========================================
% VOI: CRBL_R, M1_L, PMC_L, SMA_L, V1_BIL
nregions    = 5;

% Two input
% driving and 1 modulatory >> different model = different modul.
nconditions = 2;

% Index of each condition in the DCM
GE=1; GEMod=2;

% Index of each region in the DCM
crbl=1; m1=2; pmc=3; sma=4; v1=5;

% 3) DCM matrices specification ===========================================
% Added comments:
%For each matrix:
%   row = incoming connections (TO)
%   col = outgoing connections (FROM)

% 3.1) A MATRIX: EFFECTIVE CONNECTIVITY ===================================

% === Specify the best matrix according to the best model output of BMS ===

% A-matrix (on / off)
% A=df/dx with u = 0 -> Fixed nodes coupling.
% 0 = switched off connection --> FIXED TO PRIOR!

a = ones(nregions,nregions);

% 3.2) B MATRIX: MODULATION TO THE EFFECTIVE CONNECTIVITY =================

% ====== Specify B matrix according to the hp ===============================

%B-matrix
%B = df/dxdu -> change due to external input u.
% u = Force Modulation

b(:,:,GEMod)   = zeros(nregions); %Force modulation

% =======       Set 1 for every outgoing connection FROM CRBL    ==========
b(m1,crbl,end) = 1;
b(pmc,crbl,end)  = 1;
b(sma,crbl,end) = 1;
b(v1,crbl,end) = 1;
b(crbl,crbl,end) = 1;


% 3.3) C-matrix ===========================================================
% fixed prior: it's known that 
c = zeros(nregions,nconditions);
c(v1,GE) = 1;


% D-matrix (disabled but must be specified)
d = zeros(nregions,nregions,0);

for subject = init:nsub
    
    disp('*********************    Specifying...    *********************')
    name = sprintf('S%d',subject)
    
    if isfolder( fullfile(my_folder_path,name) )
        
        % Load SPM matrix. It provides the TIMING for the TASKS
        glm_dir = fullfile(my_folder_path,name,'AE','stats');
        SPM     = load(fullfile(glm_dir,'SPM.mat'));
        SPM     = SPM.SPM;
        
        % Load ROIs. It provides the EXPERIMENTAL TIME SERIES
        f = {
            fullfile(glm_dir,'VOI_CRBL_R_1.mat');
            fullfile(glm_dir,'VOI_M1_L_1.mat');
            fullfile(glm_dir,'VOI_PMC_L_1.mat');
            fullfile(glm_dir,'VOI_SMA_L_1.mat');
            fullfile(glm_dir,'VOI_V1_BIL_1.mat')
            };
        
        for r = 1:length(f)
            XY = load(f{r});
            xY(r) = XY.xY;
        end
        
        % Move to output directory
        cd(glm_dir);
        
        % Select whether to include each condition from the design matrix
        % (GE, GEF1, GEF2, GEF3)
        include = [1 0 0 0 0];
        include(mod_ind) = 1;
        
        % give a name to the DCM according to the input
        if mod_ind == 1
            name = "mod_lin";
        elseif mod_ind == 2
            name = "mod_quad";
        elseif mod_ind == 3
            name = "mod_cub";
        else
            % Error cactching --> Exit the code
            disp('Ehi! Insert a correct number!')
            disp('1 for Linear, 2 for Quadratic or 3 for Cubic')
            break
        end

        % Specify ========================================================= 
        % This Corresponds to the series of questions in the GUI.
        % TIP: IF YOU MUST ANSWER QUESTIONS IN GUI, CREATE A STRUCTURE IN
        % SCRIPT WITH THE ANSWER AND CALL FUNCTION _SPECIFY TO KEEP 
        % THE SCRIPT COMPLETELY AUTHOMATIC.
        dcm_id = char(strrep(string(date),'-','_')); %current date as ID
        s = struct();
        s.name       = horzcat(dcm_id,'_',name); %date_name of mod
        s.u          = include;                 % Conditions
        s.delays     = repmat(TR,1,nregions);   % Slice timing for each region
        s.TE         = TE;
        s.nonlinear  = false;
        s.two_state  = false;
        s.stochastic = false;
        s.centre     = true; %mean center the input!
        s.induced    = 0;
        s.a          = a;
        s.b          = b;
        s.c          = c;
        s.d          = d;
        
        % Ready to call specify function.
        % Input: SPM matrix, VOIs, GUI fields
        DCM = spm_dcm_specify(SPM,xY,s);
        
        
        if estimate
            disp('*********** Estimating crbl... ***********')
            DCM = spm_dcm_estimate(horzcat('DCM_',dcm_id,'.mat'))
        end
       
        % Return to script directory
        cd(my_folder_path);
        
    else
        disp('***************** No Data No Party **********************')
    end
end

cd('~') %back to the root directory