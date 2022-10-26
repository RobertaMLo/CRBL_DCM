% =========================================================================
% DCM MAIN file.
%
% Hi guiys! I'm the script who calls the functions written
% to perform a complete DCM analysis.
%
% Run the sections you are interested in and Have fun !!!!!!!!
%
% =========================================================================
%   @author: robertalorenzi
%   creation date: Sep 9h, 2021
%   
%   -----------------------------------------------------------------------
%   Last update: 13 Sept 2021;
%   -----------------------------------------------------------------------

%% SECTION 1. Standard initializations -- ALWAYS RUN!!!! ==================
clc
clear
close all


% Initial path. After performing the analysis, I'll return here.
% path where subjects folders have been saved
init_path = pwd;

% Where subjects folders have been stored
my_folder_path = '/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj';

%% SECTION 2.  Run just when the path of fmri file has been changed =======
% Prepare SPM.mat with the correct path for slicing time file
% SPM_change_timing_path(my_folder_path)

%% SECTION 3. 1st level DCM: Specification and Estimate ===================
% Starting point and number of subject to be included in the analysis
init = 1;
nsub = 6;
estimate = false; %estimate when build the GCM

DCM_predictive_crbl(my_folder_path,init,nsub,estimate)
cd(pwd)

%% SECTION 4. Build GCM ===================================================
GCM = GCM_builder(my_folder_path, 'DCM_0*', nsub)
cd(my_folder_path)
spm_dcm_fmri_check(load('GCM.mat'))

cd(pwd)