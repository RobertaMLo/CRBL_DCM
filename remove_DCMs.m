function []= remove_DCMs(protDir, init_subj, nsubj, DCM_name)


for subject = init_subj:nsubj
    disp('********************* Removing... *********************')
    name = sprintf('S%d',subject)
    
    if isfolder( fullfile(protDir,name,'Functional/stats/DCM_models') )
        
        cd(fullfile(protDir,name,'Functional/stats/DCM_models'))
        
        horzcat('rm', DCM_name);
        
        cd(protDir);
    else
        disp('***************** No Data No Party **********************')
    end
    
end
