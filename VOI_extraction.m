function VOI_extraction(folder4spm_mat, VOI_name, contr4adj, contr4act, thrs, mask_abs_path, geometry, center, dimension)
%-----------------------------------------------------------------------
% VOI EXTRACTION PROTOCOL
% protDir = your subject folder (AO_HAND / AE_P5 )
% stats_dir = stats folder of the subjects
% VOI_name = vector that includes the name of the VOIs (Ex: 'V1_BA15115_RL' )
% mask_dir = directory to save the masks. Folder that contains group
% spm.mat (../AO_HAND/Group_analysis)
% mask_abs_path = file contains masks
%
% Job saved on 19-Jan-2022 11:00:50 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%
%-----------------------------------------------------------------------

matlabbatch{1}.spm.util.voi.spmmat = {fullfile(folder4spm_mat,'SPM.mat')};
matlabbatch{1}.spm.util.voi.adjust = contr4adj;
matlabbatch{1}.spm.util.voi.session = 1;

% Name of the VOI. Call it name_of_the_region__numberBA__side
matlabbatch{1}.spm.util.voi.name = VOI_name;%horzcat('VOI',VOI_name,'_mask.nii'); %fixed name structure for VOI extracted with spm

% -------------------------------------------------------------------------
% 1) Define threshold on SPM for finding peak
% -------------------------------------------------------------------------
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = contr4act;
matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = thrs; %Increase if VOI is too small
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});

% -------------------------------------------------------------------------
% Select the mask image from Brodman Atlas
% -------------------------------------------------------------------------
matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {horzcat(mask_abs_path,',1')};
matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;

% -------------------------------------------------------------------------
% Define a geometrical ROI
% -------------------------------------------------------------------------
if strcmp(geometry,'sphere')
    matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = center;
    
    % % if you want to specify center
    %matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = [-5 -4 50];
    
    
    matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius = dimension; %Set it according to the anatomy of region
    
    % % Global max inside mask
    matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
    matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
    
    % % Supra Threshold (no sense with mask, maybe with group SPM
    % matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.supra.spm = 1 ;
    % matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.supra.mask = 'i2';
    
    % % Local (nearest) max inside mask
    % matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.local.spm = 1;
    % matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.local.mask = 'i2';

elseif strcmp(geometry,'box')
    matlabbatch{1}.spm.util.voi.roi{3}.box.centre = center;
    matlabbatch{1}.spm.util.voi.roi{3}.box.dim = dimension;
    matlabbatch{1}.spm.util.voi.roi{3}.box.move.global.spm = 1;
    matlabbatch{1}.spm.util.voi.roi{3}.box.move.global.mask = 'i2';
else
    disp('INVALID VALUE FOR GEOMETRY')
end

matlabbatch{1}.spm.util.voi.expression = 'i1 & i3';

spm_jobman('run',matlabbatch);

end
