function output = find_curve_onset_offset(input,  varargin)

curve                                                                      = input.curve;
deflection_tw                                                              = input.deflection_tw;
base_tw                                                                    = input.base_tw;
times                                                                      = input.times;
deflection_polarity                                                        = input.deflection_polarity; % 'unknown', 'positive','negative'
sig_th                                                                     = input.sig_th;
min_duration                                                               = input.min_duration; % minima durata di un segmento significativamente diverso dalla baseline, per evitare rumore
correction                                                                 = input.correction;
dt = abs(times(2) - times(2));

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


tonset                = min(times(sigvec>0));
toffset               = max(times(sigvec>0));

% output
output.pvec           = pvec;
output.sigvec         = sigvec;
output.tonset         = tonset;
output.toffset        = toffset;



end