function VOI_extraction_subjects(sub_folder, VOI_name, center, contr4adj, contr4act, thrs, mask_abs_path, geometry, dimension)
%-----------------------------------------------------------------------
% VOI EXTRACTION PROTOCOL FOR SINGLE SUBJECT VOI
% sub_folder: protocol directory + folder where subject are saved
% VOI_name = vector that includes the name of the VOIs (Ex: 'V1_BA15115_RL' )
% mask_abs_path = file contains masks (../AO_HAND/Group_analysis)
%-----------------------------------------------------------------------


%matlabbatch{1}.spm.util.voi.spmmat = {'/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND_BAR/S2/Functional/stats/SPM.mat'};
matlabbatch{1}.spm.util.voi.spmmat = {fullfile(sub_folder, 'Functional/stats/SPM.mat')};
% contrast for adjustment
matlabbatch{1}.spm.util.voi.adjust = contr4adj;
% session of fmri (1 session for AE data)
matlabbatch{1}.spm.util.voi.session = 1;

% VOI name
matlabbatch{1}.spm.util.voi.name = VOI_name;
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
% contrast for activation
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = contr4act;

%fixed field
matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';

%threshold of activation of spm
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = thrs;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});

% mask
matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {horzcat(mask_abs_path,',1')};
matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5; %threshold mask fixed


if strcmp(geometry,'sphere')

    matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = center; %center at 0 to move to local max
    matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius = dimension;
    
    % center allowed to moved
    %matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.local.spm = 1;
    %matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.local.mask = 'i2';
    
    matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
    matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';

elseif strcmp(geometry,'box')

    matlabbatch{1}.spm.util.voi.roi{3}.box.centre = center;
    matlabbatch{1}.spm.util.voi.roi{3}.box.dim = dimension;
    
    %matlabbatch{1}.spm.util.voi.roi{3}.box.move.local.spm = 1;
    %matlabbatch{1}.spm.util.voi.roi{3}.box.move.local.mask = 'i2';
    
    matlabbatch{1}.spm.util.voi.roi{3}.box.move.global.spm = 1;
    matlabbatch{1}.spm.util.voi.roi{3}.box.move.global.mask = 'i2';

else
    disp('INVALID VALUE FOR GEOMETRY')
end

matlabbatch{1}.spm.util.voi.expression = 'i1 & i3 & i2';

spm_jobman('run',matlabbatch);

end
