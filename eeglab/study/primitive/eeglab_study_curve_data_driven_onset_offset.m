function output = eeglab_study_curve_data_driven_onset_offset(input,  varargin)

%        % chiamo funzione per statistiche sull'onset ed offset delle attivazioni nelle finestre selezionate
% non può essere solo dentro nf1 nf2 perchè da un lato voglio i parametri x
% ogni soggetto nella cella, quindi ok, però voglio anche i parametri per
% l'intero campione per poter fare poi i plot di confroto fra le
% insorgenze. attenzione potresti voler rappresntare within f1, within f2
% perchè potrebero essere entrambi interessanti ma allora si ripropongono i
% problemi dei graf_ scorporare in funzione di grafica. domanda, allora non
% conviene esternalizzare e fare leggere e processare direttamente output ?
%        params.
%
%        output.onset_offset = eeglab_study_curve_tw_onset_offset(params,  varargin);
%

%% parsing dell'input
curve                                                                      = input.curve;
% levels_f1                                                                  = input.levels_f1;
% levels_f2                                                                  = input.levels_f2;
levels_grouping_factor                                                     = input.levels_grouping_factor;
% group_time_windows_list_design                                             = input.group_time_windows_list_design;
times                                                                      = input.times;
% deflection_polarity_list                                                   = input.deflection_polarity_list;
min_duration                                                               = input.min_duration;                      % ha senso settare una diversa lunghezza minima a seconda della banda o del tipo del sgnale?
base_tw                                                                    = input.base_tw;                           % baseline in ms
pvalue                                                                     = input.pvalue;                            % default will be 0.05
correction                                                                 = input.correction;                        % string. correction for multiple comparisons 'none'| 'fdr' | 'holms' | 'bonferoni'


%% parametri per i contatori
% totale livelli del grouping factor
tf_gf         = length(levels_grouping_factor);

%% inizializzo l'output
% output.input                                                               = input;
output=[];


sigcell_pruned_gf = {};

%% calcolo onset-offset per ogni livello del grouping factor e canale
for nf_gf =1:tf_gf
    
    
    [ tot_ch, tot_times] = size(curve{nf_gf});
    
    mat_pch_raw = [];
    
    for nch = 1:tot_ch
        input_fcoo.curve                                           = curve{nf_gf}(nch,:);
        %             input_fcoo.deflection_tw_list                              = group_time_windows_list_design;
        input_fcoo.base_tw                                         = base_tw;
        input_fcoo.times                                           = times;
        %             input_fcoo.deflection_polarity_list                        = deflection_polarity_list; % 'unknown', 'positive','negative'
        input_fcoo.sig_th                                          = pvalue;
        %             input_fcoo.min_duration                                    = min_duration; % minima durata di un segmento significativamente diverso dalla baseline, per evitare rumore
        input_fcoo.correction                                      = correction;
        
        % calcolo misure legate ad onset/offset
        fcoo = compare_curve_baseline_data_driven(input_fcoo);
