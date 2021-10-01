function SPM_change_timing_path(file_path)
% =========================================================================
% Protocol to change the path of fmri file in SPM structure
% 
%filed =  SPM.xY.VY
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
%   creation date: Sep 7th, 2021
%   -----------------------------------------------------------------------
%   Input:
%   file_path: String. Path of the parent folder where subjects folders
%                      are stored

%   -----------------------------------------------------------------------
%   Last update: Sep 7th, 2021
%   -----------------------------------------------------------------------


cd(file_path)
dirlist = dir;
dirlist = dirlist(3:end); % delete first two element ('.', '..')
nsubj = size(dirlist);

disp(strcat('Number of subjects: ',num2str(nsubj(1))))

for i=1:nsubj(1) % loop on subjects folder
    
    cd(strcat(dirlist(i).name, '/AE/stats'))
    
    disp(strcat('Here I am: ',pwd))
    disp('I am loading the SPM.mat file')
    
    load('SPM.mat')
    
    cd('../splits')
    file_list = dir;
    w = 1;

    disp(strcat('I am looking for fmri volume in: ',pwd))
    
    for k = 1:size(file_list) %loop on files to save the path
        if (contains(file_list(k).name, 'smooth_rwSlice_timing_') == 1)
            new_path(w,:) = strcat(file_list(k).folder,'/',file_list(k).name);
            w = w + 1;
        end
    end
    
    
    for j = 1:size(SPM.xY.VY,1) %loop to change the field of SPM
        SPM.xY.VY(j).fname = new_path(j,:);
    end
    
    disp(strcat('Done with subject S', num2str(i),...
        ' out of ', num2str(nsubj(1))))
    
    cd('../stats')
  
    save('SPM.mat', 'SPM')
    
    disp(strcat('New SPM.mat saved in ', pwd))
    
    disp(strcat('Done with subject S', num2str(i),...
        ' out of ', num2str(nsubj(1))))
    disp('=====================================================================================')
    
    cd('../../..')
 
end

