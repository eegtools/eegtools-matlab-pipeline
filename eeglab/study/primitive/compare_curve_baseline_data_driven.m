function output = compare_curve_baseline_data_driven(input,  varargin)

curve                                                                      = input.curve;
% deflection_tw_list                                                         = input.deflection_tw_list;
base_tw                                                                    = input.base_tw;
times                                                                      = input.times;
% deflection_polarity_list                                                   = input.deflection_polarity_list; % 'unknown', 'positive','negative'
% sig_th                                                                     = input.sig_th;
% min_duration                                                               = input.min_duration; % minima durata di un segmento significativamente diverso dalla baseline, per evitare rumore
% correction                                                                 = input.correction;

output = [];



% if (isempty(sig_th) || isnan(sig_th))
%     sig_th = 0.05;
% end

% if (isempty(min_duration) || isnan(min_duration))
%     min_duration = 1;
% end





tt              = length(times);
pvec_raw        = nan(tt,1);
zval_raw        = nan(tt,1);
ci_raw        = nan(2,tt);



% sel_tw_list     = false(tt,1);

% mask to select the baseline
sel_base    = times >= base_tw(1) & times <= base_tw(2);
base_raw        = curve(sel_base);

% facciamo resampling per garantire numerosità sufficiente per fare z test
tot_resamples = 1000; 
s = RandStream('mlfg6331_64'); 
base = datasample(s,base_raw,tot_resamples, 'Replace',true);


% bisogna dividere il calcolo in 2 parti:
% 1)trovare deflessioni significative (e conseguenti time window)
% da baseline  applicando poi correzione.
% 2) estrarre parametri da ciascuna tw estratta dai dati

mean_base = mean(base);
std_base = std(base);

% for ntw = 1:length(deflection_tw_list)
%     
%     
%     switch deflection_polarity_list{ntw}
%         case 'unknown'
%             tail = 'both';
%         case 'positive'
%             tail = 'right';
%         case 'negative'
%             tail = 'left';
%     end
    
    
    
%     % mask to select the possible deflection to be compared with the baseline
%     selt = times >= deflection_tw_list{ntw}(1) & times <= deflection_tw_list{ntw}(2);
%     ind_deflection        = find(selt);
%     deflection            = curve(ind_deflection);
%     ttt=length(deflection);
%     sel_tw_list(ind_deflection) = true;



%     
    % for each time point within the time window of the possible deflection to be compared with the baseline
    for ntt=1:tt
%         ind2test             = ind_deflection(ntt);
        point2test           = curve(ntt);
%         [h,pval]             = ttest(base, point2test, sig_th, 'both');
        [h,pval, ci, zval] = ztest(point2test,mean_base,std_base);
        pvec_raw(ntt)       = pval;
        zval_raw(ntt)       = zval;
        ci_raw(:,ntt)       = ci;
        
        
        
    end
    
% end


% pvec_corrected    = mcorrect(pvec_raw,correction);
% 
% sigvec     = pvec_corrected < sig_th;


% % ora andiamo a selezionare solo le deflessioni sufficientemente lunghe
% 
% if not(isempty(min_duration) | isnan(min_duration))
%     input_ls.curve        = sigvec;
%     input_ls.min_duration = round(min_duration/dt); % converto in samples da tempo    
%     sigvec                = find_long_steps(input_ls);
% end


% salviamo i risultati sulla curva continua: la curva, la p grezza, la p
% corretta, le deflessioni significative in base alla soglia selezionata

output.curve          = curve;
% output.continuous.pvec_corrected = pvec_corrected;
output.pvec_raw       = pvec_raw;
% output.continuous.sigvec         = sigvec;
output.times          = times;
output.ci_raw         = ci_raw;
output.zval_raw       = zval_raw;



