%% function  EEG = eeglab_subject_bandpass(EEG,params)
% apply a bandpass filter based on the parameters provided by the structure params:
% params.filter_algorithm         
% params.band_processing             
% params.channels_list               
% params.ff1                         
% params.ff2                         
%
%
function  EEG = eeglab_subject_bandpass(EEG, params)
    if nargin < 2
        help proj_eeglab_subject_bandpass
    end

   switch params.filter_algorithm

   %##################################################################################
        %   pop_iirfilt() - interactively filter EEG dataset data using iirfilt()
        %   Usage:
        %     >> EEGOUT = pop_iirfilt( EEG, locutoff, hicutoff);
        %     >> EEGOUT = pop_iirfilt( EEG, locutoff, hicutoff, trans_bw, revfilt, causal);
        %
        %   Graphical interface:
        %     "Lower edge ..." - [edit box] Lower edge of the frequency pass band (Hz)
        %                   Same as the 'locutoff' command line input.
        %     "Higher edge ..." - [edit box] Higher edge of the frequency pass band (Hz)
        %                   Same as the 'hicutoff' command line input.
        %     "Notch filter" - [edit box] provide the notch range, i.e. [45 55]
        %                   for 50 Hz). This option overwrites the low and high edge limits
        %                   given above. Set the 'locutoff' and 'hicutoff' values to the
        %                   values entered as parameters, and set 'revfilt to 1, to swap
        %                   from bandpass to notch filtering.
        %     "Filter length" - [edit box] Filter lenghth in point (default: see
        %                   >> help pop_iirfilt). Same as 'trans_bw' optional input.
        %
        %   Inputs:
        %     EEG       - input dataset
        %     locutoff  - lower edge of the frequency pass band (Hz)  {0 -> lowpass}
        %     hicutoff  - higher edge of the frequency pass band (Hz) {0 -> highpass}
        %     trans_bw  - length of the filter in points {default 3*fix(srate/locutoff)}
        %     revfilt   - [0|1] Reverse filter polarity (from bandpass to notch filter).
        %                       Default is 0 (bandpass).
        %     causal    - [0|1] use causal filter.
        %
        %   Outputs:
        %     EEGOUT   - output dataset
       
        case 'causal_pop_iirfilt_12'
            EEG2                          = pop_select(EEG,'channel',params.channels_list);
            EEG2                          = pop_iirfilt(EEG2,params.ff1, params.ff2, [], 0, 1);
            EEG.data(params.channels_list,:) = EEG2.data;
            
        case 'noncausal_pop_iirfilt_12'
            EEG2                          = pop_select(EEG,'channel',channels_list);
            EEG2                          = pop_iirfilt(EEG2,params.ff1, params.ff2, [], 0, 0);
            EEG.data(params.channels_list,:) = EEG2.data;
       
    %##################################################################################
        %  pop_eegfilt() - interactively filter EEG dataset data using eegfilt()
        %  
        %   Usage:
        %     >> EEGOUT = pop_eegfilt( EEG, locutoff, hicutoff, filtorder);
        %  
        %   Graphical interface:
        %     "Lower edge ..." - [edit box] Lower edge of the frequency pass band (Hz) 
        %                   Same as the 'locutoff' command line input.
        %     "Higher edge ..." - [edit box] Higher edge of the frequency pass band (Hz) 
        %                   Same as the 'hicutoff' command line input.
        %     "Notch filter" - [edit box] provide the notch range, i.e. [45 55] 
        %                   for 50 Hz). This option overwrites the low and high edge limits
        %                   given above. Set the 'locutoff' and 'hicutoff' values to the
        %                   values entered as parameters, and set 'revfilt to 1, to swap
        %                   from bandpass to notch filtering.
        %     "Filter length" - [edit box] Filter lenghth in point (default: see 
        %                   >> help eegfilt). Same as 'filtorder' optional input.
        %  
        %   Inputs:
        %     EEG       - input dataset
        %     locutoff  - lower edge of the frequency pass band (Hz)  {0 -> lowpass}
        %     hicutoff  - higher edge of the frequency pass band (Hz) {0 -> highpass}
        %     filtorder - length of the filter in points {default 3*fix(srate/locutoff)}
        %     revfilt   - [0|1] Reverse filter polarity (from bandpass to notch filter). 
        %                       Default is 0 (bandpass).
        %     usefft    - [0|1] 1 uses FFT filtering instead of FIR. Default is 0.
        %     firtype   - ['firls'|'fir1'] filter design method, default is 'firls'
        %     causal    - [0|1] 1 uses causal filtering. Default is 0.
        %  
        %   Outputs:
        %     EEGOUT   - output dataset        
       
        case 'causal_pop_eegfilt_12'
            EEG2                          = pop_select(EEG,'channel',params.channels_list);
            EEG2                          = pop_eegfilt( EEG2,params.ff1, params.ff2, [], 0, 0, 0, 'fir1', 1);
            EEG.data(params.channels_list,:) = EEG2.data;
            
        case 'noncausal_pop_eegfilt_12'
            EEG2                          = pop_select( EEG,'channel',params.channels_list);
            EEG2                          = pop_eegfilt( EEG2,params.ff1, params.ff2, [], 0, 0, 0, 'fir1', 0);
            EEG.data(params.channels_list,:) = EEG2.data;
            
    %##################################################################################
        % pop_eegfiltnew() - Filter data using Hamming windowed sinc FIR filter
        %
        %   Usage:
        %     >> [EEG, com, b] = pop_eegfiltnew(EEG); % pop-up window mode
        %     >> [EEG, com, b] = pop_eegfiltnew(EEG, locutoff, hicutoff, filtorder,
        %                                       revfilt, usefft, plotfreqz);
        %
        %   Inputs:
        %     EEG       - EEGLAB EEG structure
        %     locutoff  - lower edge of the frequency pass band (Hz)
        %                 {[]/0 -> lowpass}
        %     hicutoff  - higher edge of the frequency pass band (Hz)
        %                 {[]/0 -> highpass}
        %
        %   Optional inputs:
        %     filtorder - filter order (filter length - 1). Mandatory even
        %     revfilt   - [0|1] invert filter (from bandpass to notch filter)
        %                 {default 0 (bandpass)}
        %     usefft    - ignored (backward compatibility only)
        %     plotfreqz - [0|1] plot filter's frequency and phase response
        %                 {default 0}
        %
        %   Outputs:
        %     EEG       - filtered EEGLAB EEG structure
        %     com       - history string
        %     b         - filter coefficients
        %
        %   Note:
        %     pop_eegfiltnew is intended as a replacement for the deprecated
        %     pop_eegfilt function. Required filter order/transition band width is
        %     estimated with the following heuristic in default mode: transition band
        %     width is 25% of the lower passband edge, but not lower than 2 Hz, where
        %     possible (for bandpass, highpass, and bandstop) and distance from
        %     passband edge to critical frequency (DC, Nyquist) otherwise. Window
        %     type is hardcoded to Hamming. Migration to windowed sinc FIR filters
        %     (pop_firws) is recommended. pop_firws allows user defined window type
        %     and estimation of filter order by user defined transition band width.
         
        case 'pop_eegfiltnew_12'
            EEG2                          = pop_select(EEG,'channel',params.channels_list);
            EEG2                          = pop_eegfiltnew( EEG2,params.ff1, params.ff2, [], 0, [], 0);
            EEG.data(params.channels_list,:) = EEG2.data;
            
            
       case 'pop_eegfiltnew_14'
           EEG2                          = pop_select(EEG,'channel',params.channels_list);
           EEG2                          = pop_eegfiltnew( EEG2,'locutoff',params.ff1,'hicutoff' ,params.ff2);
           EEG.data(params.channels_list,:) = EEG2.data;
           
       case 'pop_eegfilt'
           EEG2                          = pop_select(EEG,'channel',params.channels_list);
