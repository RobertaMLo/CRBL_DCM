function [] = AE_conditions_filemaker(sub_folder, protocol_name, file_mat)
% =========================================================================
%   Save a .mat file of the experimental condition for AE UCL protocol.
%   The output file is used as input in "Multiple Conditions" to compute
%   SPM.mat
% =========================================================================
%   Input:
%   sub_folder = String. subject folder absolute path
%   protocol_name = String. Name of the protocol. For AEO choose between
%                   AE, AO, AOb
%   file_mat    =   String. Name of the file containing raw informations
%   struct_field =  Variable. Name of the "file_mat" structure from which
%                   onset and durations can be taken
%   
%
% -------------------------------------------------------------------------
% author:       robertalorenzi
% date:         Mar 9th 2022 
%
% version:      rev.00 - Mar 9th 2022
% revised by:   robertalorenzi - Sept 20th 2023
% -------------------------------------------------------------------------
%cond_fname = 'conditions.mat';                                             % condition file name. Must be a .mat


load(file_mat);

struct_field = cue.SqueezeANDHOLD;


%load(file_mat)
% EHIIIII CIAOOOOO DEVO ESSERE MODIFICATO


% Number of conditions is the number of the experimental tasks
% Additional condition from params modulation are automatically added.
% Do not include them in the size of cell "names"
names = cell(1,1);
onsets = cell(1,1);
durations = cell(1,1);

names{1} = protocol_name;                                                  % Name of the Experimental condition
onsets{1} = struct_field.Time;                                              % Onset time: Starting time of task execution.
durations{1} = zeros(length(struct_field.Time),1);                          % Duariotion of the condition. 0 because Event-Related design

pmod = struct('name',{''},'param',{},'poly',{});                           % Fixed structure. See spm GUI
%pmod.(condition_number).name{param_number} Here 1 condition (AE) and 1
%params (squeeze = force level)
pmod(1).name{1} = 'force';                                                 % Mod param name
pmod(1).param{1} = struct_field.squeeze;                                    % Mod param values
pmod(1).poly{1} = 4;                                                       % Poly expansion

cd(fullfile(sub_folder,'Functional'))
mkdir('stats')
cd stats
save('cond4SPM', 'names', 'onsets', 'durations', 'pmod')
disp('Conditions file saved: cond4SPM.mat')
cd(sub_folder)
cd ..

