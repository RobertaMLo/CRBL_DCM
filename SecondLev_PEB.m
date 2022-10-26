clear
clc
close

% Load GCM structure:
current_dir = pwd;
parent_dir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5/GCM_models';
GCM_struct = load(fullfile(parent_dir,'GCM_fixedconn_0delay_CentrInpt.mat'));
GCM = GCM_struct.GCM(:,4); % load function save data into a struct.

[PEB_full_fix, DCM_full_fix] = spm_dcm_peb(GCM)
models = DCM_full_fix
[BMA_full_fix,BMR_full_fix] = spm_dcm_peb_bmc(PEB_full_fix, 'A')