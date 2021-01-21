function output = eeglab_study_plot_find_extrema_avg(input)

% curve,levels_f1,levels_f2,group_time_windows_list_design,times,which_extrema_design_roi,sel_extrema


curve                                                                      = input.curve;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
group_time_windows_list_design                                             = input.group_time_windows_list_design;
times                                                                      = input.times;
which_extrema_design_roi                                                   = input.which_extrema_design_roi;
sel_extrema                                                                = input.sel_extrema;



% output.curve{nf1,nf2}                     % (nsubj) MEAN per ogni soggetto nella finestra
% output.curve_tw{nf1,nf2}                  % (nsubj x ntp) serie temporale per ogni soggetto nella finestra

% output.extr{nf1,nf2}                  % (1) EXTR calcolato sulla serie temporale media di gruppo
% output.extr_lat{nf1,nf2}              % (1) LATENCY of EXTR calcolato sulla serie temporale media di gruppo

% output.extr_lat_vec{nf1,nf2}          % (n) latencies in cui raggiungi l'EXTR



% in questo metodo per trovare gli estremi viene usata la finestra globale di gruppo applicata direttamente al pattern medio di
% gruppo: si trovano gli estremi nella finestra selezionata basandosi sulpattern mediato tra tutti i soggetti.
output=[];
M=[];
% il cell array su cui fare la statistica
% curve;
% il cell array con il valore medio degli estremi su
% tutte le finestre temporali
extr={};
% le corrispondenti latenze
extr_lat={};
% nel caso abbia fatto i conti sui singolii
% soggetti, mi servono per ogni soggetto
% gli estremi selezionati (primo o baricentro)

if isempty(levels_f2)
    
    
    % selecting and averaging powers in a time window
    for nf1=1:length(levels_f1)
        %for each level in factor 1
        M2=[];
        extr_f12=[];
        extr_lat_vec_f12=[];
        extr_lat_f12=[];
        curve_tw_f12=[];
        
        % for each level in factor 2
        for nwin=1:length(group_time_windows_list_design)
            %for each time window
            tmin_group=group_time_windows_list_design{nwin}(1);
            tmax_group=group_time_windows_list_design{nwin}(2);
            sel_times_global = times >= tmin_group & times <= tmax_group ;
            M=curve{nf1,1};
            lse=length(which_extrema_design_roi);
            
            % 1) considera la finestra definita globalmente. per il patten medio, cerca il tipo di estremo richiesto per quella finestra, ottiene sia il valore dell'estremo E_gru, sia la sua latenza tE_gru
            % 2) usa la media sulla finestra temporale del gruppo (metodo standard)
            
            M0=M(sel_times_global,:);
            T0=times(sel_times_global);
            V0=mean(M0,2);
            
            str=['extr = ',which_extrema_design_roi{nwin},'(V0);'];
            eval(str);
            % prendiamo gli indici corrispondenti alle occorrenze dell'estremo (possono essere più di una)
            % ed ecco le latenze delle occorrenze dell'estremo
            extr_lat_V0=T0(V0==extr);
            
            switch sel_extrema
                % una prima scelta arbitraria è selezionare la prima occorrenza dell'estremo.
                case 'first_occurrence'
                    extr_lat=extr_lat_V0(1);
                    
                    % oppure, il baricentro (la media delle latenze)
                case 'avg_occurrences'
                    extr_lat=round(mean(extr_lat_V0));
            end
            
            M2(nwin,:)=mean(M0,1);
            
            % il valore dell'estremo (singolo valore)
            extr_f12{nwin}=extr;
            % il cell array con le corrispondenti latenze (possibilmente un vettore)
            extr_lat_vec_f12{nwin}=extr_lat_V0;
            % valore latenza selezionato in base a sel_extrema
            % (singolo valore)
            extr_lat_f12{nwin}=extr_lat;
            
            % matrice con i pattern di ciascun soggetto nella finestra
            % temporale selezionata. qui la finestra e' quella globale
            curve_tw_f12{nwin}=M0;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %attenzione: qui è finita la scelta tra le varie
            %stime degli estremi, ma stai ANCORA ciclando sulle finestre temporali
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % attenzione: qui hai finito di ciclare sulle
        % finestre ma stai ANCORA ciclando sui livelli del
        % fattore f1 e su quelli del fattore f2
        % qui salviamo nei cell array su f1 ed f2 (quello
        % che non viene calcolato rimane vuoto come
        % inizializzato)
        
        % cosa mi serve?
        
        % la matrice con le medie intra soggetto e per ciascuna finetra
        % temporale (serie temporale tipo il pattern nel caso senza
        
        % finestre temporali). questa matrice verra' passata alle funzioni
        % per la statistica e la rappresentazione
        output.curve{nf1,1} = M2;
        ...output.curve_avg{nf1,nf2} = mean(M2);
            
    % i pattern di tutti i soggetti nelle
    % finestre selezionate (per poter verificare / rifare i conti
    % altrove). in questo caso le finestre sono le stesse per ogni
    % soggetto e sono quelle globali di gruppo.
    output.curve_tw{nf1,1}=curve_tw_f12;
    
    % il valore degli estremi su
    % tutte le finestre temporali
    output.extr{nf1,1} = extr_f12;
    
    % le corrispondenti latenze (per ogni finestra, possibilmente un vettore con tutte le occorrenze)
    output.extr_lat_vec{nf1,1} = extr_lat_vec_f12;
    
    % per tutte le finestre, la latenza selezionata (e.g la prima occorrenza o la media delle occorrenze...)
    output.extr_lat{nf1,1} = extr_lat_f12;
    
    
    end
    %fine ciclo su f1
    output.which_extrema_design_roi=which_extrema_design_roi;
    %        display(output)
    
