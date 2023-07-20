function F_con_def(stats_dir, con_name, con_vect, delete_bool)
% % Computation of F contrast =============================================
% protDir = protocol Directory
% con_name = name of the contrast
% con_vect = contrast vector
% delete_bool = logic value: 0 = DON'T delete old contrast, 1 = Delete old
% contrast

% author: 
%-----------------------------------------------------------------------
% Job saved on 27-Mar-2023 17:16:49 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.con.spmmat = {fullfile(pwd,stats_dir,'SPM.mat')};
matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = con_name;              %Effects of Interest
matlabbatch{1}.spm.stats.con.consess{1}.fcon.weights = con_vect;
matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 0;                                   %don't delete_bool

spm_jobman('run', matlabbatch);

