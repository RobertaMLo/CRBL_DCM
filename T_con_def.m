function T_con_def(stats_dir, con_name, con_vect, delete_bool)
% % Computation of T contrast =============================================
% protDir = protocol Directory
% con_name = name of the contrast
% con_vect = contrast vector: put 1/-1 in correspondance of beta(s) you ant to
% test
% delete_bool = logic value: 0 = DON'T delete old contrast, 1 = Delete old
% contrast
%
%-----------------------------------------------------------------------
% Job saved on 25-Mar-2022 15:52:02 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%
% author: Roberta and Gokce
% date: March 25th 2022
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.con.spmmat = {fullfile(pwd,stats_dir,'SPM.mat')};
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = con_name;               %action_vs_rest';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = con_vect;
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = delete_bool;

spm_jobman('run', matlabbatch);
