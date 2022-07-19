% =========================================================================

% Protcolo to perform baysian model reduction as an exhaustive search.
% Both at single and at population level

clear
clc

% Load GCM structure:
current_dir = pwd;
parent_dir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5/GCM_models';
GCM_struct = load(fullfile(parent_dir,'GCM_fixedconn_last.mat'))
GCM = GCM_struct.GCM; % load function save data into a struct.


%GCM_bmr = spm_dcm_bmr(GCM(:,1), {'A'});

write_all = false

GCM_posthoc = spm_dcm_post_hoc(GCM(:,1),'',{'A'}, write_all);



%cd(current_dir)