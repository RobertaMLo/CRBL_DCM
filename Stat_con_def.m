function Stat_con_def(cont_type, sub_Dir, con_name, con_vect, delete_bool)
% % Computation of T contrast =============================================
% protDir = protocol Directory
% stats_dir = directory where SPM.mat is saved - TEMPORARYYYYY!
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
%
%last update: 12 Sept 2023
%-----------------------------------------------------------------------
try
    
    if strcmp(cont_type, 'T')
        matlabbatch{1}.spm.stats.con.spmmat = {fullfile(sub_Dir,'Functional/stats','SPM.mat')};
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = con_name; %action_vs_rest';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = con_vect;
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.delete = delete_bool;
    elseif strcmp(cont_type, 'F')
        matlabbatch{1}.spm.stats.con.spmmat = {fullfile(sub_Dir, 'Functional/stats','SPM.mat')};
        matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = con_name;              %Effects of Interest
        matlabbatch{1}.spm.stats.con.consess{1}.fcon.weights = con_vect;
        matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.delete = delete_bool;                                   %don't delete_bool

    end

catch
    disp('Contrast type not valid. Please choose F or T')
end

spm_jobman('run', matlabbatch);
