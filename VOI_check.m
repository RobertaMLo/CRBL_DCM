% =========================================================================
% Protocol to plot the timeseries of VOI
% 
% =========================================================================
%   @author: robertalorenzi
%   creation date: Oct 20th, 2021
%   -----------------------------------------------------------------------
%   Last update:
%   -----------------------------------------------------------------------

work_dir = pwd;
parent_dir = '/Users/robertalorenzi/Desktop/Ongoing/DCM/DCM4CRBL/motor_subjs';

subject_id = 1;

name = sprintf('S%d',subject_id);
if isfolder( fullfile(parent_dir,name) )
    
    cd(fullfile(parent_dir,name,'AE','stats'))
    
    fullfile(parent_dir,name,'AE','stats')
%     
%     CRBL_R_A = load('VOI_CRBL_R_A_1.mat').Y;
%     M1_L = load('VOI_M1_L_1.mat').Y;
%     PMC_L = load('VOI_PMC_L_1.mat').Y;
%     SMA_L = load('VOI_SMA_L_1.mat').Y;
%     V1_L = load('VOI_V1_BIL_1.mat').Y;

     CRBL_R_A = load('VOI_CRBL_R_A_T_contr_1.mat').Y;
     M1_L = load('VOI_M1_L_T_contr_1.mat').Y;
     PMC_L = load('VOI_PMC_L_T_contr_1.mat').Y;
     SMA_L = load('VOI_SMA_L_T_contr_1.mat').Y;
     V1_L = load('VOI_V1_BIL_T_contr_1.mat').Y;
     
     CRBL_R_A2 = load('VOI_CRBL_R_A_T_contr_001_1.mat').Y;
     M1_L = load('VOI_M1_L_T_contr_001_1.mat').Y;
     PMC_L = load('VOI_PMC_L_T_contr_001_1.mat').Y;
     SMA_L = load('VOI_SMA_L_T_contr_001_1.mat').Y;
     V1_L = load('VOI_V1_BIL_T_contr_001_1.mat').Y;

% 
%     CRBL_R_A2 = load('VOI_CRBLVI_Fadj_1.mat').Y;
%     M1_L2 = load('VOI_M1_Fadj_1.mat').Y;
%     PMC_L2 = load('VOI_PMC_Fadj_1.mat').Y;
%     SMA_L2 = load('VOI_SMA_Fadj_1.mat').Y;
%     
    figure(1); plot(CRBL_R_A);
    figure(2); plot(M1_L);
    figure(3); plot(PMC_L);
    figure(4); plot(SMA_L);
    figure(5); plot(V1_L);
    
    figure(6);
    plot(CRBL_R_A);
    hold on
    plot(M1_L);
    hold on
    plot(PMC_L);
    hold on
    plot(SMA_L);
    hold on
    plot(V1_L);
end

cd(work_dir)
            
            
            
            
            
            