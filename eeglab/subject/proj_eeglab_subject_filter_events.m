%% EEG = proj_eeglab_subject_filter_events(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_filter_events(project, varargin)

		

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
                    }

                if isempty(varargin{par+1})
                    continue;
                else
                    assign(varargin{par}, varargin{par+1});
                end
        end
    end

    if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
    
    numsubj = length(list_select_subjects);
    vsel_sub = find(ismember(project.subjects.list,list_select_subjects));
    
    % -------------------------------------------------------------------------------------------------------------------------------------

%     names = {};
%     durations = {};
%     ranks = {};
%     ica_types ={};
    
    for subj=1:numsubj
        sel_sub = vsel_sub(subj);
        subj_name   = list_select_subjects{subj}; 
        inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);

        EEG = pop_loadset(inputfile);
        
        if isempty(project.import.filter_events.list)
            disp(['list of event to select is empty!' ])
        else
            disp(['selecting events in ',  inputfile])
            
            alleve = 1:length(EEG.event);
            match_eve = strfind_index({EEG.event.type},project.import.filter_events.list);
            
            if strcmp(project.import.filter_events.filter, 'select')
                sel_eve = match_eve;
            else
                sel_eve = find(not( ismember(alleve,match_eve)));
            end
            
            EEG.event = EEG.event(sel_eve);
            EEG = eeg_checkset( EEG );
            
            eeglab redraw
            
            EEG                     = pop_saveset( EEG, 'filename', EEG.filename, 'filepath', EEG.filepath);

        end
   
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
% utilization of proj_eeglab_subject_get_filename function to define IO file name
