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
fMRI_SPM2ndLevel_job.m
Matlab executable.
Group-level analysis of fMRI to find the peak of activations at a group level.
Output: group SPM.mat
IMPROVMENT to be done (minor!!!): make it a FUNCTION suitable for general pipeline by changing the contrast name "action_vs_rest" with general vatiable.
====================================================
T_con_def.m
Matlab function.
Specify T contrast for fMRI activation at GROUP LEVEL.
IMPROVMENT to be done: input not stat_dir but protDir to be consistent with the other protocols.
===================================================
SPM_change_timing_path.m
Matlab function.
Change the timing path of SPM.mat. it MUST be used when SPM.mat is copied on another computer.
====================================================
===================== VOI ==========================
====================================================
VOI_extraction.m
Matlab function.
Extraction of the BOLD signals from the Volume of Interest of each subject by overlapping to the neighbourhood of its peak the mask from group activation VOI*
main: run_VOI_estraction.m
*group activation VOI computed by overlapping Brodmann atlas to group level activation
===================================================
VOI_check.m
Matlab exec.
Plot of Signal extracted from the VOIs
====================================================
===================== DCM ==========================
====================================================
====================================================
DCM_AE.m
Matlab function.
Function with a mega switch from fMRI preprocessing to DCM estimate. Developed with Fulvia's standard (see TVB ecc ecc codes)
TO BE COMPLETED
main: run_DCM_AE.m
===================================================
trial_visuomotor_dcm.m
Matlab function.
Specify (and estimate if required) DCMs. Test different configuration of matrix A,B and C by modifying the script.
IMPROVMENT to be done: change the input instead of the script.
===================================================
visuomotor_dcm.m
Matlab function.
Specify (and estimate if requried) DCMs. Test different configuration of matrix A and C by changing the inputs (txt files for A and C)
IMPROVMENT to be done: make it suitable also for matrix B that could have more than 2D, according to how many modulations are gonna be tesed.
main: run_visuomotor_DCM.m (run also GCM_builder.m)
===================================================
GCM_builer.m
Matlab function.
Take as input specified (not estimated!!!!) DCMs and build a GCM structure, i.e. cell array with rows = nsubjects and cols= nmodels
main: run_GCM_builder_and_estim.m
(also run_visuomotor_DCM.m BUT ONLY for FIXED CONN TEST)
===================================================
model_selection.m
Matlab function.
FFx and/or RFX on subjects models
IMPROVMENT to be done: when more than 2 models, make the delpta F comparison authomatic for all the model combinations.
====================================================
model_reduction.m
Matlab exec.
Implement bayesian model reduction for each model type saved in an already estimate GCM file
====================================================
remove_DCMs.m
Matlab function.
Remove DCMs already specified.
===================================================











