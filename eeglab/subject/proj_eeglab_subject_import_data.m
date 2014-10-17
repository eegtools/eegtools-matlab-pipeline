
function EEG = proj_eeglab_subject_import_data(project, subj_name)

    % function EEG = eeglab_subject_import_data(project, subj_name)
    % function to import data into eeglab from different file format 
    % discard undesired electrodes
    % apply specific filtering for eeg,eog and emg channels
    
    % INPUTS:
    % project structure containing all the project info
    % subjects name

    input_file_name=fullfile(project.paths.original_data, [project.import.original_data_prefix subj_name project.import.original_data_suffix '.' project.import.original_data_extension]);
    [path,name_noext,ext] = fileparts(input_file_name);
    
    ff1_global=project.preproc.ff1_global;
    ff2_global=project.preproc.ff2_global;
    
    nch=project.eegdata.nch;
    nch_eeg=project.eegdata.nch_eeg;
    
    eeglab_channels_file=project.eegdata.eeglab_channels_file_path;
    % --------------------------------------------------------------------------------------------------------------------------------------------
    
    switch project.import.acquisition_system
        case 'BRAINAMP'
            % load vhdr data
            EEG = pop_loadbv(path, [name_noext,ext]); ..., [], 1:nch_eeg);

   
        case 'BIOSEMI'
            EEG = pop_biosig(input_file_name, 'importannot','off');
            
    ... case 'OTHER SYSTEMS'
    end

    % EVENT SELECTING
    % convert events type to string & remove blanks from events' labels
    for ev=1:size(EEG.event,2)
        EEG.event(ev).type = num2str(EEG.event(ev).type);
        EEG.event(ev).type = regexprep(EEG.event(ev).type,' ','');
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

% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 1/10/2014
% modified filtering section
% blank removed from events' labels

% 30/1/2014
% first version of the new project structure