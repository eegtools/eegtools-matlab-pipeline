%% function [sub.adjusted_fmin, sub_adjusted_fmax, sub_realign_freq, sub_realign_freq_value, sub_realign_freq_value_lat, ...
%     group.fb.centroid_mean, centroid_mean_sub_realign_fb] = ...
%     eeglab_get_narrowband(input_struct.ersp_matrix_sub, input_struct.times, input_struct.freqs, input_struct.group_tmin, input_struct.group_tmax, input_struct.group_fmin,
% input_struct.group_fmax, input_struct.group_dfmin, input_struct.group_dfmax, input_struct.which_realign_measure)
%
% calculate adjusted frequency band limits for each subject.
% starts from group frequency band limits. for each frequency in the group
% frequency band, find hightest reaign measure(maximum, minumum or area under the curve, respectively 'max', 'mean', 'auc') in the group
% defined time window. Select the frequency with the more pronounced
% realign measure.
% exports:
% 1) the frequency corresponding to the strongest realign measure;
% 2) the realign measure value of that frequencuency and its latency
% 3) the subject-adjusted limits of the frequency band
% 4) centroid frequency for the group and the realigned frequency band


function [project, narrowband_output]=eeglab_get_narrowband(project,narrowband_input)

narrowband_output = [];

if nargin <2
    help eeglab_get_narrowband
    return;
end

%     %% input structure
%     narrowband_input.times                 =
%     narrowband_input.freqs                 =
%     narrowband_input.ersp_matrix_sub       =
%     narrowband_input.group_tmin            =
%     narrowband_input.group_tmax            =
%     narrowband_input.group_fmin            =
%     narrowband_input.group_fmax            =
%     narrowband_input.group_dfmin           =
%     narrowband_input.group_dfmax           =
%
%     narrowband_input.which_realign_measure =

%% output structure

% relate to group
results.group.ersp.vec_allfreqs     = [];
results.group.ersp.vec_band         = [];
results.group.fb.centroid_mean      = [];
results.group.ersp.mean             = [];
results.group.ersp.median           = [];
results.group.ersp.var              = [];
results.group.ersp.auc_abs          = [];
results.group.ersp.auc_rel          = [];
results.group.fb.centroid_median    = [];
results.group.ersp.low05quantile    = [];
results.group.ersp.high05quantile   = [];

% related to subject based adjustment
results.sub.realign_freq            = [];
results.sub.realign_freq_value_lat  = [];
results.sub.fmin                    = [];
results.sub.fmax                    = [];
results.sub.fb.centroid_mean        = [];



sel_times_group = narrowband_input.times >= narrowband_input.group_tmin & narrowband_input.times <= narrowband_input.group_tmax;
sel_freqs_group = narrowband_input.freqs >= narrowband_input.group_fmin & narrowband_input.freqs <= narrowband_input.group_fmax;

ersp_matrix_sub_tw_fb = narrowband_input.ersp_matrix_sub(:,sel_times_group);

