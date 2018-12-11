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
levels_gf                                                     = input.levels_gf;
% group_time_windows_list_design                                             = input.group_time_windows_list_design;
times                                                                      = input.times;
% deflection_polarity_list                                                   = input.deflection_polarity_list;
min_duration                                                               = input.min_duration;                      % ha senso settare una diversa lunghezza minima a seconda della banda o del tipo del sgnale?
base_tw                                                                    = input.base_tw;                           % baseline in ms
pvalue                                                                     = input.pvalue;                            % default will be 0.05
correction                                                                 = input.correction;                        % string. correction for multiple comparisons 'none'| 'fdr' | 'holms' | 'bonferoni'
select_tw_des_stat                                                         = input.select_tw_des_stat;


if isempty(select_tw_des_stat)
    select_tw_des_stat = [times(1), times(end)];
end

%% parametri per i contatori
% totale livelli del grouping factor
tf_gf         = length(levels_gf);

%% inizializzo l'output
% output.input                                                               = input;
output=[];


sigcell_pruned_gf = {};
cell_tw_gf  = {};
sel_ch_cell_gf = {};
results_tw_cell_gf = {};


%% calcolo onset-offset per ogni livello del grouping factor e canale
for nf_gf =1:tf_gf
    
    
    [ tot_ch, tot_times] = size(curve{nf_gf});
    
    mat_pch_raw = [];
    mat_zvalch_raw = [];
    mat_cich_raw = [];
    
    for nch = 1:tot_ch
        input_fcoo.curve                                           = curve{nf_gf}(nch,:);
        %             input_fcoo.deflection_tw_list                              = group_time_windows_list_design;
        input_fcoo.base_tw                                         = base_tw;
        input_fcoo.times                                           = times;
        %             input_fcoo.deflection_polarity_list                        = deflection_polarity_list; % 'unknown', 'positive','negative'
        %         input_fcoo.sig_th                                          = pvalue;
        %             input_fcoo.min_duration                                    = min_duration; % minima durata di un segmento significativamente diverso dalla baseline, per evitare rumore
        %         input_fcoo.correction                                      = correction;
        
        % calcolo misure legate ad onset/offset
        fcoo = compare_curve_baseline_data_driven(input_fcoo);
        %         output.ch{nf_gf,nch} = fcoo;
        
        mat_pch_raw(nch,:) = fcoo.pvec_raw;
        mat_zvalch_raw(nch,:) = fcoo.zval_raw;
%         mat_cich_raw(nch,:) = fcoo.ci_raw;
        
    end
    
    results_ztest.mat_pch_raw = mat_pch_raw;
    results_ztest.mat_zvalch_raw = mat_zvalch_raw;
    results_ztest.mat_cich_raw = mat_cich_raw;

    
    t1 = select_tw_des_stat(1);
    t2 = select_tw_des_stat(2);
    
    select_time = (times >= t1 & times <= t2);
    exclude_time = not(select_time);
    
    mat_pch_raw(:,exclude_time) = 1;
    
    mat_pch_corrected    = mat_pch_raw;
    mat_pch_corrected(:,select_time)    = mcorrect(mat_pch_raw(:,select_time),correction);
    
    sigmat_raw     = mat_pch_corrected < pvalue;
    
    
    
    
    sigmat_pruned = sigmat_raw + 0;
    dt = abs(times(2) - times(1));
    
    if sum(sum(sigmat_pruned))
        % ora andiamo a selezionare solo le deflessioni sufficientemente lunghe
        if not(isempty(min_duration) | isnan(min_duration))
            if min_duration >= dt
                for nch = 1:tot_ch
                    %             disp(nch);
                    input_ls.curve        = sigmat_raw(nch,select_time);
                    input_ls.min_duration = round(min_duration/dt); % converto in samples da tempo
                    sigmat_pruned(nch,select_time)  = find_long_steps(input_ls);
                end
            end
            
        end
        
    end
    
    
    sigcell_pruned_gf{nf_gf} = sigmat_pruned;
    
    %% estrazione time windows per ogni canale con tutti parametri relativi
    sigmat_pruned_0 = sigmat_pruned;
    
    sigmat_pruned_0(isnan(sigmat_pruned)) = 0;
    sel_ch = find(sum(sigmat_pruned_0,2) >0);
    
    sel_ch_cell_gf{nf_gf} = sel_ch;
    
    
    
    tot_ch_def = length(sel_ch);
    times_selected = times(select_time);

    tot_t = length(times_selected);
    
    
    for nch = 1: tot_ch_def
        
        mat_tw = [];
        
        
        ind_ch = sel_ch(nch);
        data_ch =  sigmat_pruned_0(ind_ch,select_time);
        if sum(data_ch) == tot_t
            mat_tw(1,:) =[ times_selected(1),times_selected(tot_t)];
        else
            
            discont = diff(data_ch);
            
            salite = find(discont == 1);
            discese = find(discont == -1);
            
            ini_tw = salite;
            fin_tw = discese;
            
            if data_ch(1) == 1
                ini_tw = [1, ini_tw];
            end
            
            if data_ch(tot_t) == 1
                fin_tw = [fin_tw, tot_t];
            end
            
            
            for n_ini = 1:length(ini_tw)
                mat_tw(n_ini,:) = times_selected([ini_tw(n_ini), fin_tw(n_ini)]);
            end
        end
        cell_tw_gf{nf_gf,nch} = mat_tw;
        
    end
end


