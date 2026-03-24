
By using this pipeline you agree:

i)  to cite our work: Lorenzi RM, Korkmaz G, Alahmadi AAS, Monteverdi A, Casiraghi L, 
 D'Angelo E, Palesi F, Gandini Wheeler-Kingshott CAM. 
Cerebellar control over inter-regional excitatory/inhibitory dynamics discriminates execution
from observation of an action. 
Cerebellum. 2025 Jun 16;24(4):115. doi: 10.1007/s12311-025-01863-6.

ii) to collaborate with Dr. Roberta M. Lorenzi, Dr. Gokce Korkmaz, Prof. Fulvia Palesi, 
    Prof. Egidio D'Angelo, and  Prof. Claudia Gandini Wheeler Kingshott



====================================================
===================== fMRI =========================
====================================================
AE_conditions_filemaker.m
Builder of the condition file for SPM computation. From raw data to mat file suitable for fMRI preporcessing
main:run_AE_conditions_filemaker.m
====================================================
fMRI_SPM_AE_job.m
Matlab function.
Compute SPM.mat from preprocessed fMRI
Output: SPM.mat for each subject
IMPROVMENT to be done (minor!!!): change input_vols with protDir to make the code suitable for the integration into DCM_AE.m
====================================================
fMRI_smooth_DCM_job
Matlab function.
fMRI smooting - save the smoothed vols in subhect directory
====================================================
fMRI_SPM_AE_GLMestim_job.m
GLM to compute betas. (Just the job saved from matlab batch and transformed into a function)
====================================================
fMRI_MNI_norm_DCM
warping into MNI space
OUTPUT: normlaized vols for each subject
====================================================
fMRI_SPM2ndLevel_jobfun_25.m
function to compute group SPM .mat
Output: group SPM.mat
IMPROVMENT DONE: loop on subjects is outside the function!! It takes as input the location where to save group SPM.mat, the single subject contrasts computed suring first level analysis in the form required by spm {full path/name.nii, 1} and name of the group level contrast 
====================================================
T_con_def.m
Matlab function.
Specify T contrast for fMRI activation at GROUP LEVEL.
===================================================

====================================================
===================== VOI ==========================
====================================================
VOI_extraction.m
Matlab function.
Extraction of the BOLD signals from the Volume of Interest of each subject by overlapping to the neighbourhood of its peak the mask from group activation VOI*
main: run_VOI_estraction.m
*group activation VOI computed by overlapping Brodmann atlas to group level activation
===================================================