% calcolo il centroide basato sulla media
results.group.ersp.vec_allfreqs = mean(ersp_matrix_sub_tw_fb,2);
freqs_vec_group_band                  = narrowband_input.freqs(sel_freqs_group);
ersp_distr_group_band                 = freqs_vec_group_band.*results.group.ersp.vec_allfreqs(sel_freqs_group)';
results.group.fb.centroid_mean  = sum(ersp_distr_group_band)/sum(results.group.ersp.vec_allfreqs(sel_freqs_group)');

% calcolo la media dello spettro nella banda
results.group.ersp.mean         = mean(results.group.ersp.vec_allfreqs(sel_freqs_group));

% calcolo la mediana dello spettro nella banda
results.group.ersp.median                 = median(results.group.ersp.vec_allfreqs(sel_freqs_group));

% calcolo la varianza dello spettro nella banda
results.group.ersp.var                    = var(results.group.ersp.vec_allfreqs(sel_freqs_group));

% calcolo la auc di banda
results.auc_abs_group_fb                  = sum(abs(results.group.ersp.vec_allfreqs(sel_freqs_group)));

% calcolo la auc relativa totale di banda
results.group.ersp.auc_rel                = results.auc_abs_group_fb/sum(abs( results.group.ersp.vec_allfreqs));

% calcolo descrittori non parametrici dello  spettro di potenza nella
% banda di gruppo

% calcolo il centroide basato sulla mediana

vec_ersp.median_distr_group_band                = find(results.group.ersp.vec_allfreqs(sel_freqs_group) >= results.group.ersp.median);
ind_ersp.median_distr_group_band                = vec_ersp.median_distr_group_band(1);
results.group.fb.centroid_median                = freqs_vec_group_band(ind_ersp.median_distr_group_band);

% calcolo il quantile corrispondente a 0.05
low05quantile_ersp_distr_group_band             = quantile(results.group.ersp.vec_allfreqs(sel_freqs_group),0.05);
vec_low05quantile_ersp_distr_group_band         = find(results.group.ersp.vec_allfreqs(sel_freqs_group)>= low05quantile_ersp_distr_group_band);
ind_low05quantile_ersp_distr_group_band         =  vec_low05quantile_ersp_distr_group_band(1);
results.centroid_low05quantile_group_fb         =  freqs_vec_group_band(ind_low05quantile_ersp_distr_group_band);

% calcolo il quantile corrispondente a 0.95
high05quantile_ersp_distr_group_band            = quantile(results.group.ersp.vec_allfreqs(sel_freqs_group),0.95);
vec_high05quantile_ersp_distr_group_band        = find(results.group.ersp.vec_allfreqs (sel_freqs_group) >= high05quantile_ersp_distr_group_band);
ind_high05quantile_ersp_distr_group_band        = vec_high05quantile_ersp_distr_group_band(1);
results.group.ersp.high05quantile               = freqs_vec_group_band(ind_high05quantile_ersp_distr_group_band);

ff = find(sel_freqs_group);


if ismember(narrowband_input.which_realign_measure,{'min','max','auc'})
    
    if strcmp(narrowband_input.which_realign_measure,'min')
        
        % vettore con le misure di riallineamento in tutte le frequenze nella finetra temporale
        % selezionata
        realign_narrowband_input.freqs_vec           = min(ersp_matrix_sub_tw_fb(sel_freqs_group,:),[],2);
        
        % valore della misura di riallineamento più pronunciatatra tutte le frequenze
        sub_realign_freq_value                   = min(realign_narrowband_input.freqs_vec);
        
        % seleziono la frequenza con la misura di riallineamento più pronunciata
        sel_freq_strongest_realign               = find(realign_narrowband_input.freqs_vec == sub_realign_freq_value);
        
        % se avessi più frequenze che raggiungono l'etremo, considero
        % arbitrariamente la prima
        sel_freq_strongest_realign               = sel_freq_strongest_realign(1);
        
        % seleziono la frequenza con la misura di riallineamento più pronunciata
        results.sub.realign_freq           = narrowband_input.freqs(ff(sel_freq_strongest_realign));
        
        % seleziono la curva che corrisponde alla ERSP in funzione del tempo nella frequenza che presenta la misura di riallineamento più pronunciata
        realign_freq_curve                       = ersp_matrix_sub_tw_fb(ff(sel_freq_strongest_realign),:);
        
        % calcolo la latenza corrispondente al raggiungimento della misura di riallineamento
        % nella frequenza con l'etremo più pronunciata
        sub_realign_freq_value_lat               = narrowband_input.times(realign_freq_curve == sub_realign_freq_value);
        
        % anche qui, considero arbitrariamente solo la PRIMA occorrenza
        % dell'etremo
        results.sub.realign_freq_value_lat = sub_realign_freq_value_lat(1);
        
        % calcolo il limite inferiore della banda subject-adjusted
        results.sub.fmin                   = results.sub.realign_freq-narrowband_input.group_dfmin;
        
        % calcolo il limite superiore della banda subject-adjusted
        results.sub.fmax                  = results.sub.realign_freq + narrowband_input.group_dfmax;
        
        if results.sub.fmin   < narrowband_input.group_fmin
            results.sub.fmin = narrowband_input.group_fmin;
        end
        
        if  results.sub.fmax   > narrowband_input.group_fmax
            results.sub.fmax = narrowband_input.group_fmax;
        end
        
        sel_freqs_sub=narrowband_input.freqs >= results.sub.fmin & narrowband_input.freqs <=  results.sub.fmax;
        results.sub.fb.centroid_mean=sum(narrowband_input.freqs(sel_freqs_sub).*mean(ersp_matrix_sub_tw_fb(sel_freqs_sub,:),2)')/sum(mean(ersp_matrix_sub_tw_fb(sel_freqs_sub,:),2)');
        
        
        
    elseif strcmp(narrowband_input.which_realign_measure,'max')
        
        % vettore con le misure di riallineamento in tutte le frequenze nella finetra temporale
        % selezionata
        realign_narrowband_input.freqs_vec             = max(ersp_matrix_sub_tw_fb(sel_freqs_group,:),[],2);
        
        % valore della misura di riallineamento più pronunciatatra tutte le frequenze
        sub_realign_freq_value                     = max(realign_narrowband_input.freqs_vec);
        
        % seleziono la frequenza con la misura di riallineamento più pronunciata
        sel_freq_strongest_realign                 = find(realign_narrowband_input.freqs_vec==sub_realign_freq_value);
        
        % se avessi più frequenze che raggiungono l'etremo, considero
        % arbitrariamente la prima
        sel_freq_strongest_realign                 = sel_freq_strongest_realign(1);
        
        % seleziono la frequenza con la misura di riallineamento più pronunciata
        results.sub.realign_freq             = narrowband_input.freqs(ff(sel_freq_strongest_realign));
        
        % seleziono la curva che corrisponde alla ERSP in funzione del tempo nella frequenza che presenta la misura di riallineamento più pronunciata
        realign_freq_curve                         = ersp_matrix_sub_tw_fb(ff(sel_freq_strongest_realign),:);
        
        % calcolo la latenza corrispondente al raggiungimento della misura di riallineamento
        % nella frequenza con l'etremo più pronunciata
        sub_realign_freq_value_lat                 = narrowband_input.times(realign_freq_curve==sub_realign_freq_value);
        
        % anche qui, considero arbitrariamente solo la PRIMA occorrenza
        % dell'etremo
        results.sub.realign_freq_value_lat   = sub_realign_freq_value_lat(1);
        
        % calcolo il limite inferiore della banda subject-adjusted
        results.sub.fmin                     = results.sub.realign_freq-narrowband_input.group_dfmin;
        
        % calcolo il limite superiore della banda subject-adjusted
        results.sub.fmax                    = results.sub.realign_freq + narrowband_input.group_dfmax;
        
        if results.sub.fmin < narrowband_input.group_fmin
            results.sub.fmin = narrowband_input.group_fmin;
        end
        
        if  results.sub.fmax > narrowband_input.group_fmax
            results.sub.fmax = narrowband_input.group_fmax;
        end
        
        sel_freqs_sub=narrowband_input.freqs >= results.sub.fmin & narrowband_input.freqs <=  results.sub.fmax;
        results.sub.fb.centroid_mean=sum(narrowband_input.freqs(sel_freqs_sub).*mean(ersp_matrix_sub_tw_fb(sel_freqs_sub,:),2)')/sum(mean(ersp_matrix_sub_tw_fb(sel_freqs_sub,:),2)');
        
        
    elseif strcmp(narrowband_input.which_realign_measure,'auc')
        
        % vettore con le misure di riallineamento in  tutte le frequenze nella finetra temporale
        % selezionata
        realign_narrowband_input.freqs_vec              = sum(abs(ersp_matrix_sub_tw_fb(sel_freqs_group,:)),2);
        
        % valore della misura di riallineamento più pronunciatatra tutte le frequenze
        sub_realign_freq_value                      = max(realign_narrowband_input.freqs_vec);
        
        % seleziono la frequenza con la misura di riallineamento più pronunciata
        sel_freq_strongest_realign                  = find(realign_narrowband_input.freqs_vec==sub_realign_freq_value);
        
        % se avessi più frequenze che raggiungono l'etremo, considero
        % arbitrariamente la prima
        sel_freq_strongest_realign                  = sel_freq_strongest_realign(1);
        
        % seleziono la frequenza con la misura di riallineamento più pronunciata
        results.sub.realign_freq              = narrowband_input.freqs(ff(sel_freq_strongest_realign));
        
        % seleziono la curva che corrisponde alla ERSP in funzione del tempo nella frequenza che presenta la misura di riallineamento più pronunciata
        realign_freq_curve                          = ersp_matrix_sub_tw_fb(ff(sel_freq_strongest_realign),:);
        
%         % calcolo la latenza corrispondente al raggiungimento della misura di riallineamento
%         % nella frequenza con l'etremo più pronunciata
%         sub_realign_freq_value_lat                  = narrowband_input.times(realign_freq_curve==sub_realign_freq_value);
%         
%         % anche qui, considero arbitrariamente solo la PRIMA occorrenza
%         % dell'etremo
%         results.sub.realign_freq_value_lat    = sub_realign_freq_value_lat(1);
%         
        % calcolo il limite inferiore della banda subject-adjusted
        results.sub.fmin                      = results.sub.realign_freq-narrowband_input.group_dfmin;
        
        % calcolo il limite superiore della banda subject-adjusted
        results.sub.fmax                     = results.sub.realign_freq + narrowband_input.group_dfmax;
        
        if results.sub.fmin < narrowband_input.group_fmin
            results.sub.fmin = narrowband_input.group_fmin;
        end
        
        if  results.sub.fmax > narrowband_input.group_fmax
            results.sub.fmax = narrowband_input.group_fmax;
        end
        
        sel_freqs_sub=narrowband_input.freqs >= results.sub.fmin & narrowband_input.freqs <=  results.sub.fmax;
        results.sub.fb.centroid_mean=sum(narrowband_input.freqs(sel_freqs_sub).*mean(ersp_matrix_sub_tw_fb(sel_freqs_sub,:),2)')/sum(mean(ersp_matrix_sub_tw_fb(sel_freqs_sub,:),2)');
        
    end
    
    narrowband_output.narrowband_input=narrowband_input;
    narrowband_output.results=results;
    
else
    display('ERROR: select min or max!!!!')
    return;
end
end