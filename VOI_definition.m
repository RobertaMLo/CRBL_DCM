function VOI_definition(parent_dir, VOI_name, contrast_id, conj_id, ... 
 thr_type, thr_value, center_vec, radius)
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
%   creation date: Sep 28h, 2021
%   -----------------------------------------------------------------------
%   Input:
%   parent_dir:     String. Path of the parent folder where subjects
%                   folders are stored
%   VOI_name:       String. Name of VOI
%   contrast_id:    Int. Index of the contrast choosen to adjust data
%   conj_id:        Int. Default = 1. Type of conj of different contrast
%   thr_type:       String. 'none' (Default), 'FWE' to correct data
%   thr_value:      Float. pvalue to include voxel. Default = 0.001
%   center_vec :    Vector of int. Center od VOI
%   radius:         Int. Radius of the OUTER Sphere
%   

%   -----------------------------------------------------------------------
%   Last update:
%   -----------------------------------------------------------------------
    cd(file_path)
    dirlist = dir;
    dirlist = dirlist(3:end); % delete first two element ('.', '..')
    nsubj = size(dirlist);
    
    for subject=1:nsubj(1)
        
        name = sprintf('S%d',subject);
    
        if isfolder( fullfile(parent_dir,name) )
        
            cd(strcat(dirlist(s).name, '/AE/stats'))
            
            % Insert the subject's SPM .mat filename here
            spm_mat_file = 'SPM.mat';
            
            % Start batch
            clear matlabbatch;
            matlabbatch{1}.spm.util.voi.spmmat  = cellstr(spm_mat_file);
            matlabbatch{1}.spm.util.voi.adjust  = 1;                    % Effects of interest contrast number
            matlabbatch{1}.spm.util.voi.session = 1;                    % Session index
            matlabbatch{1}.spm.util.voi.name    = VOI_name;               % VOI name
            
            % Define thresholded SPM for finding the subject's local peak response
            matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat      = {''};
            matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast    = contrast_id;     % Index of contrast for choosing voxels
            matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = conj_id;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc  = thr_type;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh      = thr_value;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.extent      = 0;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.mask ...
                = struct('contrast', {}, 'thresh', {}, 'mtype', {});
            
            % Define large fixed outer sphere
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre     = center_vec; % Set coordinates here
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius     = radius;           % Radius (mm)
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
            
            % Define smaller inner sphere which jumps to the peak of the outer sphere
            matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre           = [0 0 0]; % Leave this at zero
            matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius           = 8;       % Set radius here (mm)
            matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm  = 1;       % Index of SPM within the batch
            matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';    % Index of the outer sphere within the batch
            
            % Include voxels in the thresholded SPM (i1) and the mobile inner sphere (i3)
            matlabbatch{1}.spm.util.voi.expression = 'i1 & i3';
            
            % Run the batch
            spm_jobman('run',matlabbatch);
            
        else
             disp('***************** No Data No Party **********************')
        end
    end
    
end