else
    
    
    % selecting and averaging powers in a time window
    for nf1=1:length(levels_f1)
        %for each level in factor 1
        for nf2=1:length(levels_f2)
            M2=[];
            extr_f12=[];
            extr_lat_vec_f12=[];
            extr_lat_f12=[];
            curve_tw_f12=[];
            
            % for each level in factor 2
            for nwin=1:length(group_time_windows_list_design)
                %for each time window
                tmin_group=group_time_windows_list_design{nwin}(1);
                tmax_group=group_time_windows_list_design{nwin}(2);
                sel_times_global = times >= tmin_group & times <= tmax_group ;
                M=curve{nf1,nf2};
                lse=length(which_extrema_design_roi);
                
                % 1) considera la finestra definita globalmente. per il patten medio, cerca il tipo di estremo richiesto per quella finestra, ottiene sia il valore dell'estremo E_gru, sia la sua latenza tE_gru
                % 2) usa la media sulla finestra temporale del gruppo (metodo standard)
                
                M0=M(sel_times_global,:);
                T0=times(sel_times_global);
                V0=mean(M0,2);
                
                str=['extr = ',which_extrema_design_roi{nwin},'(V0);'];
                eval(str);
                % prendiamo gli indici corrispondenti alle occorrenze dell'estremo (possono essere più di una)
                % ed ecco le latenze delle occorrenze dell'estremo
                extr_lat_V0=T0(V0==extr);
                
                switch sel_extrema
                    % una prima scelta arbitraria è selezionare la prima occorrenza dell'estremo.
                    case 'first_occurrence'
                        extr_lat=extr_lat_V0(1);
                        
                        % oppure, il baricentro (la media delle latenze)
                    case 'avg_occurrences'
                        extr_lat=round(mean(extr_lat_V0));
                end
                
                M2(nwin,:)=mean(M0,1);
                
                % il valore dell'estremo (singolo valore)
                extr_f12{nwin}=extr;
                % il cell array con le corrispondenti latenze (possibilmente un vettore)
                extr_lat_vec_f12{nwin}=extr_lat_V0;
                % valore latenza selezionato in base a sel_extrema
                % (singolo valore)
                extr_lat_f12{nwin}=extr_lat;
                
                % matrice con i pattern di ciascun soggetto nella finestra
                % temporale selezionata. qui la finestra e' quella globale
                curve_tw_f12{nwin}=M0;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %attenzione: qui è finita la scelta tra le varie
                %stime degli estremi, ma stai ANCORA ciclando sulle finestre temporali
                
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % attenzione: qui hai finito di ciclare sulle
            % finestre ma stai ANCORA ciclando sui livelli del
            % fattore f1 e su quelli del fattore f2
            % qui salviamo nei cell array su f1 ed f2 (quello
            % che non viene calcolato rimane vuoto come
            % inizializzato)
            
            % cosa mi serve?
            
            % la matrice con le medie intra soggetto e per ciascuna finetra
            % temporale (serie temporale tipo il pattern nel caso senza
            
            % finestre temporali). questa matrice verra' passata alle funzioni
            % per la statistica e la rappresentazione
            output.curve{nf1,nf2} = M2;
            ...output.curve_avg{nf1,nf2} = mean(M2);
                
        % i pattern di tutti i soggetti nelle
        % finestre selezionate (per poter verificare / rifare i conti
        % altrove). in questo caso le finestre sono le stesse per ogni
        % soggetto e sono quelle globali di gruppo.
        output.curve_tw{nf1,nf2}=curve_tw_f12;
        
        % il valore degli estremi su
        % tutte le finestre temporali
        output.extr{nf1,nf2} = extr_f12;
        
        % le corrispondenti latenze (per ogni finestra, possibilmente un vettore con tutte le occorrenze)
        output.extr_lat_vec{nf1,nf2} = extr_lat_vec_f12;
        
        % per tutte le finestre, la latenza selezionata (e.g la prima occorrenza o la media delle occorrenze...)
        output.extr_lat{nf1,nf2} = extr_lat_f12;
        
        end
        %fine ciclo su f2
    end
    %fine ciclo su f1
    output.which_extrema_design_roi=which_extrema_design_roi;
    %        display(output)
end
end
