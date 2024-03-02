function VOI_definition_spheres_MNI_native(parent_dir, start_subj, nsubj, subject_space, VOI_name, contr4adj, contr_index, center_vec, geometry, dimension, thr_val)
% =========================================================================
% Protocol to define Volume Of Interest (VOI)
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
%   start_subj =    Int. Id of starting subject for the analysis
%   nsubj:          Int. Number of subjects to analyse
%   contr4adj:      Int. Index of F contrast in SPM.mat
%   VOI_name:       String. Name of VOI
%   subject_space:  String. Choose 'Native' or 'MNI'
%   thr_val:        Float. pvalue to include voxel. Default = 0.001
%   center_vec :    Int. Center od VOI
%   dimension:      Int. Radius of the sphere or dim of the box
%
%   -----------------------------------------------------------------------
%   Last update:
%   -----------------------------------------------------------------------

    for subject=start_subj:nsubj
        
        name = sprintf('S%d',subject);
    
        if isfolder( fullfile(parent_dir,name) )
        
            cd(fullfile(parent_dir,name,'Functional','stats'))
            
            disp('=======================================================')
            disp('HELLO ROBI!!!! How are u doing? Here I am to work for you! Be happy :D ')
            fullfile(parent_dir,name,'Functional','stats')
            
            % Insert the subject's SPM .mat filename here
            spm_mat_file = 'SPM.mat';
            
            % Start batch
            clear matlabbatch;
            matlabbatch{1}.spm.util.voi.spmmat  = cellstr(spm_mat_file);
            matlabbatch{1}.spm.util.voi.adjust  = contr4adj;                    
            matlabbatch{1}.spm.util.voi.session = 1;                    % Session index
            matlabbatch{1}.spm.util.voi.name    = VOI_name;             % VOI name
            
            % Define thresholded SPM for finding the subject's local peak response
            matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat      = {''};
            matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast    = contr_index;     % Index of contrast for choosing voxels
            matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc  = 'none';
            matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh      = thr_val;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.extent      = 0;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.mask ...
                = struct('contrast', {}, 'thresh', {}, 'mtype', {});
            
            % Define sphere
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre     = center_vec; % Set coordinates here
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius     = dimension;           % Radius (mm)
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.global.spm = 1;
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.global.mask = 'i2'
                
            
            if strcmp(subject_space,'MNI')
                % Include voxels in the thresholded SPM (i1) and the sphere(i2)
                matlabbatch{1}.spm.util.voi.expression = 'i1 & i2';
                
            elseif strcmp(subject_space,'Native')
                % Define smaller inner sphere which jumps to the peak of the outer sphere
                matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre           = [0 0 0]; % Leave this at zero
                matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius           = 6;       % Set radius here (mm)
                matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm  = 1;       % Index of SPM within the batch
                matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';    % Index of the outer sphere within the batch: {2} sopra
                % Include voxels in the thresholded SPM (i1) and the mobile inner sphere (i3)
                matlabbatch{1}.spm.util.voi.expression = 'i1 & i3';
            end
            
            % Run the batch
            spm_jobman('run',matlabbatch);
            cd(parent_dir);
            
        else
             disp('***************** No Data No Party **********************')
        end
    end
    
end
