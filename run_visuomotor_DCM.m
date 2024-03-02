clear
clc
close all

start_dir = pwd ;
protDir = '/media/bcc/Volume/Analysis/Roberta/DCM/AO_HAND_BAR';

estimate_dcm = 0;

A_filename = {'Reduced_Model_1.txt','Reduced_Model_2.txt','Reduced_Model_3.txt','Reduced_Model_4.txt','Reduced_Model_5.txt'};
B_filename = {''};
C_filename = {'C_V1.txt'};

DCM_filename = {'red1', 'red2', 'red3','red4', 'red5'};

GCM_name = 'GCM_fixed_conn_last2';

n_dcm = 0;

for a = 1:length(A_filename)
    
    %n_dcm = n_dcm + 1;
    
    %DCM_filename{n_dcm}
    
    for c = 1:length(C_filename)

	    for b = 1:length(B_filename)

    		    n_dcm = n_dcm + 1;
            
                DCM_filename{n_dcm}

        	    visuomotor_DCM(protDir, A_filename{a}, B_filename{b},...
           		 C_filename{c}, DCM_filename{n_dcm}, estimate_dcm)

	    end     
        
    end
end


%DCM_name = '^DCM_202269_h11m5+'

DCM_name = {'^DCM_2023106_h17'};
sub_vec = [2 7 8 9 10 12 13]
GCM = GCM_builder(protDir,fullfile(protDir,'GCM_models'), GCM_name, ...
    DCM_name, sub_vec);

cd(start_dir)
