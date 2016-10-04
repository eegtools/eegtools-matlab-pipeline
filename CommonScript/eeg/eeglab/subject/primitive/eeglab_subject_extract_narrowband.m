%% function results = eeglab_subject_extract_narrowband(input)
%
% returns:
% results.fnb             
% results.centroid_mean
% results.fcog_all
% results.fcog_pos
% results.fcog_neg
% results.polarity_index
%
function results = eeglab_subject_extract_narrowband(input)
    % struct('name','teta','min',4,'max',8,'dfmin',1,'dfmax',1,'ref_roi_list',{'Cpz'}, 'ref_roi_name','Cpz','ref_cond', 'ao', 'ref_tw_list', [0 100], 'ref_tw_name', 'gigi', 'realign_method','auc');
    project                                                                    = input.project;
    input_file_name                                                            = input.input_file_name;
    ref_roi_list                                                               = input.ref_roi_list;
    ref_tw_list                                                                = input.ref_tw_list;
    cycles                                                                     = input.cycles;
    freqs                                                                      = input.freqs;
    timesout                                                                   = input.timesout;
    padratio                                                                   = input.padratio;
    baseline                                                                   = input.baseline;
    epoch                                                                      = input.epoch;
    ersp_measure                                                               = input.ersp_measure;
    which_realign_measure                                                      = input.which_realign_measure;
    group_dfmin                                                                = input.dfmin;
    group_dfmax                                                                = input.dfmax;

    %% iniziallizzo variabili
    % inizializzo il cell array
    % tot_bands = length(frequency_bands_list);
    % fnb       = nan;

    %% calcolo ersp: bisogna calcolarla per ogni canale della roi e poi mediare per ottenere l'ersp media della roi
    % carico il dataset di EEGLab
    EEG                 = pop_loadset(input_file_name);

    % estraggo la label dei canali nel dataset
    all_ch_lab          = {EEG.chanlocs.labels};

    if(not(iscell(ref_roi_list)))
        ref_roi_list    = {ref_roi_list};
    end

    % considero i canali della roi selezionata
    roi_chans           = ref_roi_list;

    % vettore con gli indici dei canali della roi tra quelli del dataset
    num_chan_vec        = find(ismember(all_ch_lab, roi_chans));

    % totale dei canali nelle roi di riferimento
    tch_roi             = length(roi_chans);

    % cell array con tante celle quanti sono i canali nella roi di riferimento
    ersp_cell_roi       = cell(tch_roi);


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
            ...             , 'powbase'   , powbase                        ... vector giving the power of the baseline (will be used as a comparison to compute ersp)
            , 'plotersp'  , 'off'                          ...
            , 'plotitc'   , 'off'                          ...
            , 'plotersp'  , 'off'                          ...
            );

        % meaure ersp or db or % variations compared with the baseline
        if strcmp(ersp_measure, 'Pfu')
            ersp=(10.^(ersp{nf1,nf2}/10)-1)*100;

        end

        % buld the cell array with ersp of all channels in the selected roi
        ersp_cell_roi{nch} = ersp;
    end

    % re-formatting the cell array in a matrix to average alla channels in
    % the roi
    dim             = ndims(ersp_cell_roi{1});              % Get the number of dimensions for your arrays
    M               = cat(dim+1,ersp_cell_roi{:});            % Convert to a (dim+1)-dimensional matrix
    mean_ersp_roi   = mean(M,dim+1);  % Get the mean across arrays



    % select the time window
    tw              = ref_tw_list;
    % tw lowest time
    group_tmin      = min(tw);
    % tw highest time
    group_tmax      = max(tw);

    if isempty(group_tmin)
        group_tmin = min(times);
    end

    if isempty(group_tmax)
        group_tmax = max(times);
    end

    group_fmin = input.min;
    group_fmax = input.max;

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
    narrowband_input.which_realign_measure  = which_realign_measure; % questa gli abdrà passata da project in qualche modo

    [project, narrowband_output]            = eeglab_get_narrowband(project,narrowband_input);

    results.fnb                             = narrowband_output.results.sub.realign_freq;
    results.centroid_mean                   = narrowband_output.results.sub.fb.centroid_mean; 
    results.fcog.all                        = narrowband_output.results.sub.fb.fcog.all; 
    results.fcog.pos                        = narrowband_output.results.sub.fb.fcog.pos; 
    results.fcog.neg                        = narrowband_output.results.sub.fb.fcog.neg; 
    results.fcog.polarity_index             = narrowband_output.results.sub.fb.fcog.polarity_index; 

    % nota: extract narrowband restituirebbe molte più info, vedere
    % come capializzarle (possibile salvare / scrivere struttura su txt?)
end

%====================================================================================================================================
% CHANGE LOG
% 23/6/15
% added fcog_pos, fcog_neg, fcog_polarity_index
% all calculated params are returned in a single struct
% 19/6/15
% added export of fcog