% % ora andiamo ad estrarre i parametri per ogni tw
% 
% for ntw = 1:length(deflection_tw_list)
%     selt = times >= deflection_tw_list{ntw}(1) & times <= deflection_tw_list{ntw}(2);
%     if sum(size(selt) == size(sigvec)) ==2
%         seltsig = selt & sigvec>0;
%     else
%         seltsig = selt & sigvec'>0;
%     end
%     tonset                                                                     = min(times(seltsig));
%     toffset                                                                    = max(times(seltsig));
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
%     if not(isempty(tonset)) && not(isempty(tonset))
%         vonset                                                                     = curve(times == tonset);
%         voffset                                                                    = curve(times == toffset);
%         max_deflection                                                             = max(curve(seltsig));
%         tmax_deflection                                                            = times(curve == max_deflection);
%         min_deflection                                                             = min(curve(seltsig));
%         tmin_deflection                                                            = times(curve == min_deflection);
%         dt_onset_max_deflection                                                    = tmax_deflection - tonset;
%         dt_max_deflection_offset                                                   = toffset - tmax_deflection;
%         
%         
%         selt2 = times >= tonset & times <= max_deflection;
%         area_onset_max_deflection                                                  = sum(curve(selt2));
%         
%         selt2 = times >= max_deflection & times <= toffset;
%         area_max_deflection_offset                                                 = sum(curve(selt2));
%         
%         dt_onset_min_deflection                                                    = tmin_deflection - tonset;
%         dt_min_deflection_offset                                                   = toffset - tmin_deflection;
%         
%         selt2 = times >= tonset & times <= min_deflection;
%         area_onset_min_deflection                                                  = sum(curve(selt2));
%         
%         selt2 = times >= min_deflection & times <= toffset;
%         area_min_deflection_offset                                                 = sum(curve(selt2));
%         
%         dt_onset_offset                                                            = toffset - tonset;
%         
%         selt2 = times >= tonset & times <= toffset;
%         area_onset_offset                                                          = sum(curve(selt2));
%         vmean_onset_offset                                                         = mean(curve(selt2));
%         vmedian_onset_offset                                                       = median(curve(selt2));
%         
%         barycenter                                                                 = sum( times(selt2).*curve(selt2)') / sum(curve(selt2));
%         
%         %% output
%         
%         output.tw(ntw).tonset                                                       = tonset;                                            % tempo di onset
%         output.tw(ntw).vonset                                                       = vonset;                                            % valore di onset
%         output.tw(ntw).toffset                                                      = toffset;                                           % tempo di offset
%         output.tw(ntw).voffset                                                      = voffset;                                           % valore di offset
%         output.tw(ntw).tmax_deflection                                              = tmax_deflection;                                   % tempo di valore massimo della deflessione
%         output.tw(ntw).max_deflection                                               = max_deflection;                                    % valore massimo della deflessione
%         output.tw(ntw).tmin_deflection                                              = tmin_deflection;                                   % tempo di valore minimo della deflessione
%         output.tw(ntw).min_deflection                                               = min_deflection;                                    % valore valore minimo della deflessione
%         output.tw(ntw).dt_onset_max_deflection                                      = dt_onset_max_deflection;                           % tempo tra onset e massimo di deflessione
%         output.tw(ntw).dt_max_deflection_offset                                     = dt_max_deflection_offset;                          % tempo tra massimo di deflessione e offset
%         output.tw(ntw).area_onset_max_deflection                                    = area_onset_max_deflection;                         % area tra onset e massimo di deflessione
%         output.tw(ntw).area_max_deflection_offset                                   = area_max_deflection_offset;                        % area tra massimo di deflessione e offset
%         output.tw(ntw).dt_onset_min_deflection                                      = dt_onset_min_deflection;                           % tempo tra onset e mainimo di deflessione
%         output.tw(ntw).dt_min_deflection_offset                                     = dt_min_deflection_offset;                          % tempo tra minimo di deflessione e offset
%         output.tw(ntw).area_onset_min_deflection                                    = area_onset_min_deflection;                         % area tra onset e minimo di deflessione
%         output.tw(ntw).area_min_deflection_offset                                   = area_min_deflection_offset;                        % area tra minimo di deflessione e offset
%         output.tw(ntw).dt_onset_offset                                              = dt_onset_offset;                                   % tempo tra onset e offset
%         output.tw(ntw).area_onset_offset                                            = area_onset_offset;                                 % area tra onset e offset
%         output.tw(ntw).vmean_onset_offset                                           = vmean_onset_offset;                                % media curva tra onset e offset
%         output.tw(ntw).vmedian_onset_offset                                         = vmedian_onset_offset;                              % mediana curva tra onset e offset
%         output.tw(ntw).barycenter                                                   = barycenter;                                        % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
%         
%         
%     end
% end

end