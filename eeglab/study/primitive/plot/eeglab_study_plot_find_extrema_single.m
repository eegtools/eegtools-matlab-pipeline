function output = eeglab_study_plot_find_extrema_single(input)

% curve,levels_f1,levels_f2,group_time_windows_list_design,subject_time_windows_list_design,times,which_extrema_design_roi,sel_extrema

curve                                                                      = input.curve;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
group_time_windows_list_design                                             = input.group_time_windows_list_design;
subject_time_windows_list_design                                           = input.subject_time_windows_list_design;
times                                                                      = input.times;
which_extrema_design_roi                                                   = input.which_extrema_design_roi;
sel_extrema                                                                = input.sel_extrema;

% convertire input output struttura




% output.curve{nf1,nf2}                     % (nsubj) MEAN per ogni soggetto nella finestra
% output.curve_tw{nf1,nf2}                  % (nsubj x ntp) serie temporale per ogni soggetto nella finestra

% output.extr{nf1,nf2}                      % (nsubj) EXTR per ogni soggetto nella finestra

% output.extr_mean{nf1,nf2}                 % (1) MEAN di ampiezza nella finestra
% output.extr_sd{nf1,nf2}                   % (1) SD di ampiezza nella finestra
% output.extr_median{nf1,nf2}               % (1) MEDIAN di ampiezza nella finestra
% output.extr_range{nf1,nf2}                % (2) MAX e MIN delle ampiezze tra tutti i soggetti

% output.extr_lat{nf1,nf2}                  % (nsubj) EXTR LATENCY (in funzione pero del criterio di occorrenza definito nel project config....e.g la prima occorrenza o la media delle occorrenze...)
% output.extr_lat_mean{nf1,nf2}             % (1) MEAN di latenza nella finestra
% output.extr_lat_sd{nf1,nf2}               % (1) SD di latenza nella finestra
% output.extr_lat_median{nf1,nf2}           % (1) MEDIAN di latenza nella finestra
% output.extr_lat_range{nf1,nf2}            % (2) MAX e MIN delle latenza tra tutti i soggetti

% output.extr_lat_vec{nf1,nf2}              % (nsubj x n) vettore con tutte le occorrenze dell'estremo per ogni soggetto

