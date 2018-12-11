function output = eeglab_mask_cell_p_gf(input,  varargin)

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
% curve                                                                      = input.curve;

levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;

name_f1 = input.name_f1;
name_f2 = input.name_f2;
name_gf = input.name_gf;
name_cf = input.name_cf;



% ho ancora i singoli soggetti
curve_allch                                              = input.curve_allch;
output_dd_gf                                                  = input.output_dd_gf;

allch                                                                      = input.allch;



times                                                                      = input.times;
levels_gf                                                     =   input.levels_gf  ;

lgf = length(levels_gf);






%

% cell array con le p calcolate per ogni livello del grouping factor
sigcell_pruned_gf =  output_dd_gf.sigcell_pruned_gf;
% per ogni livello del grouping factor i canali che presentano deflessioni
% significative rispetto alla baseline
sel_ch_cell_gf =  output_dd_gf.sel_ch_cell_gf;
% per livello del grouping factor e per ogni canale, le tw in cui c'è
% deflessione significativa
cell_tw_gf =  output_dd_gf.cell_tw_gf;
results_tw_cell_gf = output_dd_gf.results_tw_cell_gf;




tch = length(allch);

%% dimensioni del cell array : livelli del primo fattore, livelli del secondo fattore del disegno: ogbi elemento è una matrice con  a tre dimesnioni : canali, tempi, soggetti
[s1 s2]  = size(curve_allch);

