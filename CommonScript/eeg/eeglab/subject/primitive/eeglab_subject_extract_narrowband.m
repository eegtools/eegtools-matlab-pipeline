function narrowband_cell = eeglab_subject_extract_narrowband(input)

input_file_name                                                            = input.input_file_name;
roi_list                                                                   = input.roi_list;
frequency_bands_list                                                       = input.frequency_bands_list;
group_time_windows_list                                                    = input.group_time_windows_list;

cycles                                                                     = input.cycles;
freqs                                                                      = input.freqs;
timesout                                                                   = input.timesout;
padratio                                                                   = input.padratio;
baseline                                                                   = input.baseline;
powbase                                                                    = input.powbase;
epoch                                                                      = input.epoch;
ersp_measure                                                               = input.ersp_measure;


which_realign_measure                                                      = input.which_realign_measure;

group_dfmin                                                                = input.group_dfmin;
group_dfmax                                                                = input.group_dfmax;


%% iniziallizzo variabili
% inizializzo il cell array
tot_bands = length(frequency_bands_list);

narrow_band_cell =cell(tot_bands);


% cell array con tante celle quanti sono i canali nella roi di riferimento
ersp_cell_roi = cell(tch_roi);

%% calcolo ersp: bisogna calcolarla per ogni canale della roi e poi mediare per ottenere l'ersp media della roi
% carico il dataset di EEGLab
EEG = pop_loadset(input_file_name);

% estraggo la label dei canali nel dataset
all_ch_lab = {EEG.chanlocs.labels};

% per ogni roi
for nroi = 1 : length(roi_list)
    
    % considero i canali della roi selezionata
    roi_chans = roi_list{nroi};
    
    % vettore con gli indici dei canali della roi tra quelli del dataset
    num_chan_vec=find(ismember(all_ch_lab, roi_chans));
    
    % totale dei canali nelle roi di riferimento
    tch_roi =length(roi_chans);
    
    
    % for each channel of the selected roi
    for nch = 1:tch_roi
        
        % select channel id
        topovec = num_chan_vec(nch);
        
        % select channel label
        ch_lab = EEG.chanlocs(topovec).labels;
        
        % calculate ersp for the selected channel
        
        [ersp,itc,powbase, times, freqs, erspboot, itcboot] = ...
            pop_newtimef(                                  ...
            EEG                                            ... the EEG data structure
            , 1                                            ... select channels isnead of components
            , topovec                                      ... channel index
            , epoch                                        ...
            , cycles                                       ... cycles of the wavelet, if 0 fourier
            , 'topovec'   , topovec                        ... channel index
            , 'elocs'     , EEG.chanlocs                   ... topog. loactions of the channels
            , 'chaninfo'  , EEG.chaninfo                   ... labels channels
            , 'caption'   , ch_lab                         ...
            , 'baseline'  , baseline                       ...
            , 'freqs'     , freqs                          ...
            , 'timesout'  , timesout                       ... vector of times at which the function will provide ersp values
            , 'padratio'  , padratio                       ... number of zeros which will be added at the borders of the signal, to cosmetically (fake!!!!) increase the spectral resolution/smoothness of the tf dscomposition
            , 'trialbase' , 'full'                         ...
            , 'powbase'   , powbase                        ... vector giving the power of the baseline (will be used as a comparison to compute ersp)                    
            , 'plotersp'  , 'off'                          ...
            , 'plotitc'   , 'off'                          ...
            , 'plotersp'  , 'off'                          ...
            );
        
        % meaure ersp or db or % variations compared with the baseline
        if strcmp(ersp_measure, 'Pfu')
            ersp{nf1,nf2}=(10.^(ersp{nf1,nf2}/10)-1)*100;
            
        end
        
        % buld the cell array with ersp of all channels in the selected roi
        ersp_cell_roi{nch} = ersp;
    end
    
    % re-formatting the cell array in a matrix to average alla channels in
    % the roi
    dim = ndims(ersp_cell_roi{1});              %# Get the number of dimensions for your arrays
    M = cat(dim+1,ersp_cell_roi{:});            %# Convert to a (dim+1)-dimensional matrix
    mean_ersp_roi = mean(ersp_cell_roi,dim+1);  %# Get the mean across arrays
    
    % for each time window
    for ntw =  1:length(group_time_windows_list)
        
        % select the time window
        tw = group_time_windows_list{ntw};
        
        % tw lowest time
        group_tmin = min(tw);
        
        % tw highest time
        group_tmax = max(tw);
        
        if isempty(group_tmin)
            group_tmin = min(times);
        end
       
        
        if isempty(group_tmax)
            group_tmax = max(times);
        end
        
        
        for nband=1:tot_bands
            
            fband = frequency_bands_list{nband};
            
            group_fmin = min(fband);
            group_fmax = max(fband);
            
            % narrowband input structure
            narrowband_input.times                  = times;
            narrowband_input.freqs                  = freqs;
            narrowband_input.ersp_matrix_sub        = mean_ersp_roi;
            narrowband_input.group_tmin             = group_tmin;
            narrowband_input.group_tmax             = group_tmax;
            narrowband_input.group_fmin             = group_fmin;
            narrowband_input.group_fmax             = group_fmax ;
            narrowband_input.group_dfmin            = group_dfmin;
            narrowband_input.group_dfmax            = group_dfmax;
            narrowband_input.which_realign_measure  = which_realign_measure{nband}; % questa gli abdrà passata da project in qualche modo
            
            [project, narrowband_cell{nband,nroi,ntw}]            = eeglab_get_narrowband(project,narrowband_input);
        end
    end
end




