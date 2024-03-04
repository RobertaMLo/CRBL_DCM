<<<<<<< HEAD
function [] = AO_conditions_filemaker(file_mat,assigned_struct)
% =========================================================================
%   Save a .mat file of the experimental condition for AE UCL protocol.a
%   The output file is used as input in "Multiple Conditions" to compute
%   SPM.mat
% =========================================================================
%   Input:
%   file_mat    = String. Name of the file containing raw informations
%   assigned_struct = Assign the structure. PUT THE NAME OF THE STRUC WITHOUT
%   APEX '' e.g.: assigned_strcut = ciao (NOT 'ciao')
%
% -------------------------------------------------------------------------
% author:       robertalorenzi
% date:         Mar 9th 2022 
%
% version:      rev.01 - Feb 2024
% revised by:   robertlorenzi
% comments:     to be pushed on github as final version - it should be same of AE
% -------------------------------------------------------------------------

load(file_mat)

% Number of conditions is the number of the experimental tasks
% Additional condition from params modulation are automatically added.
% Do not include them in the size of cell "names"
names = cell(1,1);
onsets = cell(1,1);
durations = cell(1,1);


%names{1} = 'AObar';                                                        % Name of the Experimental condition: AE, AO, AObar
%onsets{1} = cue.SqueezeANDHOLD.Time;                                       % Onset time: Starting time of task execution.
%durations{1} = zeros(length(cue.SqueezeANDHOLD.Time),1);                   % Duariotion of the condition. 0 because Event-Related design

%pmod = assigned_struct('name',{''}, 'param' ,{},'poly',{});                 % Fixed structure. See spm GUI
%pmod.(condition_number).name{param_number} Here 1 condition (AE) and 1
%params (squeeze = force level)
%pmod(1).name{1} = 'force';                                                 % Mod param name
%pmod(1).param{1} = cue.SqueezeANDHOLD.squeeze;                             % Mod param values


% In theory assigned struct should be cue.SqueezeANDHOLD
names{1} = 'AObar';                                                           % Name of the Experimental condition
onsets{1} = assigned_struct.Time;                                    % Onset time: Starting time of task execution.
durations{1} = zeros(length(assigned_struct.Time),1);                % Duariotion of the condition. 0 because Event-Related design

pmod = struct('name',{''},'param',{},'poly',{});                           % Fixed structure. See spm GUI
%pmod.(condition_number).name{param_number} Here 1 condition (AE) and 1
%params (squeeze = force level)
pmod(1).name{1} = 'force';                                                 % Mod param name
pmod(1).param{1} = assigned_struct.squeeze;                                    % Mod param values
pmod(1).poly{1} = 4;                                                       % Poly expansion

save('Functional/stats/cond4SPM', 'names', 'onsets', 'durations', 'pmod')
disp('Conditions file saved: cond4SPM.mat')
