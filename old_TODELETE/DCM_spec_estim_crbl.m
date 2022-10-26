function DCM_spec_estim_crbl(my_folder_path, dcm_id, init, nsub, estimate)
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
%   Last update: 22 Oct 2021;
%   -----------------------------------------------------------------------

%% CRBL
disp('=========================== CRBL ============================')
% TR and TR from Adnan Paper
TR = 2.5;   % Repetition time (secs)
TE = 0.035;  % Echo time (secs)

% Experiment settings
nregions    = 5;
nconditions = 2;

% Index of each condition in the DCM
GE=1; GEForce=2;

% Index of each region in the DCM
crbl=1; m1=2; pmc=3; sma=4; v1=5;

%Specify DCMs (one per subject)
% FOR EACH SUBJECT THIS PART CREATE A DCM NAMED DCM_FULL.MAT
%Added comments:
%For each matrix: col = outgoing connections, row = incoming connections

% A-matrix (on / off)
% A=df/dx with u = 0 -> Fixed nodes coupling.
% 0 = switched off connection --> FIXED TO PRIOR!
a = ones(nregions,nregions);

% a(crbl,pmc) = 0;
% a(v1,crbl) = 0;
% a(v1,m1) = 0;
% a(v1,pmc) = 0;
% a(v1,sma) = 0;


%B-matrix
%B = df/dxdu -> change due to external input u
% u = task, pictures, words
b = zeros(nregions,nregions,nconditions); %Force modulation

%b(from, to)
b(v1,crbl,end) = 1; %from v1 to crbl = top down
b(crbl,v1,end) = 1; %from crbl to v1 = bottom up


% C-matrix
c = zeros(nregions,nconditions);
c(v1,GE) = 1;

% D-matrix (disabled but must be specified)
d = zeros(nregions,nregions,0);

disp("======================= Matrices: ")
disp("A: ")
a
disp("B: ")
b
disp("C: ")
c

for subject = init:nsub
    disp('*********** Specifying... ***********')
    name = sprintf('S%d',subject)
    
    if isfolder( fullfile(my_folder_path,name) )
        
        % Load SPM matrix. It provides the TIMING for the TASKS
        glm_dir = fullfile(my_folder_path,name,'AE','stats');
        SPM     = load(fullfile(glm_dir,'SPM.mat')); %PROVIDING EXPERIMENTAL TIMING FOR THE TASKS
        SPM     = SPM.SPM;
        
        % Load ROIs. It provides the EXPERIMENTAL TIME SERIES
        % MUST BE CONSISTENT WITH THE INDEX ORDER
         f = {
            
            fullfile(glm_dir,'VOI_CRBL_R_A_MNI_1.mat'); %PROVIDING THE EXPERIMENTAL TIME SERIES
            fullfile(glm_dir,'VOI_M1_L_MNI_1.mat');
            fullfile(glm_dir,'VOI_PMC_L_MNI_1.mat');
            fullfile(glm_dir, 'VOI_SMA_L_MNI_1.mat');
            fullfile(glm_dir,'VOI_V1_BIL_MNI_1.mat');
            
            };
        
        for r = 1:length(f)
            XY = load(f{r});
            xY(r) = XY.xY;
        end
        
        % Move to output directory
        cd(glm_dir);
        
        % Select whether to include each condition from the design matrix
        % (GE, GEF1, GEF2, GEF3, GEF4)
        
        include = [1 0 0 1 0]; %GFE3
        
        % Specify. Corresponds to the series of questions in the GUI.
        % TIP: IF YOU MUST ANSWER QUESTIONS IN GUI, CREATE A STRUCTURE IN
        % SCRIPT WITH THE ANSWER AND CALL FUNCTION _SPECIFY TO KEEP THE SCRIPT
        % COMPLETELY AUTHOMATIC.
        dcm_date = char(strrep(string(date),'-','_'));
        dcm_id = horzcat(dcm_date,'_', dcm_id); %current date as ID
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
        
        clear dcm_id
        
    else
        disp('***************** No Data No Party **********************')
    end
end

cd('~') %back to the root directory