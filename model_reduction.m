% =========================================================================

% Protcolo to perform baysian model reduction as an exhaustive search.
% Both at single and at population level

clear

% Load GCM structure:
current_dir = pwd;
parent_dir = '/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj/';
GCM_struct = load(fullfile(parent_dir,'GCM_full.mat'));
GCM = GCM_struct.GCM; % load function save data into a struct.


GCM = spm_dcm_bmr(GCM);



%cd(current_dir)