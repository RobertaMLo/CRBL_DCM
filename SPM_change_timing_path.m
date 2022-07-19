function SPM_change_timing_path(protDir, start_subj, nsubj)
% =========================================================================
% Protocol to change the path of fmri file in SPM structure
%
%filed =  SPM.xY.VY
%
% NB: For each subject data must be organized in one folder per subject.
%     Each subject folder must contain these paths:
%           Functional/stats/SPM.mat --> statistical analysis
%           Functional/splits/vol_filename.nii' --> splitted fmri volumes
% 
% Subjects' folder must be saved in protDir, which is the parent folder
% named as the protocol (i.e. AE_PF/SXX)
%
% =========================================================================
%   @author: robertalorenzi
%   creation date: Sep 7th, 2021
%   -----------------------------------------------------------------------
%   Input:
%   protDir:    String. Path of the protocol direvtory, i.e. the parent directory
%                       where subjects folders are stored
%   start_subj: Int. ID of the first subject
%   nsubj:      Int. Number of subject to analyze, or last subject ID

%   -----------------------------------------------------------------------
%   Last update: Apr 19th, 2022
%   -----------------------------------------------------------------------

% Path on lab PC bcc15: /media/bcc/Volume/Analysis/Roberta/DCM/AE_P5

current_path = pwd;

disp(strcat('Number of subjects: ',num2str(nsubj)))

for i=start_subj:nsubj % loop on subjects folder
    
    name = sprintf('S%d',i)
    sub_folder = fullfile(protDir,name)
    
    if isfolder(fullfile(sub_folder,'Functional/stats'))
        
        spm_folder = fullfile(sub_folder,'Functional/stats')
        %cd(strcat(sub_folder, '/AE/stats'))
        %disp(strcat('Here I am: ',pwd))
        disp('I am loading the SPM.mat file')
        
        load(fullfile(spm_folder,'SPM.mat'))
        
        cd(fullfile(sub_folder,'Functional/Preproc_fMRI/swsplits_mni2mm'))
        file_list = dir;
        w = 1;
        
        disp(strcat('I am looking for fmri volume in: ',pwd))
        
        for k = 1:size(file_list) %loop on files to save the path
            if (contains(file_list(k).name, 'swf') == 1)
                new_path(w,:) = fullfile(file_list(k).folder,file_list(k).name);
                w = w + 1;
            end
        end
        
        
        for j = 1:size(SPM.xY.VY,1) %loop to change the field of SPM
            %SPM.xY.VY(j).fname
            SPM.xY.VY(j).fname = new_path(j,:);
        end
        
        disp(strcat('Done with subject S', num2str(i),...
            ' out of ', num2str(nsubj(1))))
        
        cd(spm_folder)
        
        %save('SPM.mat', 'SPM')
        
        disp(strcat('New SPM.mat saved in ', pwd))
        
        disp(strcat('Done with subject S', num2str(i),...
            ' out of ', nsubj))
        disp('=====================================================================================')
        
    else
        disp("No data for this Subject")
        continue
    end
    
    cd(current_path)
    
end