% output.extr_pattern_subject{nf1,nf2}      % (nsubj x ntp), inizializzata a NaN, per ogni soggetto contiene i valori della serie temporale nelle posizioni riallineate
% output.extr_pattern_lat_range{nf1,nf2}    %  (nsubj x 2), inizio e fine della finestra riallineata




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
        
        extr_f12=[];
        extr_lat_vec_f12=[];
        extr_lat_f12=[];
        curve_tw_f12=[];
        
        extr_mean_f12=[];
        extr_sd_f12=[];
        extr_median_f12=[];
        extr_range_f12=[];
        
        extr_lat_mean_f12=[];
        extr_lat_sd_f12=[];
        extr_lat_median_f12=[];
        extr_lat_range_f12=[];
        extr_pattern_lat_range_f12=[];
        extr_pattern_subject_f12=[];
        
        % for each level in factor 2
        M2=[];
        for nwin=1:length(group_time_windows_list_design)
            
            % for each time window
            tmin_group=group_time_windows_list_design{nwin}(1);
            tmax_group=group_time_windows_list_design{nwin}(2);
            
            % questi sono i limiti della finestra che andrà centrata
            % sull'estremo di ogni soggetto all'interno della
            % finestra di gruppo
            tmin_subject=subject_time_windows_list_design{nwin}(1);
            tmax_subject=subject_time_windows_list_design{nwin}(2);
            
            sel_times_global = times >= tmin_group & times <= tmax_group ;
            M=curve{nf1,1};
            lse=length(which_extrema_design_roi);
            
            M0=M(sel_times_global,:);
            T0=times(sel_times_global);
            V0=mean(M0,2);
            % mi alloco una matrice che riempo di NaN, per ogni soggetto, sostituirò con numeri solo la parte corrispondente alla sotto-finestra adattata all'estremo del soggetto.
            M1=NaN(size(M0));
            
            % ECCO DOVE ENTRA IN GIOCO LA
            % SPECIFICITA' DEL SOGGETTO
            for nsub=1:size(M,2)
                % per ogni soggetto, consideriamo i valori nella finestra estesa comune a tutti
                V0=M0(:,nsub);
                
                % calcoliamoci l'estremo del soggetto
                str=['extr_sub = ',which_extrema_design_roi{nwin},'(V0);'];
                eval(str);
                % prendiamo gli indici corrispondenti alle occorrenze dell'estremo (possono essere più di una)
                % ed ecco le latenze delle occorrenze dell'estremo
                extr_lat_V0=T0(V0==extr_sub);
                
                switch sel_extrema
                    % una prima scelta arbitraria è selezionare la prima occorrenza dell'estremo.
                    case 'first_occurrence'
                        extr_lat_sub=extr_lat_V0(1);
                        
                        % oppure, il baricentro (la media delle latenze)
                    case 'avg_occurrences'
                        extr_lat_sub=round(mean(extr_lat_V0));
                end
                % il valore dell'estremo (singolo valore)
                extr_f12(nwin,nsub)=extr_sub;
                % il cell array con le corrispondenti latenze (possibilmente un vettore)
                extr_lat_vec_f12{nwin}{nsub}=extr_lat_V0;
                % valore latenza selezionato in base a sel_extrema (singolo valore)
                extr_lat_f12(nwin,nsub)=extr_lat_sub;
                
                % ora bisogna centrare la finestrella (sotto-finestra) intorno all'estremo del soggetto,
                % bisogna evitare che lafinestra del singolo soggeto debordi da quella di gruppo
                % da qualche parte bisgnerà salvare questi valori, per ogni tw e soggetto
                
                tmin_sub=extr_lat_sub-abs(tmin_subject); %così sono sicuro per tutte le combinazioni di segni
                tmax_sub=extr_lat_sub+abs(tmax_subject);
                
                % adesso prendiamoci la finestra temporale del soggetto. bisogna imporre la condizione di stare dentro la finestra globale estesa di gruppo.
                sel_times_sub= (T0 >= tmin_group & T0 <= tmax_group) & ... condizione per la finestra estesa globale (evitare debordo)
                    (T0 >= tmin_sub & T0 <= tmax_sub); ... condizione aggiuntiva per adattarsi al soggetto (centare la finestra sull'estremo del soggetto)
                    
                % sostiuamo i NaN corrispondenti alla finestra ricentrata sull'estremo del soggetto con i valori corrispondenti.
                % in linea di principio, se i dati sono particolarmente patologici o le sottofinestre sono scelte male,
                % POTREBBE accadere di avere pochi, o addirittura 1 valore, se l'estremo casca esattamente sul punto estremo della finestra globale scelta.
                M1(sel_times_sub,nsub)=V0(sel_times_sub);
                
                % prendo il range deitempi usati per ogni soggetto
                % (tenendo conto anche del non debordo)
                T1=T0(sel_times_sub);
                extr_pattern_lat_range_f12{nwin}{nsub}=[min(T1), max(T1)];
                
                
            end
            
            
            
            % campi aggiuntivi rispetto al metodo avg, fornisco
            % qualche prima stima statistica parametrica e non
            % parametrica (eventualmente gia' pronta per essere
            % riportata in un paper)
            
            % per ogni finestra, la media degli estremi tra tutti i soggetti
            extr_mean_f12{nwin}=mean(extr_f12(nwin,:));
            % corrispondente deviazione standard
            extr_sd_f12{nwin}=std(extr_f12(nwin,:));
            % non parametrico, la mediana
            extr_median_f12{nwin}=median(extr_f12(nwin,:));
            % non parametrico, il range
            extr_range_f12{nwin}=[min(extr_f12(nwin,:)),max(extr_f12(nwin,:))];
            
            %stessi conti per le latenze
            extr_lat_mean_f12{nwin}=mean(extr_lat_f12(nwin,:));
            extr_lat_sd_f12{nwin}=std(extr_lat_f12(nwin,:));
            extr_lat_median_f12{nwin}=median(extr_lat_f12(nwin,:));
            extr_lat_range_f12{nwin}=[min(extr_lat_f12(nwin,:)),max(extr_lat_f12(nwin,:))];
            
            % la matrice che contiene, in ogni riga i dati del soggetto corrispondente nella sua finetra (i dati fuori dalla sua finestra vengono lasciati NaN)
            extr_pattern_subject_f12{nwin}=M1;
            
            % per fare la statistica, mi calcolo la media di ogni soggetto nella sua sotto finestra temporale riaggiustata intorno al suo estremo
            M2(nwin,:)=nanmean(M1,1);
            
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
        
        
        % aggiungo anche i campi aggiuntivi legati alla specificita'
        % dei soggetti
        output.extr_mean{nf1,1}=extr_mean_f12;
        output.extr_sd{nf1,1}=extr_sd_f12;
        output.extr_median{nf1,1}=extr_median_f12;
        output.extr_range{nf1,1}=extr_range_f12;
        
        output.extr_lat_mean{nf1,1}=extr_lat_mean_f12;
        output.extr_lat_sd{nf1,1}=extr_lat_sd_f12;
        output.extr_lat_median{nf1,1}=extr_lat_median_f12;
        output.extr_lat_range{nf1,1}=extr_lat_range_f12;
        
        
        % aggiungo il campo specifico al fatto di considerare
        % sotto-finestre centrate sull'estremo del singolo soggetto
        % (conservo il pattern di ogni soggetto)
        output.extr_pattern_subject{nf1,1}=extr_pattern_subject_f12;
        
        % per ogni soggetto, mi salvo gli estremi della finestra
        % temporale usata
        output.extr_pattern_lat_range{nf1,1}=extr_pattern_lat_range_f12;
        
    end
    %fine ciclo su f1
    output.which_extrema_design_roi=which_extrema_design_roi;
    ...display(output);
else
% selecting and averaging powers in a time window
for nf1=1:length(levels_f1)
    %for each level in factor 1
    for nf2=1:length(levels_f2)
        
        extr_f12=[];
        extr_lat_vec_f12=[];
        extr_lat_f12=[];
        curve_tw_f12=[];
        
        extr_mean_f12=[];
        extr_sd_f12=[];
        extr_median_f12=[];
        extr_range_f12=[];
        
        extr_lat_mean_f12=[];
        extr_lat_sd_f12=[];
        extr_lat_median_f12=[];
        extr_lat_range_f12=[];
        extr_pattern_lat_range_f12=[];
        extr_pattern_subject_f12=[];
        
        % for each level in factor 2
        M2=[];
        for nwin=1:length(group_time_windows_list_design)
            
            % for each time window
            tmin_group=group_time_windows_list_design{nwin}(1);
            tmax_group=group_time_windows_list_design{nwin}(2);
            
            % questi sono i limiti della finestra che andrà centrata
            % sull'estremo di ogni soggetto all'interno della
            % finestra di gruppo
            tmin_subject=subject_time_windows_list_design{nwin}(1);
            tmax_subject=subject_time_windows_list_design{nwin}(2);
            
            sel_times_global = times >= tmin_group & times <= tmax_group ;
            M=curve{nf1,nf2};
            lse=length(which_extrema_design_roi);
            
            M0=M(sel_times_global,:);
            T0=times(sel_times_global);
            V0=mean(M0,2);
            % mi alloco una matrice che riempo di NaN, per ogni soggetto, sostituirò con numeri solo la parte corrispondente alla sotto-finestra adattata all'estremo del soggetto.
            M1=NaN(size(M0));
            
            % ECCO DOVE ENTRA IN GIOCO LA
            % SPECIFICITA' DEL SOGGETTO
            for nsub=1:size(M,2)
                % per ogni soggetto, consideriamo i valori nella finestra estesa comune a tutti
                V0=M0(:,nsub);
                
                % calcoliamoci l'estremo del soggetto
                str=['extr_sub = ',which_extrema_design_roi{nwin},'(V0);'];
                eval(str);
                % prendiamo gli indici corrispondenti alle occorrenze dell'estremo (possono essere più di una)
                % ed ecco le latenze delle occorrenze dell'estremo
                extr_lat_V0=T0(V0==extr_sub);
                
                switch sel_extrema
                    % una prima scelta arbitraria è selezionare la prima occorrenza dell'estremo.
                    case 'first_occurrence'
                        extr_lat_sub=extr_lat_V0(1);
                        
                        % oppure, il baricentro (la media delle latenze)
                    case 'avg_occurrences'
                        extr_lat_sub=round(mean(extr_lat_V0));
                end
                % il valore dell'estremo (singolo valore)
                extr_f12(nwin,nsub)=extr_sub;
                % il cell array con le corrispondenti latenze (possibilmente un vettore)
                extr_lat_vec_f12{nwin}{nsub}=extr_lat_V0;
                % valore latenza selezionato in base a sel_extrema (singolo valore)
                extr_lat_f12(nwin,nsub)=extr_lat_sub;
                
                % ora bisogna centrare la finestrella (sotto-finestra) intorno all'estremo del soggetto,
                % bisogna evitare che lafinestra del singolo soggeto debordi da quella di gruppo
                % da qualche parte bisgnerà salvare questi valori, per ogni tw e soggetto
                
                tmin_sub=extr_lat_sub-abs(tmin_subject); %così sono sicuro per tutte le combinazioni di segni
                tmax_sub=extr_lat_sub+abs(tmax_subject);
                
                % adesso prendiamoci la finestra temporale del soggetto. bisogna imporre la condizione di stare dentro la finestra globale estesa di gruppo.
                sel_times_sub= (T0 >= tmin_group & T0 <= tmax_group) & ... condizione per la finestra estesa globale (evitare debordo)
                    (T0 >= tmin_sub & T0 <= tmax_sub); ... condizione aggiuntiva per adattarsi al soggetto (centare la finestra sull'estremo del soggetto)
                    
                % sostiuamo i NaN corrispondenti alla finestra ricentrata sull'estremo del soggetto con i valori corrispondenti.
                % in linea di principio, se i dati sono particolarmente patologici o le sottofinestre sono scelte male,
                % POTREBBE accadere di avere pochi, o addirittura 1 valore, se l'estremo casca esattamente sul punto estremo della finestra globale scelta.
                M1(sel_times_sub,nsub)=V0(sel_times_sub);
                
                % prendo il range deitempi usati per ogni soggetto
                % (tenendo conto anche del non debordo)
                T1=T0(sel_times_sub);
                extr_pattern_lat_range_f12{nwin}{nsub}=[min(T1), max(T1)];
                
                
            end
            
            
            
            % campi aggiuntivi rispetto al metodo avg, fornisco
            % qualche prima stima statistica parametrica e non
            % parametrica (eventualmente gia' pronta per essere
            % riportata in un paper)
            
            % per ogni finestra, la media degli estremi tra tutti i soggetti
            extr_mean_f12{nwin}=mean(extr_f12(nwin,:));
            % corrispondente deviazione standard
            extr_sd_f12{nwin}=std(extr_f12(nwin,:));
            % non parametrico, la mediana
            extr_median_f12{nwin}=median(extr_f12(nwin,:));
            % non parametrico, il range
            extr_range_f12{nwin}=[min(extr_f12(nwin,:)),max(extr_f12(nwin,:))];
            
            %stessi conti per le latenze
            extr_lat_mean_f12{nwin}=mean(extr_lat_f12(nwin,:));
            extr_lat_sd_f12{nwin}=std(extr_lat_f12(nwin,:));
            extr_lat_median_f12{nwin}=median(extr_lat_f12(nwin,:));
            extr_lat_range_f12{nwin}=[min(extr_lat_f12(nwin,:)),max(extr_lat_f12(nwin,:))];
            
            % la matrice che contiene, in ogni riga i dati del soggetto corrispondente nella sua finetra (i dati fuori dalla sua finestra vengono lasciati NaN)
            extr_pattern_subject_f12{nwin}=M1;
            
            % per fare la statistica, mi calcolo la media di ogni soggetto nella sua sotto finestra temporale riaggiustata intorno al suo estremo
            M2(nwin,:)=nanmean(M1,1);
            
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
        
        
        % aggiungo anche i campi aggiuntivi legati alla specificita'
        % dei soggetti
        output.extr_mean{nf1,nf2}=extr_mean_f12;
        output.extr_sd{nf1,nf2}=extr_sd_f12;
        output.extr_median{nf1,nf2}=extr_median_f12;
        output.extr_range{nf1,nf2}=extr_range_f12;
        
        output.extr_lat_mean{nf1,nf2}=extr_lat_mean_f12;
        output.extr_lat_sd{nf1,nf2}=extr_lat_sd_f12;
        output.extr_lat_median{nf1,nf2}=extr_lat_median_f12;
        output.extr_lat_range{nf1,nf2}=extr_lat_range_f12;
        
        
        % aggiungo il campo specifico al fatto di considerare
        % sotto-finestre centrate sull'estremo del singolo soggetto
        % (conservo il pattern di ogni soggetto)
        output.extr_pattern_subject{nf1,nf2}=extr_pattern_subject_f12;
        
        % per ogni soggetto, mi salvo gli estremi della finestra
        % temporale usata
        output.extr_pattern_lat_range{nf1,nf2}=extr_pattern_lat_range_f12;
    end
    %fine ciclo su f2
end
%fine ciclo su f1
output.which_extrema_design_roi=which_extrema_design_roi;
...display(output);
    
end
end