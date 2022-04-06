function VOI_definition_MNI(parent_dir, start_subj, nsubj, VOI_name, ...
    F_contr_adj, contr_thr, center_vec, thr_val, sphere_rad)
% =========================================================================
% Protocol to define Volume Of Interest (VOI). It must be used with MNI
% data.
% 
% NB: For each subject data must be organized in one folder per subject.
%     Each subject folder must contain these paths:
%           AE/stats/SPM.mat --> statistical analysis
%           AE/splits/smooth_rwSlice_timing_0xyz' --> splitted fmri volumes
%     
%      Subject folders must be saved in a parent folder containing ONLY
%      subject folders
%
% =========================================================================
%   @author: robertalorenzi
%   creation date: Oct 19th, 2021
%   -----------------------------------------------------------------------
%   Input:
%   parent_dir:     String. Path of the parent folder where subjects
%                   folders are stored
%   start_subj:     Int. Id of starting subject for the analysis
%   nsubj:          Int. Number of subjects to analyse
%   VOI_name:       String. Name of VOI
%   F_contr_adj:    Int. Index of contrast used for adjustment of
%                   timeseries
%   contr_thr:      Float. pval thr for finding peak
%   thr_val:        Float. pvalue to include voxel. Default = 0.001
%   center_vec :    Vector of int. Center of VOI
%
%   -----------------------------------------------------------------------
%   Last update:
%   -----------------------------------------------------------------------

   disp('HELLO ROBI!!!! How are u doing? Here I am to work for you! Be happy :D ')
   
    for subject=start_subj:nsubj
        
        name = sprintf('S%d',subject);
    
        if isfolder( fullfile(parent_dir,name) )
        
            cd(fullfile(parent_dir,name,'AE','stats'))
            
            disp('=======================================================')
            fullfile(parent_dir,name,'AE','stats')
            
            % Insert the subject's SPM .mat filename here
            spm_mat_file = 'SPM.mat';
            
            % Start batch
            clear matlabbatch;
       
            
            matlabbatch{1}.spm.util.voi.spmmat  = cellstr(spm_mat_file);
            matlabbatch{1}.spm.util.voi.adjust  = F_contr_adj;                    
            matlabbatch{1}.spm.util.voi.session = 1;                    % Session index
            matlabbatch{1}.spm.util.voi.name    = VOI_name;
            
            % Define threshold on SPM for finding peak
            matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
            matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = contr_thr;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
            matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = thr_val;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
            
            matlabbatch{1}.spm.util.voi.roi{1}.spm.mask...
                = struct('contrast', {}, 'thresh', {}, 'mtype', {});
            
            
            % Define sphere to include the voxel of interest
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = center_vec;
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = sphere_rad;
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.supra.spm = 1;
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.supra.mask = '';
            matlabbatch{1}.spm.util.voi.expression = 'i1 & i2';
            
            
            if strcmp(subj_space,'Native')
                
            
            % Run the batch
            spm_jobman('run',matlabbatch);
            cd(parent_dir);
            
        else
             disp('***************** No Data No Party **********************')
        end
    end
    
end