function F_contrast_def(parent_dir, start_subj, nsubj, contr_name, contr_mat, del_contr)
% =========================================================================
% Protocol to define Volume Of Interest (VOI)
% 
% NB: For each subject data must be organized in one folder per subject.
%     Each subject folder must contain these paths:
%           Functional/stats/SPM.mat --> statistical analysis
%           Functional/splits/ --> splitted fmri volumes
%     
%      Subject folders must be saved in a parent folder containing ONLY
%      subject folders
%
% =========================================================================
%   @author: robertalorenzi
%   creation date: Oct 20th, 2021
%   -----------------------------------------------------------------------
%   Input:
%   parent_dir:       String. Path of the parent folder where subjects
%                     folders are stored
%   start_subj =      Int. Id of starting subject for the analysis
%   nsubj:            Int. Number of subjects to analyse
%   contr_name:       String. Name of contrast
%   contr_mat:        Int. matrix for F contrast definition
%   del_contr:        Int. 0 to keep existing contrast, 1 to delete
%   -----------------------------------------------------------------------
%   Last update:
%   -----------------------------------------------------------------------

for subject=start_subj:nsubj
        
        name = sprintf('S%d',subject);
    
        if isfolder( fullfile(parent_dir,name,'Functional','stats') )
        
            cd(fullfile(parent_dir,name,'Functional','stats'))
            
            disp('=======================================================')
            disp('Hello!!!! ------ here I am')
            fullfile(parent_dir,name,'Functional','stats')
            
            % Insert the subject's SPM .mat filename here
            spm_mat_file = 'SPM.mat';
            
            clear matlabbatch;

            matlabbatch{1}.spm.stats.con.spmmat = cellstr(spm_mat_file);
            matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = contr_name;
            matlabbatch{1}.spm.stats.con.consess{1}.fcon.weights = contr_mat;
            matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
            matlabbatch{1}.spm.stats.con.delete = del_contr;
            
            % Run the batch
            spm_jobman('run',matlabbatch);
            
            
        else
            
            disp('***************** No Data No Party **********************')
        end
end



