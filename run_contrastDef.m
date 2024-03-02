% % Executable file for defining contrast
% % SPM.mat required
% % It calls Stat_con_def, which is batch-generated code to compute F or T contrast 

clc
clear

work_dir = '/home/bcc/matlab/Roberta/CRBL_DCM';

disp('Here is my protocol director')
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND_BAR';

% subject to analyse
subj_vec = [2 7 8 10 12 13];

con_nameT = 'AOhb_vs_rest';
con_nameF = 'Fcont';

con_vect = [1 0 0 0 0 0];

con_vectF = [1 1 1 1 1 1];

delete_bool = 1; %NOT delete = 0


for i = 1:length(subj_vec)
    disp('*************************  Working on: *************************')
    subject = subj_vec(i);

    sub_id = sprintf('S%d',subj_vec(i))
    sub_folder = fullfile(protDir,sub_id)

    Stat_con_def('T', sub_folder, con_nameT, con_vect, delete_bool)
    Stat_con_def('F', sub_folder, con_nameF, con_vectF, 0)

end
