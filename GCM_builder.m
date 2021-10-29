function GCM = GCM_builder (path_to_save, GCM_filename, DCM_name, start_sub, nsub)
% =========================================================================
% Protocol to build and save a GCM structure. GCM is a group DCM where each
% row i corresponds to suj i and col j corresponds to DCM j. GCM dim =
% n_subjects x n_models. 1st column usually contains the full model name
% =========================================================================
%   @author: robertalorenzi
%   creation date: Sep 13th, 2021
%   -----------------------------------------------------------------------
%   Input
%   path_to_save:  String. Please select the parent folder where each
%                  subjects folders are stored
%   GCM_filename:  String. name of the output GCM file. (.mat)
%
%   DCM_name:      String. name of specifyed DCM (.mat)
%                  

%   nsub:          Int. Number of Subjects icluded in the analysis.
%   -----------------------------------------------------------------------
%   Last update: 26th Oct 2021;
%   -----------------------------------------------------------------------


% 1) Find all DCM files: spm_select
% syntax: option, directory, filter
% option 'FPListRec' to look for DCM file in subfolders. Output: list of
% path
% 'DCM_*' to slect every file which name starts with 'DCM'

GCM_names = {};

c=1; %counter. c=c+1 if the subject exists

for i = start_sub:nsub
    
    name = sprintf('S%d',i)
    sub_folder = fullfile(path_to_save,name);
    
    if isfolder(sub_folder)
        
        dcms = spm_select('FPListRec', sub_folder, DCM_name);
        
        for j =1:size(dcms(:,1))
            GCM_names{c,j} = cellstr(dcms(j,:));
        end
        
        c=c+1;
        
        clear dcms
    else
        disp('***************** No Data No Party **********************')
    end
end


% 2) Prepare output directory
out_dir = path_to_save;
if ~exist(out_dir,'file')
    mkdir(out_dir);
end

% Check if it exists
if exist(fullfile(out_dir,GCM_filename),'file')
    opts.Default = 'No';
    opts.Interpreter = 'none';
    f = questdlg('Overwrite existing GCM?','Overwrite?','Yes','No',opts);
    tf = strcmp(f,'Yes');
else
    tf = true;
end

% 3) Collate & estimate & save
if tf
    % Character array -> cell array. List of the name put in cell array
    % because this object is more handle.
    % GCM = cellstr(dcms);
    
                
    
    % Filenames -> DCM structures. Load DCM file name into cell array
    %GCM = spm_dcm_load(string(GCM_names(:,1:13)));
    GCM = spm_dcm_load(string(GCM_names))
    
    % Estimate DCMs. Fitting of each DCM with the data (1st level). This
    % desn't affect original data in each subj folder.
    % To speed up the computation uncomment below and comment above.
    % This allows the parallel estimation of DCMs
    use_parfor = true ;
    GCM = spm_dcm_fit ( GCM , use_parfor ) ;
    
    % Save estimated GCM
    save(fullfile(path_to_save, GCM_filename),'GCM');
end
end

