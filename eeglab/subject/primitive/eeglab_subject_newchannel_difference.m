%% EEG = eeglab_subject_newchannel_difference(project, varargin)
%
% function to preprocess already imported and filtered data
%
% SUBSAMPLING
% CHANNELS TRANSFORMATION
% INTERPOLATION
% RE-REFERENCE
% EVENT FILTERING
% SPECIFIC FILTERING
%
%%
function EEG = eeglab_subject_newchannel_difference(input_file_name, newch_name, chlabel1, chlabel2, varargin)

    EEG                         = pop_loadset(input_file_name);

    data1_id                    = ismember({EEG.chanlocs.labels}, chlabel1);
    data2_id                    = ismember({EEG.chanlocs.labels}, chlabel2);

    data1                       = EEG.data(data1_id, :);
    data2                       = EEG.data(data2_id, :);

    diff_data                   = data1 - data2;

    % check if ch to add is already present
    newch_id                    = find(ismember({EEG.chanlocs.labels}, newch_name));
    
    if isempty(newch_id)
        EEG.data(end+1,:)           = diff_data;
        EEG.chanlocs(end+1)         = EEG.chanlocs(data1_id);
        EEG.chanlocs(end).labels    = newch_name;
        EEG.chanlocs(end).ref       = [EEG.chanlocs(data1_id).ref ' - ' chlabel2];
    else
        EEG.data(newch_id,:)        = diff_data;
    end
    
    EEG                         = eeg_checkset(EEG);
    [path,name_noext, ~]        = fileparts(input_file_name);
    EEG                         = pop_saveset( EEG, 'filename', name_noext, 'filepath', path);

end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 28/05/2015
% first version