results_tw_cell_gf_cf_ch = {};
% se il grouping factor è il primo fattore del disegno
if  strcmp(name_gf,name_f1)
    
    for ns1 = 1:s1 % per ciascun livello del primo fattore
        
        sel_ch =  sel_ch_cell_gf{ns1};
        tot_ch = length(sel_ch);
        
        
        %         estrai matrice p del grouping factor (livello s1)
        for ns2 = 1:s2 % per ogni livello del secondo fattore
            % moltipica la matrice della p del gf corrispondente a s1 per ogni livello
            % del compaing factor (s2)
            
            %  livello di gruping, per ogni livello di comparing e per ogni canale con deflessione significativa vado ad
            %  estrarmi i parametri di tutte le tw con deflessioni
            
            results_ch = {};
            
            for nch = 1:tot_ch
                ind_ch = sel_ch(nch);
                
                curve_ch = squeeze(curve_allch{ns1, ns2}(:,ind_ch,:));
                
                tot_sub = size(curve_ch,2);
                
                mat_tw = cell_tw_gf{ns1,nch};
                tot_tw = size(mat_tw,1);
                output_tw = struct;
                
                for ntw = 1:tot_tw;
                    
                    
                    tonset                                                                     = mat_tw(ntw,1);
                    toffset                                                                    = mat_tw(ntw,2);
                    
                    seltsig = times >= tonset & times <= toffset;
                    
                    
                    
                    
                    output_tw(ntw).tonset                                                       = nan;                                            % tempo di onset
                    output_tw(ntw).vonset                                                       = nan(tot_sub,1);                                            % valore di onset
                    output_tw(ntw).toffset                                                      = nan;                                           % tempo di offset
                    output_tw(ntw).voffset                                                      = nan(tot_sub,1);                                           % valore di offset
                    output_tw(ntw).tmax_deflection                                              = nan(tot_sub,1);                                   % tempo di valore massimo della deflessione
                    output_tw(ntw).max_deflection                                               = nan(tot_sub,1);                                    % valore massimo della deflessione
                    output_tw(ntw).tmin_deflection                                              = nan(tot_sub,1);                                   % tempo di valore minimo della deflessione
                    output_tw(ntw).min_deflection                                               = nan(tot_sub,1);                                    % valore valore minimo della deflessione
                    output_tw(ntw).dt_onset_max_deflection                                      = nan(tot_sub,1);                           % tempo tra onset e massimo di deflessione
                    output_tw(ntw).dt_max_deflection_offset                                     = nan(tot_sub,1);                          % tempo tra massimo di deflessione e offset
                    output_tw(ntw).area_onset_max_deflection                                    = nan(tot_sub,1);                         % area tra onset e massimo di deflessione
                    output_tw(ntw).area_max_deflection_offset                                   = nan(tot_sub,1);                        % area tra massimo di deflessione e offset
                    output_tw(ntw).dt_onset_min_deflection                                      = nan(tot_sub,1);                           % tempo tra onset e mainimo di deflessione
                    output_tw(ntw).dt_min_deflection_offset                                     = nan(tot_sub,1);                          % tempo tra minimo di deflessione e offset
                    output_tw(ntw).area_onset_min_deflection                                    = nan(tot_sub,1);                         % area tra onset e minimo di deflessione
                    output_tw(ntw).area_min_deflection_offset                                   = nan(tot_sub,1);                        % area tra minimo di deflessione e offset
                    output_tw(ntw).dt_onset_offset                                              = nan;                                   % tempo tra onset e offset
                    output_tw(ntw).area_onset_offset                                            = nan(tot_sub,1);                                 % area tra onset e offset
                    output_tw(ntw).vmean_onset_offset                                           = nan(tot_sub,1);                                % media curva tra onset e offset
                    output_tw(ntw).vmedian_onset_offset                                         = nan(tot_sub,1);                              % mediana curva tra onset e offset
                    output_tw(ntw).barycenter                                                   = nan(tot_sub,1);                                        % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
                    
                    
                    vonset                                                                     = curve_ch(times == tonset,:);
                    voffset                                                                    = curve_ch(times == toffset,:);
                    max_deflection                                                             = max(curve_ch(seltsig,:),[],1);
                    min_deflection                                                             = min(curve_ch(seltsig,:),[],1);
                    
                    
                    for nsub = 1:tot_sub
                        
                        ttt = times(curve_ch(:,nsub) == max_deflection(nsub));
                        tmax_deflection(nsub)                                                            = ttt(1);
                        
                        ttt = times(curve_ch(:,nsub) == min_deflection(nsub));
                        tmin_deflection(nsub)                                                            = ttt(1);
                        
                        
                        dt_onset_max_deflection(nsub)                                                    = tmax_deflection(nsub) - tonset;
                        dt_max_deflection_offset(nsub)                                                   = toffset - tmax_deflection(nsub);
                        
                        
                        selt2 = times >= tonset & times <= tmax_deflection(nsub);
                        area_onset_max_deflection(nsub)                                                  = sum(curve_ch(selt2,nsub));
                        
                        selt2 = times >= tmax_deflection(nsub) & times <= toffset;
                        area_max_deflection_offset(nsub)                                                 = sum(curve_ch(selt2,nsub));
                        
                        dt_onset_min_deflection(nsub)                                                    = tmin_deflection(nsub) - tonset;
                        dt_min_deflection_offset(nsub)                                                   = toffset - tmin_deflection(nsub);
                        
                        selt2 = times >= tonset & times <= tmin_deflection(nsub);
                        area_onset_min_deflection(nsub)                                                  = sum(curve_ch(selt2,nsub));
                        
                        selt2 = times >= tmin_deflection(nsub) & times <= toffset;
                        area_min_deflection_offset(nsub)                                                 = sum(curve_ch(selt2,nsub));
                        
                        dt_onset_offset                                                           = toffset - tonset;
                        
                        selt2 = times >= tonset & times <= toffset;
                        area_onset_offset(nsub)                                                          = sum(curve_ch(selt2,nsub));
                        vmean_onset_offset(nsub)                                                         = mean(curve_ch(selt2,nsub));
                        vmedian_onset_offset(nsub)                                                       = median(curve_ch(selt2,nsub));
                        
                        barycenter(nsub)                                                                 = sum( times(selt2).*curve_ch(selt2,nsub)') / sum(curve_ch(selt2,nsub));
                    end
                    
                    
                    %% output
                    
                    output_tw(ntw).tonset                                                       = tonset;                                            % tempo di onset
                    output_tw(ntw).vonset                                                       = vonset;                                            % valore di onset
                    output_tw(ntw).toffset                                                      = toffset;                                           % tempo di offset
                    output_tw(ntw).voffset                                                      = voffset;                                           % valore di offset
                    output_tw(ntw).tmax_deflection                                              = tmax_deflection;                                   % tempo di valore massimo della deflessione
                    output_tw(ntw).max_deflection                                               = max_deflection;                                    % valore massimo della deflessione
                    output_tw(ntw).tmin_deflection                                              = tmin_deflection;                                   % tempo di valore minimo della deflessione
                    output_tw(ntw).min_deflection                                               = min_deflection;                                    % valore valore minimo della deflessione
                    output_tw(ntw).dt_onset_max_deflection                                      = dt_onset_max_deflection;                           % tempo tra onset e massimo di deflessione
                    output_tw(ntw).dt_max_deflection_offset                                     = dt_max_deflection_offset;                          % tempo tra massimo di deflessione e offset
                    output_tw(ntw).area_onset_max_deflection                                    = area_onset_max_deflection;                         % area tra onset e massimo di deflessione
                    output_tw(ntw).area_max_deflection_offset                                   = area_max_deflection_offset;                        % area tra massimo di deflessione e offset
                    output_tw(ntw).dt_onset_min_deflection                                      = dt_onset_min_deflection;                           % tempo tra onset e mainimo di deflessione
                    output_tw(ntw).dt_min_deflection_offset                                     = dt_min_deflection_offset;                          % tempo tra minimo di deflessione e offset
                    output_tw(ntw).area_onset_min_deflection                                    = area_onset_min_deflection;                         % area tra onset e minimo di deflessione
                    output_tw(ntw).area_min_deflection_offset                                   = area_min_deflection_offset;                        % area tra minimo di deflessione e offset
                    output_tw(ntw).dt_onset_offset                                              = dt_onset_offset;                                   % tempo tra onset e offset
                    output_tw(ntw).area_onset_offset                                            = area_onset_offset;                                 % area tra onset e offset
                    output_tw(ntw).vmean_onset_offset                                           = vmean_onset_offset;                                % media curva tra onset e offset
                    output_tw(ntw).vmedian_onset_offset                                         = vmedian_onset_offset;                              % mediana curva tra onset e offset
                    output_tw(ntw).barycenter                                                   = barycenter;
                    
                    
                end
                
                results_ch{nch}= output_tw;
                
                
                
                
            end
            results_tw_cell_gf_cf_ch{ns1, ns2}= results_ch;
            
        end
    end
    
    
    
    
    %% se il grouping factor è il secondo fattore del disegno
else
    
    
    for ns2 = 1:s2 % per ciascun livello del primo fattore
        
        sel_ch =  sel_ch_cell_gf{ns2};
        tot_ch = length(sel_ch);
        
        
        %         estrai matrice p del grouping factor (livello s1)
        for ns1 = 1:s1 % per ogni livello del secondo fattore
            % moltipica la matrice della p del gf corrispondente a s1 per ogni livello
            % del compaing factor (s2)
            
            %  livello di gruping, per ogni livello di comparing e per ogni canale con deflessione significativa vado ad
            %  estrarmi i parametri di tutte le tw con deflessioni
            
            results_ch = {};
            
            for nch = 1:tot_ch
                ind_ch = sel_ch(nch);
                
                curve_ch = squeeze(curve_allch{ns1, ns2}(:,ind_ch,:));
                
                tot_sub = size(curve_ch,2);
                
                mat_tw = cell_tw_gf{ns2,nch};
                tot_tw = size(mat_tw,1);
                
                output_tw = [];
                
                for ntw = 1:tot_tw;
                    
                    
                    tonset                                                                     = mat_tw(ntw,1);
                    toffset                                                                    = mat_tw(ntw,2);
                    
                    seltsig = times >= tonset & times <= toffset;
                    
                    
                    
                    
                    output_tw(ntw).tonset                                                       = nan;                                            % tempo di onset
                    output_tw(ntw).vonset                                                       = nan(tot_sub,1);                                            % valore di onset
                    output_tw(ntw).toffset                                                      = nan;                                           % tempo di offset
                    output_tw(ntw).voffset                                                      = nan(tot_sub,1);                                           % valore di offset
                    output_tw(ntw).tmax_deflection                                              = nan(tot_sub,1);                                   % tempo di valore massimo della deflessione
                    output_tw(ntw).max_deflection                                               = nan(tot_sub,1);                                    % valore massimo della deflessione
                    output_tw(ntw).tmin_deflection                                              = nan(tot_sub,1);                                   % tempo di valore minimo della deflessione
                    output_tw(ntw).min_deflection                                               = nan(tot_sub,1);                                    % valore valore minimo della deflessione
                    output_tw(ntw).dt_onset_max_deflection                                      = nan(tot_sub,1);                           % tempo tra onset e massimo di deflessione
                    output_tw(ntw).dt_max_deflection_offset                                     = nan(tot_sub,1);                          % tempo tra massimo di deflessione e offset
                    output_tw(ntw).area_onset_max_deflection                                    = nan(tot_sub,1);                         % area tra onset e massimo di deflessione
                    output_tw(ntw).area_max_deflection_offset                                   = nan(tot_sub,1);                        % area tra massimo di deflessione e offset
                    output_tw(ntw).dt_onset_min_deflection                                      = nan(tot_sub,1);                           % tempo tra onset e mainimo di deflessione
                    output_tw(ntw).dt_min_deflection_offset                                     = nan(tot_sub,1);                          % tempo tra minimo di deflessione e offset
                    output_tw(ntw).area_onset_min_deflection                                    = nan(tot_sub,1);                         % area tra onset e minimo di deflessione
                    output_tw(ntw).area_min_deflection_offset                                   = nan(tot_sub,1);                        % area tra minimo di deflessione e offset
                    output_tw(ntw).dt_onset_offset                                              = nan;                                   % tempo tra onset e offset
                    output_tw(ntw).area_onset_offset                                            = nan(tot_sub,1);                                 % area tra onset e offset
                    output_tw(ntw).vmean_onset_offset                                           = nan(tot_sub,1);                                % media curva tra onset e offset
                    output_tw(ntw).vmedian_onset_offset                                         = nan(tot_sub,1);                              % mediana curva tra onset e offset
                    output_tw(ntw).barycenter                                                   = nan(tot_sub,1);                                        % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
                    
                    
                    vonset                                                                     = curve_ch(times == tonset,:);
                    voffset                                                                    = curve_ch(times == toffset,:);
                    max_deflection                                                             = max(curve_ch(seltsig,:),[],1);
                    min_deflection                                                             = min(curve_ch(seltsig,:),[],1);
                    
                    
                    for nsub = 1:tot_sub
                        
                        ttt = times(curve_ch(:,nsub) == max_deflection(nsub));
                        tmax_deflection(nsub)                                                            = ttt(1);
                        
                        ttt = times(curve_ch(:,nsub) == min_deflection(nsub));
                        tmin_deflection(nsub)                                                            = ttt(1);
                        
                        dt_onset_max_deflection(nsub)                                                    = tmax_deflection(nsub) - tonset;
                        dt_max_deflection_offset(nsub)                                                   = toffset - tmax_deflection(nsub);
                        
                        
                        selt2 = times >= tonset & times <= tmax_deflection(nsub);
                        area_onset_max_deflection(nsub)                                                  = sum(curve_ch(selt2,nsub));
                        
                        selt2 = times >= tmax_deflection(nsub) & times <= toffset;
                        area_max_deflection_offset(nsub)                                                 = sum(curve_ch(selt2,nsub));
                        
                        dt_onset_min_deflection(nsub)                                                    = tmin_deflection(nsub) - tonset;
                        dt_min_deflection_offset(nsub)                                                   = toffset - tmin_deflection(nsub);
                        
                        selt2 = times >= tonset & times <= tmin_deflection(nsub);
                        area_onset_min_deflection(nsub)                                                  = sum(curve_ch(selt2,nsub));
                        
                        selt2 = times >= tmin_deflection(nsub) & times <= toffset;
                        area_min_deflection_offset(nsub)                                                 = sum(curve_ch(selt2,nsub));
                        
                        dt_onset_offset                                                           = toffset - tonset;
                        
                        selt2 = times >= tonset & times <= toffset;
                        area_onset_offset(nsub)                                                          = sum(curve_ch(selt2,nsub));
                        vmean_onset_offset(nsub)                                                         = mean(curve_ch(selt2,nsub));
                        vmedian_onset_offset(nsub)                                                       = median(curve_ch(selt2,nsub));
                        
                        barycenter(nsub)                                                                 = sum( times(selt2).*curve_ch(selt2,nsub)') / sum(curve_ch(selt2,nsub));
                    end
                    
                    
                    %% output
                    
                    output_tw(ntw).tonset                                                       = tonset;                                            % tempo di onset
                    output_tw(ntw).vonset                                                       = vonset;                                            % valore di onset
                    output_tw(ntw).toffset                                                      = toffset;                                           % tempo di offset
                    output_tw(ntw).voffset                                                      = voffset;                                           % valore di offset
                    output_tw(ntw).tmax_deflection                                              = tmax_deflection;                                   % tempo di valore massimo della deflessione
                    output_tw(ntw).max_deflection                                               = max_deflection;                                    % valore massimo della deflessione
                    output_tw(ntw).tmin_deflection                                              = tmin_deflection;                                   % tempo di valore minimo della deflessione
                    output_tw(ntw).min_deflection                                               = min_deflection;                                    % valore valore minimo della deflessione
                    output_tw(ntw).dt_onset_max_deflection                                      = dt_onset_max_deflection;                           % tempo tra onset e massimo di deflessione
                    output_tw(ntw).dt_max_deflection_offset                                     = dt_max_deflection_offset;                          % tempo tra massimo di deflessione e offset
                    output_tw(ntw).area_onset_max_deflection                                    = area_onset_max_deflection;                         % area tra onset e massimo di deflessione
                    output_tw(ntw).area_max_deflection_offset                                   = area_max_deflection_offset;                        % area tra massimo di deflessione e offset
                    output_tw(ntw).dt_onset_min_deflection                                      = dt_onset_min_deflection;                           % tempo tra onset e mainimo di deflessione
                    output_tw(ntw).dt_min_deflection_offset                                     = dt_min_deflection_offset;                          % tempo tra minimo di deflessione e offset
                    output_tw(ntw).area_onset_min_deflection                                    = area_onset_min_deflection;                         % area tra onset e minimo di deflessione
                    output_tw(ntw).area_min_deflection_offset                                   = area_min_deflection_offset;                        % area tra minimo di deflessione e offset
                    output_tw(ntw).dt_onset_offset                                              = dt_onset_offset;                                   % tempo tra onset e offset
                    output_tw(ntw).area_onset_offset                                            = area_onset_offset;                                 % area tra onset e offset
                    output_tw(ntw).vmean_onset_offset                                           = vmean_onset_offset;                                % media curva tra onset e offset
                    output_tw(ntw).vmedian_onset_offset                                         = vmedian_onset_offset;                              % mediana curva tra onset e offset
                    output_tw(ntw).barycenter                                                   = barycenter;
                    
                    
                end
                
                results_ch{nch}= output_tw;
                
                
                
                
            end
            results_tw_cell_gf_cf_ch{ns1, ns2}= results_ch;
            
        end
    end
    
    
    
    
    
    
    
    
    
    
    
    
end

%% salvtaggio output
output.sigcell_pruned_gf =  sigcell_pruned_gf;
output.sel_ch_cell_gf =  sel_ch_cell_gf;
output.cell_tw_gf =  cell_tw_gf;
output.results_tw_cell_gf = results_tw_cell_gf;
output.results_tw_cell_gf_cf_ch = results_tw_cell_gf_cf_ch;


end













