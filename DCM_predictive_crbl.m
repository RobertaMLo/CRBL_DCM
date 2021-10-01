function DCM_predictive_crbl(my_folder_path,init,nsub, estimate)
% =========================================================================
% Protocol to run a DCM analaysis
% =========================================================================
%   @author: robertalorenzi
%   creation date: Sep 8th, 2021
%   -----------------------------------------------------------------------
%   Input
%   my_folder_path:       String. Parent directory, containing subjs dir
%
%   init:       Int. Initialization of the for loop on Subjects
%               (i.e. to start from subject 1: in=1)

%   nsub:       Int. Number of Subjects icluded in the analysis.
%               N.B.: Keep separated input because when operation = 2 two
%               different models are needed

%   estimate:   Logical. true to specify DCM, false to estimate DCM    
%   -----------------------------------------------------------------------
%   Last update: 07 Sept 2021;
%   -----------------------------------------------------------------------

%% CRBL
disp('=========================== CRBL ============================')
TR = 1.25;   % Repetition time (secs)
TE = 0.04;  % Echo time (secs)

% Experiment settings
nregions    = 4;
nconditions = 2;

% Index of each condition in the DCM
GE=1; GEForce=2;

% Index of each region in the DCM
crbl=1; m1=2; pmc=3; sma=4;

%Specify DCMs (one per subject)
% FOR EACH SUBJECT THIS PART CREATE A DCM NAMED DCM_FULL.MAT
%Added comments:
%For each matrix: col = outgoing connections, row = incoming connections

% A-matrix (on / off)
% A=df/dx with u = 0 -> Fixed nodes coupling.
% 0 = switched off connection --> FIXED TO PRIOR!
a = ones(nregions,nregions);

a(pmc,crbl) = 0;

%B-matrix
%B = df/dxdu -> change due to external input u
% u = task, pictures, words
b(:,:,GEForce)     = zeros(nregions); %Force modulation
b(m1,crbl,end) = 1;
b(m1,pmc,end) = 1;
b(m1,sma,end) = 1;


% C-matrix
c = zeros(nregions,nconditions);
c(m1,GE) = 1;
c(sma,GE) = 1;

% D-matrix (disabled but must be specified)
d = zeros(nregions,nregions,0);

for subject = init:nsub
    disp('*********** Specifying... ***********')
    name = sprintf('S%d',subject)
    
    if isfolder( fullfile(my_folder_path,name) )
        
        % Load SPM matrix. It provides the TIMING for the TASKS
        glm_dir = fullfile(my_folder_path,name,'AE','stats');
        SPM     = load(fullfile(glm_dir,'SPM.mat')); %PROVIDING EXPERIMENTAL TIMING FOR THE TASKS
        SPM     = SPM.SPM;
        
        % Load ROIs. It provides the EXPERIMENTAL TIME SERIES
        %(_Fadj for F-contrast adjusted images)
        f = {
            fullfile(glm_dir,'VOI_CRBL_PM_Fadj_1.mat'); %PROVIDING THE EXPERIMENTAL TIME SERIES
            fullfile(glm_dir,'VOI_M1_Fadj_1.mat');
            fullfile(glm_dir,'VOI_PMC_Fadj_1.mat');
            fullfile(glm_dir,'VOI_SMA_Fadj_1.mat')
            };
        
        for r = 1:length(f)
            XY = load(f{r});
            xY(r) = XY.xY;
        end
        
        % Move to output directory
        cd(glm_dir);
        
        % Select whether to include each condition from the design matrix
        % (GE, GEF1, GEF2, GEF3, GEF4)
        include = [1 1 0 0 0];
        
        % Specify. Corresponds to the series of questions in the GUI.
        % TIP: IF YOU MUST ANSWER QUESTIONS IN GUI, CREATE A STRUCTURE IN
        % SCRIPT WITH THE ANSWER AND CALL FUNCTION _SPECIFY TO KEEP THE SCRIPT
        % COMPLETELY AUTHOMATIC.
        dcm_id = char(strrep(string(date),'-','_')); %current date as ID
        s = struct();
        s.name       = dcm_id;
        s.u          = include;                 % Conditions
        s.delays     = repmat(TR,1,nregions);   % Slice timing for each region
        s.TE         = TE;
        s.nonlinear  = false;
        s.two_state  = false;
        s.stochastic = false;
        s.centre     = true;
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