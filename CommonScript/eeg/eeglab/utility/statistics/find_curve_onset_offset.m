function output = find_curve_onset_offset(input,  varargin)

curve                                                                      = input.curve;
deflection_tw                                                              = input.deflection_tw;
base_tw                                                                    = input.base_tw;
times                                                                      = input.times;
deflection_polarity                                                        = input.deflection_polarity; % 'unknown', 'positive','negative'
sig_th                                                                     = input.sig_th;
min_duration                                                               = input.min_duration; % minima durata di un segmento significativamente diverso dalla baseline, per evitare rumore
correction                                                                 = input.correction;

output = [];


dt = abs(times(2) - times(1));

if (isempty(sig_th) || isnan(sig_th))
    sig_th = 0.05;
end

if (isempty(min_duration) || isnan(min_duration))
    min_duration = 1;
end



switch deflection_polarity
    case 'unknown'
        tail = 'both';
    case 'positive'
        tail = 'right';
    case 'negative'
        tail = 'left';
end


tt     = length(times);
pvec   = nan(tt,1);

% mask to select the baseline
sel_base    = times >= base_tw(1) & times <= base_tw(2);
base        = curve(sel_base);

% mask to select the possible deflection to be compared with the baseline
ind_deflection        = find(times >= deflection_tw(1) & times <= deflection_tw(2));
deflection            = curve(ind_deflection);
ttt=length(deflection);

% for each time point within the time window of the possible deflection to be compared with the baseline
for ntt=1:ttt
    ind2test             = ind_deflection(ntt);
    point2test           = deflection(ntt);
    [h,pval]             = ttest2(point2test, base,'tail',tail);
    pvec(ind2test)       = pval;
end

pvec       = mcorrect(pvec,correction);
sigvec     = pvec<sig_th;


if not(isempty(min_duration) | isnan(min_duration))

    input_ls.curve        = sigvec;
    input_ls.min_duration = round(min_duration/dt); % converto in samples da tempo

    sigvec                = find_long_steps(input_ls);
end


tonset                                                                     = min(times(sigvec>0));
toffset                                                                    = max(times(sigvec>0));

if not(isempty(tonset)) && not(isempty(tonset))
    vonset                                                                     = curve(times == tonset);
    voffset                                                                    = curve(times == toffset);
    max_deflection                                                             = max(curve(sigvec>0));
    tmax_deflection                                                            = times(curve == max_deflection);
    min_deflection                                                             = min(curve(sigvec>0));
    tmin_deflection                                                            = times(curve == min_deflection);
    dt_onset_max_deflection                                                    = tmax_deflection - tonset;
    dt_max_deflection_offset                                                   = toffset - tmax_deflection;
    selt = times >= tonset & times <= max_deflection;
    area_onset_max_deflection                                                  = sum(curve(selt));
    selt = times >= max_deflection & times <= toffset;
    area_max_deflection_offset                                                 = sum(curve(selt));
    dt_onset_min_deflection                                                    = tmin_deflection - tonset;
    dt_min_deflection_offset                                                   = toffset - tmin_deflection;
    selt = times >= tonset & times <= min_deflection;
    area_onset_min_deflection                                                  = sum(curve(selt));
    selt = times >= min_deflection & times <= toffset;
    area_min_deflection_offset                                                 = sum(curve(selt));
    dt_onset_offset                                                            = toffset - tonset;
    selt = times >= tonset & times <= toffset;
    area_onset_offset                                                          = sum(curve(selt));
    vmean_onset_offset                                                         = mean(curve(selt));
    vmedian_onset_offset                                                       = median(curve(selt));
    barycenter                                                                 = sum( times(selt).*curve(selt)') / sum(curve(selt));
    
    %% output
%     output.input                                                                = input;
    output.pvec                                                         = pvec;                                              % vettore con valori di p
    output.sigvec                                                       = sigvec;                                            % vettore con maschera significatività
    output.tonset                                                       = tonset;                                            % tempo di onset
    output.vonset                                                       = vonset;                                            % valore di onset
    output.toffset                                                      = toffset;                                           % tempo di offset
    output.voffset                                                      = voffset;                                           % valore di offset
    output.tmax_deflection                                              = tmax_deflection;                                   % tempo di valore massimo della deflessione
    output.max_deflection                                               = max_deflection;                                    % valore massimo della deflessione
    output.tmin_deflection                                              = tmin_deflection;                                   % tempo di valore minimo della deflessione
    output.min_deflection                                               = min_deflection;                                    % valore valore minimo della deflessione
    output.dt_onset_max_deflection                                      = dt_onset_max_deflection;                           % tempo tra onset e massimo di deflessione
    output.dt_max_deflection_offset                                     = dt_max_deflection_offset;                          % tempo tra massimo di deflessione e offset
    output.area_onset_max_deflection                                    = area_onset_max_deflection;                         % area tra onset e massimo di deflessione
    output.area_max_deflection_offset                                   = area_max_deflection_offset;                        % area tra massimo di deflessione e offset
    output.dt_onset_min_deflection                                      = dt_onset_min_deflection;                           % tempo tra onset e mainimo di deflessione
    output.dt_min_deflection_offset                                     = dt_min_deflection_offset;                          % tempo tra minimo di deflessione e offset
    output.area_onset_min_deflection                                    = area_onset_min_deflection;                         % area tra onset e minimo di deflessione
    output.area_min_deflection_offset                                   = area_min_deflection_offset;                        % area tra minimo di deflessione e offset
    output.dt_onset_offset                                              = dt_onset_offset;                                   % tempo tra onset e offset
    output.area_onset_offset                                            = area_onset_offset;                                 % area tra onset e offset
    output.vmean_onset_offset                                           = vmean_onset_offset;                                % media curva tra onset e offset
    output.vmedian_onset_offset                                         = vmedian_onset_offset;                              % mediana curva tra onset e offset
    output.barycenter                                                   = barycenter;                                        % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
    
    
end


end