%         output.ch{nf_gf,nch} = fcoo;
        
        mat_pch_raw(nch,:) = fcoo.pvec_raw;
        
        
    end
    
    mat_pch_corrected    = mcorrect(mat_pch_raw,correction);
    
    sigmat_raw     = mat_pch_corrected < pvalue;
    
    
    
    sigmat_pruned = sigmat_raw + 0;
    dt = abs(times(2) - times(1));

    
    % ora andiamo a selezionare solo le deflessioni sufficientemente lunghe
    if not(isempty(min_duration) | isnan(min_duration))
        for nch = 1:tot_ch
            input_ls.curve        = sigmat_raw(nch,:);
            input_ls.min_duration = round(min_duration/dt); % converto in samples da tempo
            sigmat_pruned(nch,:)  = find_long_steps(input_ls);
        end
        
    end
    
    sigcell_pruned_gf{nf_gf} = sigmat_pruned;
    
    
    
    %
    %     % ora andiamo ad estrarre i parametri per ogni tw
    %
    %     for ntw = 1:length(deflection_tw_list)
    %         selt = times >= deflection_tw_list{ntw}(1) & times <= deflection_tw_list{ntw}(2);
    %         if sum(size(selt) == size(sigvec)) ==2
    %             seltsig = selt & sigvec>0;
    %         else
    %             seltsig = selt & sigvec'>0;
    %         end
    %         tonset                                                                     = min(times(seltsig));
    %         toffset                                                                    = max(times(seltsig));
    %
    %
    %         output.tw(ntw).tonset                                                       = nan;                                            % tempo di onset
    %         output.tw(ntw).vonset                                                       = nan;                                            % valore di onset
    %         output.tw(ntw).toffset                                                      = nan;                                           % tempo di offset
    %         output.tw(ntw).voffset                                                      = nan;                                           % valore di offset
    %         output.tw(ntw).tmax_deflection                                              = nan;                                   % tempo di valore massimo della deflessione
    %         output.tw(ntw).max_deflection                                               = nan;                                    % valore massimo della deflessione
    %         output.tw(ntw).tmin_deflection                                              = nan;                                   % tempo di valore minimo della deflessione
    %         output.tw(ntw).min_deflection                                               = nan;                                    % valore valore minimo della deflessione
    %         output.tw(ntw).dt_onset_max_deflection                                      = nan;                           % tempo tra onset e massimo di deflessione
    %         output.tw(ntw).dt_max_deflection_offset                                     = nan;                          % tempo tra massimo di deflessione e offset
    %         output.tw(ntw).area_onset_max_deflection                                    = nan;                         % area tra onset e massimo di deflessione
    %         output.tw(ntw).area_max_deflection_offset                                   = nan;                        % area tra massimo di deflessione e offset
    %         output.tw(ntw).dt_onset_min_deflection                                      = nan;                           % tempo tra onset e mainimo di deflessione
    %         output.tw(ntw).dt_min_deflection_offset                                     = nan;                          % tempo tra minimo di deflessione e offset
    %         output.tw(ntw).area_onset_min_deflection                                    = nan;                         % area tra onset e minimo di deflessione
    %         output.tw(ntw).area_min_deflection_offset                                   = nan;                        % area tra minimo di deflessione e offset
    %         output.tw(ntw).dt_onset_offset                                              = nan;                                   % tempo tra onset e offset
    %         output.tw(ntw).area_onset_offset                                            = nan;                                 % area tra onset e offset
    %         output.tw(ntw).vmean_onset_offset                                           = nan;                                % media curva tra onset e offset
    %         output.tw(ntw).vmedian_onset_offset                                         = nan;                              % mediana curva tra onset e offset
    %         output.tw(ntw).barycenter                                                   = nan;                                        % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
    %
    %
    %
    %
    %
    %         if not(isempty(tonset)) && not(isempty(tonset))
    %             vonset                                                                     = curve(times == tonset);
    %             voffset                                                                    = curve(times == toffset);
    %             max_deflection                                                             = max(curve(seltsig));
    %             tmax_deflection                                                            = times(curve == max_deflection);
    %             min_deflection                                                             = min(curve(seltsig));
    %             tmin_deflection                                                            = times(curve == min_deflection);
    %             dt_onset_max_deflection                                                    = tmax_deflection - tonset;
    %             dt_max_deflection_offset                                                   = toffset - tmax_deflection;
    %
    %
    %             selt2 = times >= tonset & times <= max_deflection;
    %             area_onset_max_deflection                                                  = sum(curve(selt2));
    %
    %             selt2 = times >= max_deflection & times <= toffset;
    %             area_max_deflection_offset                                                 = sum(curve(selt2));
    %
    %             dt_onset_min_deflection                                                    = tmin_deflection - tonset;
    %             dt_min_deflection_offset                                                   = toffset - tmin_deflection;
    %
    %             selt2 = times >= tonset & times <= min_deflection;
    %             area_onset_min_deflection                                                  = sum(curve(selt2));
    %
    %             selt2 = times >= min_deflection & times <= toffset;
    %             area_min_deflection_offset                                                 = sum(curve(selt2));
    %
    %             dt_onset_offset                                                            = toffset - tonset;
    %
    %             selt2 = times >= tonset & times <= toffset;
    %             area_onset_offset                                                          = sum(curve(selt2));
    %             vmean_onset_offset                                                         = mean(curve(selt2));
    %             vmedian_onset_offset                                                       = median(curve(selt2));
    %
    %             barycenter                                                                 = sum( times(selt2).*curve(selt2)') / sum(curve(selt2));
    %
    %             %% output
    %
    %             output.tw(ntw).tonset                                                       = tonset;                                            % tempo di onset
    %             output.tw(ntw).vonset                                                       = vonset;                                            % valore di onset
    %             output.tw(ntw).toffset                                                      = toffset;                                           % tempo di offset
    %             output.tw(ntw).voffset                                                      = voffset;                                           % valore di offset
    %             output.tw(ntw).tmax_deflection                                              = tmax_deflection;                                   % tempo di valore massimo della deflessione
    %             output.tw(ntw).max_deflection                                               = max_deflection;                                    % valore massimo della deflessione
    %             output.tw(ntw).tmin_deflection                                              = tmin_deflection;                                   % tempo di valore minimo della deflessione
    %             output.tw(ntw).min_deflection                                               = min_deflection;                                    % valore valore minimo della deflessione
    %             output.tw(ntw).dt_onset_max_deflection                                      = dt_onset_max_deflection;                           % tempo tra onset e massimo di deflessione
    %             output.tw(ntw).dt_max_deflection_offset                                     = dt_max_deflection_offset;                          % tempo tra massimo di deflessione e offset
    %             output.tw(ntw).area_onset_max_deflection                                    = area_onset_max_deflection;                         % area tra onset e massimo di deflessione
    %             output.tw(ntw).area_max_deflection_offset                                   = area_max_deflection_offset;                        % area tra massimo di deflessione e offset
    %             output.tw(ntw).dt_onset_min_deflection                                      = dt_onset_min_deflection;                           % tempo tra onset e mainimo di deflessione
    %             output.tw(ntw).dt_min_deflection_offset                                     = dt_min_deflection_offset;                          % tempo tra minimo di deflessione e offset
    %             output.tw(ntw).area_onset_min_deflection                                    = area_onset_min_deflection;                         % area tra onset e minimo di deflessione
    %             output.tw(ntw).area_min_deflection_offset                                   = area_min_deflection_offset;                        % area tra minimo di deflessione e offset
    %             output.tw(ntw).dt_onset_offset                                              = dt_onset_offset;                                   % tempo tra onset e offset
    %             output.tw(ntw).area_onset_offset                                            = area_onset_offset;                                 % area tra onset e offset
    %             output.tw(ntw).vmean_onset_offset                                           = vmean_onset_offset;                                % media curva tra onset e offset
    %             output.tw(ntw).vmedian_onset_offset                                         = vmedian_onset_offset;                              % mediana curva tra onset e offset
    %             output.tw(ntw).barycenter                                                   = barycenter;                                        % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
    %
    %
    %         end
end
output.sigcell_pruned_gf =  sigcell_pruned_gf;
end















