
function EEG = proj_eeglab_subject_import_data(project, varargin)

% function EEG = eeglab_subject_import_data(project, subj_name)
% function to import data into eeglab from different file format
% discard undesired electrodes
% apply specific filtering for eeg,eog and emg channels

% INPUTS:
% project structure containing all the project info
% subjects name

list_select_subjects  = project.subjects.list;


options_num=size(varargin,2);

for opt=1:2:options_num    
    switch varargin{opt}
        case 'list_select_subjects'
            list_select_subjects=varargin{opt+1};
    end
end

numsubj = length(list_select_subjects);

for subj=1:numsubj
    subj_name = list_select_subjects{subj};
    
    input_file_name         = fullfile(project.paths.original_data, [project.import.original_data_prefix subj_name project.import.original_data_suffix '.' project.import.original_data_extension]);
    [path,name_noext,ext]   = fileparts(input_file_name);
    
    eeglab_channels_file    = project.eegdata.eeglab_channels_file_path;
    % --------------------------------------------------------------------------------------------------------------------------------------------
    
    switch project.import.acquisition_system
        case 'BRAINAMP'
            % load vhdr data
            EEG = pop_loadbv(path, [name_noext,ext]); ..., [], 1:nch_eeg);
                % EVENT SELECTING
            % convert events type to string & remove blanks from events' labels
            for ev=1:size(EEG.event,2)
                EEG.event(ev).type = regexprep(EEG.event(ev).type,' ','');
            end
            
        case 'BIOSEMI'
            EEG = pop_biosig(input_file_name, 'importannot','off');
            % EVENT SELECTING
            % convert events type to string & remove blanks from events' labels
            for ev=1:size(EEG.event,2)
                EEG.event(ev).type = num2str(EEG.event(ev).type);
            end
            
        otherwise
            error(['unrecognized device (' project.import.acquisition_system ')']);
    end
    
    EEG = pop_chanedit( EEG, 'lookup',eeglab_channels_file);    ...  considering using a same file, suitable for whichever electrodes configuration
        EEG = eeg_checkset( EEG );
    
    % global filtering
    
    EEG = proj_eeglab_subject_filter(EEG, project, 'global', 'bandstop');
    EEG = eeg_checkset( EEG );
    
    EEG = proj_eeglab_subject_filter(EEG, project, 'global', 'bandpass');
    EEG = eeg_checkset( EEG );
    %===============================================================================================
    % CHECK & SAVE
    %===============================================================================================
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename', [name_noext project.import.output_suffix], 'filepath', project.paths.input_epochs);
end
end

% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 11/12/2014
% added 'otherwise' case in switch statement, variable cleaning

% 1/10/2014
% modified filtering section
% blank removed from events' labels

% 30/1/2014
% first version of the new project structure