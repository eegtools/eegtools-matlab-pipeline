function EEG = eeglab_subject_events_correct_event_code_biosemi(input_file_name)
%    function EEG = eeglab_subject_correct_event_code_biosemi(input_file_name, settings_path)
%    correct event labels (decimal codes) for biosemi in case the 8 highest pins are wrongly on.    
%    input_file_name is the full path of the input file (.set EEGLab format)

%     % load configuration file
%     [path,name_noext,ext] = fileparts(settings_path);
%     addpath(path);    eval(name_noext);
%     
    EEG = pop_loadset(input_file_name);

    raw_event_code_dec=[EEG.event.type];
    raw_event_code_bin=dec2bin(raw_event_code_dec);
    cor_event_code_bin=raw_event_code_bin(:,9:end);
    cor_event_code_dec=bin2dec(cor_event_code_bin);
    for neve=1:length(cor_event_code_dec)
        EEG.event(neve).type=cor_event_code_dec(neve);
    end
    EEG = pop_saveset( EEG, 'filename',EEG.filename ,'filepath',EEG.filepath);
end