%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_recover_raw(project, varargin)

		

    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'output_import_data';
    custom_suffix           = '';
    custom_input_folder     = '';
    
    for par=1:2:length(varargin)
        switch varargin{par}
            case {  ...
                    'list_select_subjects', ...
                    'get_filename_step',    ... 
                    'custom_input_folder',  ...
                    'custom_suffix' ...
                    };

                if isempty(varargin{par+1})
                    continue;
                else
                    assign(varargin{par}, varargin{par+1});
                end
        end
    end

    if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
    
    numsubj = length(list_select_subjects);
    
    % -------------------------------------------------------------------------------------------------------------------------------------

%     names = {};
%     durations = {};
%     ranks = {};
%     ica_types ={};
    
    for subj=1:numsubj
        
        subj_name   = list_select_subjects{subj}; 
        outputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
        
        [filepath,name_noext,ext] = fileparts(outputfile);
        
        bckfile = fullfile(filepath,[name_noext,'_raw',ext]);
        
        disp(['recovering ' bckfile])
                     
%         EEG = pop_loadset(bckfile);
        try
            EEG                     = pop_loadset(bckfile);
        catch
            [fpath,fname,fext] = fileparts(bckfile);
            EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
        end
        
        EEG = pop_saveset( EEG, 'filename',[name_noext, ext],'filepath',EEG.filepath);

   
    end
    
%     summary = [names; ranks; ica_types; durations]';
%     disp(summary);
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_name_noext function to define IO file name
