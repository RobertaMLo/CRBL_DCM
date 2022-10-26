clear
clc
close all

start_dir = pwd ;
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AE_P5';

init_subj = 1; nsubj = 1; estimate = 0;

A_filename = {'A_full.txt'};
B_filename = {'Reduced_Model_1.txt', 'Reduced_Model_2.txt'};
C_filename = {'C_V1.txt'};

DCM_filename = {'trial1', 'trial2'};

GCM_name = 'trialGCM'

n_dcm = 0;

for a = 1:length(A_filename)
    
    %n_dcm = n_dcm + 1;
    
    %DCM_filename{n_dcm}
    
    for c = 1:length(C_filename)

	for b = 1:length(B_filename)

    		n_dcm = n_dcm + 1;
            
            DCM_filename{n_dcm}

        	visuomotor_DCM(protDir, init_subj, nsubj, A_filename{a}, B_filename{b},...
           		 C_filename{c}, DCM_filename{n_dcm}, estimate)

	end     
        
    end
end


%DCM_name = '^DCM_202269_h11m5+'

DCM_name = {'^DCM_202269_h11m14_trial+'}

GCM = GCM_builder(protDir,fullfile(protDir,'GCM_models'), GCM_name, ...
    DCM_name, init_subj, nsubj);

cd(start_dir)
