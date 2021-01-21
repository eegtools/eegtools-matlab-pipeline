function output = eeglab_study_curve_tw_onset_offset(input,  varargin)

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
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
group_time_windows_list_design                                             = input.group_time_windows_list_design;
times                                                                      = input.times;
deflection_polarity_list                                                   = input.deflection_polarity_list;
min_duration                                                               = input.min_duration;                      % ha senso settare una diversa lunghezza minima a seconda della banda o del tipo del sgnale?
base_tw                                                                    = input.base_tw;                           % baseline in ms
pvalue                                                                     = input.pvalue;                            % default will be 0.05
correction                                                                 = input.correction;                        % string. correction for multiple comparisons 'none'| 'fdr' | 'holms' | 'bonferoni'


%% parametri per i contatori
% ttw         = length(group_time_windows_list_design);
tf1         = length(levels_f1);
tf2         = length(levels_f2);

%% inizializzo l'output
% output.input                                                               = input;
output=[];


if isempty(levels_f2)
    %% calcolo onset-offset per singolo soggetto
    for nf1 =1:tf1
        tsub = size(curve{nf1},2);
        for nsub = 1:tsub
            
            input_fcoo.curve                                           = curve{nf1}(:,nsub);
            input_fcoo.deflection_tw_list                              = group_time_windows_list_design;
            input_fcoo.base_tw                                         = base_tw;
            input_fcoo.times                                           = times;
            input_fcoo.deflection_polarity_list                        = deflection_polarity_list; % 'unknown', 'positive','negative'
            input_fcoo.sig_th                                          = pvalue;
            input_fcoo.min_duration                                    = min_duration; % minima durata di un segmento significativamente diverso dalla baseline, per evitare rumore
            input_fcoo.correction                                      = correction;
            
            % calcolo misure legate ad onset/offset
            fcoo = find_curve_onset_offset(input_fcoo);
            output.sub{nf1,nsub} = fcoo;
            
        end
    end
    
    %% calcolo onset-offset per media tra soggetti
    for nf1 =1:tf1
        input_fcoo.curve                                           = mean(curve{nf1},2);
        input_fcoo.deflection_tw_list                              = group_time_windows_list_design;
        input_fcoo.base_tw                                         = base_tw;
        input_fcoo.times                                           = times;
        input_fcoo.deflection_polarity_list                             = deflection_polarity_list; % 'unknown', 'positive','negative'
        input_fcoo.sig_th                                          = pvalue;
        input_fcoo.min_duration                                    = min_duration; % minima durata di un segmento significativamente diverso dalla baseline, per evitare rumore
        input_fcoo.correction                                      = correction;
        
        % calcolo misure legate ad onset/offset
        fcoo = find_curve_onset_offset(input_fcoo);
        output.avgsub{nf1} = fcoo;
    end
else
    
    %% calcolo onset-offset per singolo soggetto
    for nf1 =1:tf1
        for nf2 =1:tf2
            tsub = size(curve{nf1,nf2},2);
            for nsub = 1:tsub
                
                input_fcoo.curve                                           = curve{nf1,nf2}(:,nsub);
                input_fcoo.deflection_tw_list                              = group_time_windows_list_design;
                input_fcoo.base_tw                                         = base_tw;
                input_fcoo.times                                           = times;
                input_fcoo.deflection_polarity_list                        = deflection_polarity_list; % 'unknown', 'positive','negative'
                input_fcoo.sig_th                                          = pvalue;
                input_fcoo.min_duration                                    = min_duration; % minima durata di un segmento significativamente diverso dalla baseline, per evitare rumore
                input_fcoo.correction                                      = correction;
                
                % calcolo misure legate ad onset/offset
                fcoo = find_curve_onset_offset(input_fcoo);
                output.sub{nf1,nf2,nsub} = fcoo;
                
            end
        end
    end
    
    %% calcolo onset-offset per media tra soggetti
    for nf1 =1:tf1
        for nf2 =1:tf2
            input_fcoo.curve                                           = mean(curve{nf1,nf2},2);
            input_fcoo.deflection_tw_list                              = group_time_windows_list_design;
            input_fcoo.base_tw                                         = base_tw;
            input_fcoo.times                                           = times;
            input_fcoo.deflection_polarity_list                             = deflection_polarity_list; % 'unknown', 'positive','negative'
            input_fcoo.sig_th                                          = pvalue;
            input_fcoo.min_duration                                    = min_duration; % minima durata di un segmento significativamente diverso dalla baseline, per evitare rumore
            input_fcoo.correction                                      = correction;
            
            % calcolo misure legate ad onset/offset
            fcoo = find_curve_onset_offset(input_fcoo);
            output.avgsub{nf1,nf2} = fcoo;
            
            
        end
    end
    
    
    
end





end

