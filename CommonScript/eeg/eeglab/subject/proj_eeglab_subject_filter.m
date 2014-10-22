%% function EEG = proj_eeglab_subject_filter(EEG, project,channels_type,band_processing)
%  apply to data user selected filters to EEG data
%  filter algorithm is coded by project.preproc.filter_algorithm:
%       * 'pop_eegfiltnew_12'                     = pop_eegfiltnew without the causal/non-causal option. is the default filter of EEGLab,
%                                                 allows to set the band also for notch, so it's more flexible than pop_basicfilter of erplab
%       * 'pop_basicfilter'                       = erplab filters (version erplab_1.0.0.33: more recent presented many bugs)
%       * 'causal_pop_iirfilt_12'                 = causal version of iirfilt
%       * 'noncausal_pop_iirfilt_12'              = noncausal version of iirfilt
%       * 'causal_pop_eegfilt_12'                 = causal pop_eegfilt (old version of EEGLab filters)
%       * 'noncausal_pop_eegfilt_12'              = noncausal pop_eegfilt
%       * 'causal_pop_eegfiltnew_13'              = causal pop_eegfiltnew
%       * 'noncausal_pop_eegfiltnew_13'           = noncausal pop_eegfiltnew
%
%  channels_type = 'global' | 'eeg' | 'eog' | 'emg'
%
%  band_processing apply 'bandpass' or 'bandstop' (notch) filter
%
% % GLOBAL FILTER
% project.preproc.ff1_global    = 0.16;                         % F1:   lower frequency in Hz of the preliminar filtering applied during data import
% project.preproc.ff2_global    = 100;                          % F2:   higher frequency in Hz of the preliminar filtering applied during data import
% 
% % NOTCH
% project.preproc.do_notch      = 1;                            % F3:   define if apply the notch filter at 50 Hz
% project.preproc.notch_fcenter = 50;                           % F4:   center frequency of the notch filter 50 Hz or 60 Hz
% project.preproc.notch_fspan   = 5;                            % F5:   halved frequency range of the notch filters  
% 
% % during pre-processing
% %FURTHER EEG FILTER
% project.preproc.ff1_eeg     = 0.16;                         % F6:   lower frequency in Hz of the EEG filtering applied during preprocessing
% project.preproc.ff2_eeg     = 45;                           % F7:   higher frequency in Hz of the EEG filtering applied during preprocessing
% 
% %FURTHER EOG FILTER
% project.preproc.ff1_eog     = 0.16;                         % F8:   lower frequency in Hz of the EOG filtering applied during preprocessing
% project.preproc.ff2_eog     = 8;                            % F9:   higher frequency in Hz of the EEG filtering applied during preprocessing
% 
% %FURTHER EMG FILTER
% project.preproc.ff1_emg     = 5;                            % F10:   lower frequency in Hz of the EMG filtering applied during preprocessing
% project.preproc.ff2_emg     = 100;                          % F11:   higher frequency in Hz of the EMG filtering applied during preprocessing
%
function EEG = proj_eeglab_subject_filter(EEG, project,channels_type,band_processing)

if nargin < 4
    help proj_eeglab_subject_filter
end

%% set global parameters (independent form the type of filtered channels

params.filter_algorithm            =  project.preproc.filter_algorithm; % filter algorithm
params.band_processing             =  band_processing;                  % 'bandpass' or 'bandstop'

%% set specific parameters of each channel type (modular, so easy to extend)
switch channels_type
    case 'global'
        params.channels_list               =  1:project.eegdata.nch;      % channel list
    case 'eeg'
        params.channels_list               =  project.eegdata.eeg_channels_list;
    case 'eog'
        params.channels_list               =  project.eegdata.eog_channels_list;
    case 'emg'
        params.channels_list               =  project.eegdata.emg_channels_list;
    otherwise
        disp('Unknown channel type')
        return
end


if strcmp(band_processing, 'bandpass')
    switch channels_type
        case 'global'
            params.ff1                         =  project.preproc.ff1_global; % low cutoff frequency
            params.ff2                         =  project.preproc.ff2_global; % high cutoff frequency
        case 'eeg'
            params.ff1                         =  project.preproc.ff1_eeg;
            params.ff2                         =  project.preproc.ff2_eeg;
        case 'eog'
            params.ff1                         =  project.preproc.ff1_eeg;
            params.ff2                         =  project.preproc.ff2_eeg;
        case 'emg'
            params.ff1                         =  project.preproc.ff1_eeg;
            params.ff2                         =  project.preproc.ff2_eeg;
        otherwise
            disp('Unknown channel type')
            return
    end
    
    EEG = eeglab_subject_bandpass(EEG, params);
end

if strcmp(band_processing, 'bandstop')
    
    params.notch_fcenter = project.preproc.notch_fcenter;  % center frequency of the notch filter 50 Hz or 60 Hz
    params.notch_fspan   = project.preproc.notch_fspan;    %  halved frequency range of the notch filters
   
    EEG = eeglab_subject_bandstop(EEG, params);
end


end

