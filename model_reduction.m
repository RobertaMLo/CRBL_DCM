% =========================================================================
% Protocol to perform Bayesian Model Reduction on each column of a GCM
% already estmated. Bayesian Model Reduction works in column, i.e., for each
% model type, it computes statistics over the subject
% Input: parent directory, where GCM file is stored and the GCM filename
% Output: RCM, BMC, BMA for all models, saved in a temporary directory in protocol folder with the same
% name of the input GCM and suffix _TEMP.

% =========================================================================
clear
clc

% Load GCM structure:

parent_dir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5/GCM_models';
GCM_name  = 'GCM_mod_RLMM_v1crblsma_withLin.mat';


GCM_struct = load(fullfile(parent_dir,GCM_name));
GCM = GCM_struct.GCM; % load function save data into a struct.
%n_subj = size(GCM,1);
n_mod = size(GCM,2);

RCM_allmod = struct(RCM);
BMC_allmod = struct(BMC);
BMA_allmod = struct(BMA);

work_dir = pwd;

for m=1:n_mod
    [RCM,BMC,BMA] = spm_dcm_bmr(GCM(:,m));
    disp('==============================================================')
    disp('==============================================================')
    sprintf('Hey Dude, Reducing model %i out of %i', m,n_mod)
    disp('==============================================================')
    disp('==============================================================')
    RCM_allmod(m).RCM = RCM;
    BMC_allmod(m).BMC = BMC;
    BMA_allmod(m).BMA = BMA;

end

path4res = '/media/bcc/Volume/Analysis/Roberta/DCM_AE/BMR_allmod';
dir_name = fullfile(path4res,regexprep(GCM_name,'.mat','_TEMP'));
if ~exist(dir_name, 'dir')
    mkdir(yourFolder)
end

cd(dir_name)
save 'RCM.mat', 'RCM_allmod.RCM';
save 'BMC.mat', 'BMC_allmod.BMC';
save 'BMA.mat', 'BMA_allmod.BMA';
cd(work_dir)


% %GCM_bmr = spm_dcm_bmr(GCM(:,1), {'A'});
% 
% write_all = false;
% 
% 
% for i_gcm = 1:size(GCM,2)
%     GCM_posthoc = spm_dcm_post_hoc(GCM(:,i_gcm),'','', write_all);
%     %GCM_opt = spm_dcm_search(GCM(:,1))
% end
% 
% 
% %cd(current_dir)