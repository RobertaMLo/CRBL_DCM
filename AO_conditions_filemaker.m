function [] = AO_conditions_filemaker(file_mat,struct_name)
% =========================================================================
%   Save a .mat file of the experimental condition for AE UCL protocol.
%   The output file is used as input in "Multiple Conditions" to compute
%   SPM.mat
% =========================================================================
%   Input:
%   file_mat   = String. Name of the file containing raw informations
%   cond_fname = String. Name of the conditions file. Must be a .mat
%
% -------------------------------------------------------------------------
% author:       robertalorenzi
% date:         Mar 9th 2022 
%
% version:      rev.00 - Mar 9th 2022
% revised by:   
% -------------------------------------------------------------------------
%cond_fname = 'conditions.mat';                                             % condition file name. Must be a .mat

%load(file_mat)


% Number of conditions is the number of the experimental tasks
% Additional condition from params modulation are automatically added.
% Do not include them in the size of cell "names"
names = cell(1,1);
onsets = cell(1,1);
durations = cell(1,1);

names{1} = 'AE';                                                           % Name of the Experimental condition
onsets{1} = struct_name.Time;                                    % Onset time: Starting time of task execution.
durations{1} = zeros(length(struct_name.Time),1);                % Duariotion of the condition. 0 because Event-Related design

pmod = struct('name',{''},'param',{},'poly',{});                           % Fixed structure. See spm GUI
%pmod.(condition_number).name{param_number} Here 1 condition (AE) and 1
%params (squeeze = force level)
pmod(1).name{1} = 'force';                                                 % Mod param name
pmod(1).param{1} = struct_name.squeeze;                                    % Mod param values
pmod(1).poly{1} = 4;                                                       % Poly expansion

save('Functional/stats/cond4SPM', 'names', 'onsets', 'durations', 'pmod')
disp('Conditions file saved: cond4SPM.mat')