%            EEG2                          = pop_eegfilt( EEG2,params.ff1, params.ff2);
           EEG2                          = pop_eegfilt( EEG2,params.ff1, 0);
           EEG2                          = pop_eegfilt( EEG2,0, params.ff2);
           EEG.data(params.channels_list,:) = EEG2.data;
           
    %##################################################################################        
        % pop_eegfiltnew() - Filter data using Hamming windowed sinc FIR filter
        %
        % Usage:
        %   >> [EEG, com, b] = pop_eegfiltnew(EEG); % pop-up window mode
        %   >> [EEG, com, b] = pop_eegfiltnew(EEG, locutoff, hicutoff, filtorder,
        %                                     revfilt, usefft, plotfreqz, minphase);
        %
        % Inputs:
        %   EEG       - EEGLAB EEG structure
        %   locutoff  - lower edge of the frequency pass band (Hz)
        %               {[]/0 -> lowpass}
        %   hicutoff  - higher edge of the frequency pass band (Hz)
        %               {[]/0 -> highpass}
        %
        % Optional inputs:
        %   filtorder - filter order (filter length - 1). Mandatory even
        %   revfilt   - [0|1] invert filter (from bandpass to notch filter)
        %               {default 0 (bandpass)}
        %   usefft    - ignored (backward compatibility only)
        %   plotfreqz - [0|1] plot filter's frequency and phase response
        %               {default 0}
        %   minphase  - scalar boolean minimum-phase converted causal filter
        %               {default false}
        %
        % Outputs:
        %   EEG       - filtered EEGLAB EEG structure
        %   com       - history string
        %   b         - filter coefficients
        %
        % Note:
        %   pop_eegfiltnew is intended as a replacement for the deprecated
        %   pop_eegfilt function. Required filter order/transition band width is
        %   estimated with the following heuristic in default mode: transition band
        %   width is 25% of the lower passband edge, but not lower than 2 Hz, where
        %   possible (for bandpass, highpass, and bandstop) and distance from
        %   passband edge to critical frequency (DC, Nyquist) otherwise. Window
        %   type is hardcoded to Hamming. Migration to windowed sinc FIR filters
        %   (pop_firws) is recommended. pop_firws allows user defined window type
        %   and estimation of filter order by user defined transition band width.
        
        % causal: minimum-phase converted causal filter
        case 'causal_pop_eegfiltnew_13'
            EEG2                          = pop_select(EEG,'channel',params.channels_list);
            EEG2                          = pop_eegfiltnew( EEG2,params.ff1, params.ff2,[] ,0,false,0,true);
            EEG.data(params.channels_list,:) = EEG2.data;
        %  non casual zero phase
        case 'noncausal_pop_eegfiltnew_13'
            EEG2                          = pop_select(EEG,'channel',params.channels_list);
            EEG2                          = pop_eegfiltnew(EEG2,params.ff1, params.ff2,[] ,0,false,0,false);
            EEG.data(params.channels_list,:) = EEG2.data;
        
    %##################################################################################
        %    >> EEG = pop_basicfilter( EEG, chanArray, locutoff, hicutoff, filterorder, typef, remove_dc, boundary)
        %
        % Inputs:
        %
        % EEG         - input dataset
        % chanArray   - channel(s) index(es) where the filter will be applied.
        % locutoff    - lower edge of the frequency pass band (Hz)  {0 -> lowpass}
        % hicutoff    - higher edge of the frequency pass band (Hz) {0 -> highpass}
        % filterorder - length of the filter in points {default 3*fix(srate/locutoff)}
        % typef       - type of filter. 'butter'=IIR Butterworth,  'fir'=windowed linear-phase FIR, 'notch'=PM Notch
        % remove_dc   - 1=remove data's mean value. 0=keep as it is.
        % boundary    - string 'boundary' or a numeric event code(s)
        %
        % Outputs:
        %
        % EEGOUT      - (filtered) output dataset
        %
        case 'pop_basicfilter'
%            EEG = pop_basicfilter( EEG, params.channels_list,params.ff1, params.ff2, 2, 'butter', 0, [] );
            EEG = pop_basicfilter( EEG, params.channels_list, ...
                'Boundary', 'boundary',...
                'Cutoff', [params.ff1,params.ff2],....
                'Design', 'butter',...
                'Filter', 'bandpass'...
                ...'Order', 2 ...
                );
 

           EEG = eeg_checkset( EEG );
        otherwise % if is empty, use the default
            disp('Please select a valid filter!')
            return
        
    end




end