for nf_gf =1:tf_gf
    sel_ch =  sel_ch_cell_gf{nf_gf};
    tot_ch = length(sel_ch);
    for nch = 1:tot_ch
        ind_ch = sel_ch(nch);
        curve_ch = curve{nf_gf}(ind_ch,select_time);
        
        mat_tw = cell_tw_gf{nf_gf,nch};
        tot_tw = size(mat_tw,1);
        for ntw = 1:tot_tw;
            
            % ora andiamo ad estrarre i parametri per ogni tw
            
            %         for ntw = 1:length(deflection_tw_list)
            %         selt = times >= deflection_tw_list{ntw}(1) & times <= deflection_tw_list{ntw}(2);
            %         if sum(size(selt) == size(sigvec)) ==2
            %             seltsig = selt & sigvec>0;
            %         else
            %             seltsig = selt & sigvec'>0;
            %         end
            
            
            tonset                                                                     = mat_tw(ntw,1);
            toffset                                                                    = mat_tw(ntw,2);
            
            seltsig = times_selected >= tonset & times_selected <= toffset;
            
            %
            %
            output_tw(ntw).tonset                                                       = nan;                                            % tempo di onset
            output_tw(ntw).vonset                                                       = nan;                                            % valore di onset
            output_tw(ntw).toffset                                                      = nan;                                           % tempo di offset
            output_tw(ntw).voffset                                                      = nan;                                           % valore di offset
            output_tw(ntw).tmax_deflection                                              = nan;                                   % tempo di valore massimo della deflessione
            output_tw(ntw).max_deflection                                               = nan;                                    % valore massimo della deflessione
            output_tw(ntw).tmin_deflection                                              = nan;                                   % tempo di valore minimo della deflessione
            output_tw(ntw).min_deflection                                               = nan;                                    % valore valore minimo della deflessione
            output_tw(ntw).dt_onset_max_deflection                                      = nan;                           % tempo tra onset e massimo di deflessione
            output_tw(ntw).dt_max_deflection_offset                                     = nan;                          % tempo tra massimo di deflessione e offset
            output_tw(ntw).area_onset_max_deflection                                    = nan;                         % area tra onset e massimo di deflessione
            output_tw(ntw).area_max_deflection_offset                                   = nan;                        % area tra massimo di deflessione e offset
            output_tw(ntw).dt_onset_min_deflection                                      = nan;                           % tempo tra onset e mainimo di deflessione
            output_tw(ntw).dt_min_deflection_offset                                     = nan;                          % tempo tra minimo di deflessione e offset
            output_tw(ntw).area_onset_min_deflection                                    = nan;                         % area tra onset e minimo di deflessione
            output_tw(ntw).area_min_deflection_offset                                   = nan;                        % area tra minimo di deflessione e offset
            output_tw(ntw).dt_onset_offset                                              = nan;                                   % tempo tra onset e offset
            output_tw(ntw).area_onset_offset                                            = nan;                                 % area tra onset e offset
            output_tw(ntw).vmean_onset_offset                                           = nan;                                % media curva tra onset e offset
            output_tw(ntw).vmedian_onset_offset                                         = nan;                              % mediana curva tra onset e offset
            output_tw(ntw).barycenter                                                   = nan;                                        % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
            
            
            
            
            
            vonset                                                                     = curve_ch(times_selected == tonset);
            voffset                                                                    = curve_ch(times_selected == toffset);
            max_deflection                                                             = max(curve_ch(seltsig));
            ttt                                                                        = times_selected(curve_ch == max_deflection);
            tmax_deflection                                                            = ttt(1);
            
            min_deflection                                                             = min(curve_ch(seltsig));
            ttt                                                            = times_selected(curve_ch == min_deflection);
            tmin_deflection                                                            = ttt(1);

            dt_onset_max_deflection                                                    = tmax_deflection - tonset;
            dt_max_deflection_offset                                                   = toffset - tmax_deflection;
            
            
            selt2 = times_selected >= tonset & times_selected <= tmax_deflection;
            area_onset_max_deflection                                                  = sum(curve_ch(selt2));
            
            selt2 = times_selected >= tmax_deflection & times_selected <= toffset;
            area_max_deflection_offset                                                 = sum(curve_ch(selt2));
            
            dt_onset_min_deflection                                                    = tmin_deflection - tonset;
            dt_min_deflection_offset                                                   = toffset - tmin_deflection;
            
            selt2 = times_selected >= tonset & times_selected <= tmin_deflection;
            area_onset_min_deflection                                                  = sum(curve_ch(selt2));
            
            selt2 = times_selected >= tmin_deflection & times_selected <= toffset;
            area_min_deflection_offset                                                 = sum(curve_ch(selt2));
            
            dt_onset_offset                                                           = toffset - tonset;
            
            selt2 = times_selected >= tonset & times_selected <= toffset;
            area_onset_offset                                                          = sum(curve_ch(selt2));
            vmean_onset_offset                                                         = mean(curve_ch(selt2));
            vmedian_onset_offset                                                       = median(curve_ch(selt2));
            
            barycenter                                                                 = sum( times_selected(selt2).*curve_ch(selt2)) / sum(curve_ch(selt2));
            
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
            output_tw(ntw).barycenter                                                   = barycenter;                                        % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
            
            
        end
        results_tw_cell_gf{nf_gf,nch}= output_tw;
    end
end
output.sigcell_pruned_gf =  sigcell_pruned_gf;
output.sel_ch_cell_gf =  sel_ch_cell_gf;
output.cell_tw_gf =  cell_tw_gf;
output.results_tw_cell_gf = results_tw_cell_gf;
output.results_ztest = results_ztest; 

end















