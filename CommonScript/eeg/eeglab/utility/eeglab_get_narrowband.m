%% function [sub_adjusted_fmin, sub_adjusted_fmax, sub_realign_freq, sub_realign_freq_value, sub_realign_freq_value_lat, mean_centroid_group_fb, mean_centroid_sub_realign_fb, median_centroid_group_fb, median_centroid_sub_realign_fb] = ...
%     eeglab_get_narrowband(ersp_matrix_sub, times, freqs, group_tmin, group_tmax, group_fmin, group_fmax, group_dfmin, group_dfmax,which_realign_measure)
% calculate adjusted frequency band limits for each subject. 
% starts from group frequency band limits. for each frequency in the group
% frequency band, find hightest reaign measure(maximum, minumum or area under the curve, respectively 'max', 'mean', 'auc') in the group
% defined time window. Select the frequency with the more pronounced
% realign measure. 
% exports: 
% 1) the frequency corresponding to the strongest realign measure; 
% 2) the realign measure value of that frequencuency and its latency
% 3) the subject-adjusted limits of the frequency band
% 4) centroid frequency for the group and the realigned frequency band: mean(freq_vec*ersp_freq_vec) 



function [sub_adjusted_fmin, sub_adjusted_fmax, sub_realign_freq, sub_realign_freq_value, sub_realign_freq_value_lat, ...
    mean_centroid_group_fb, mean_centroid_sub_realign_fb, median_centroid_group_fb, median_centroid_sub_realign_fb] = ...
    eeglab_get_narrowband(ersp_matrix_sub, times, freqs, group_tmin, group_tmax, group_fmin, group_fmax, group_dfmin, group_dfmax, which_realign_measure)

    if nargin <10
        help eeglab_get_narrowband
        return;
    end

    sub_adjusted_fmin=[];
    sub_adjusted_fmax=[];
    sub_realign_freq=[];
   
    % ersp_matrix_sub=ersp_roi{nf1,nf2}(sel_freqs,:,nsub);

    sel_times= times >= group_tmin & times <= group_tmax;
    sel_freqs= freqs >= group_fmin & freqs <= group_fmax;

    ersp_matrix_sub_tw_fb=ersp_matrix_sub(sel_freqs,sel_times);
    
    mean_centroid_group_fb=mean(freqs(sel_freqs).*mean(ersp_matrix_sub_tw_fb(sel_freqs,:),2));
    median_centroid_group_fb=median(freqs(sel_freqs).*mean(ersp_matrix_sub_tw_fb(sel_freqs,:),2));
    
    
    if strcmp(which_realign_measure,'min')
       
       % vettore con le misure di riallineamento in tutte le frequenze nella finetra temporale
       % selezionata
       realign_freqs_vec=min(ersp_matrix_sub_tw_fb,[],2);

       % valore della misura di riallineamento più pronunciatatra tutte le frequenze
       sub_realign_freq_value=min(realign_freqs_vec);

       % seleziono la frequenza con la misura di riallineamento più pronunciata
       sel_freq_strongest_realign=find(realign_freqs_vec==sub_realign_freq_value);

       % se avessi più frequenze che raggiungono l'etremo, considero
       % arbitrariamente la prima
       sel_freq_strongest_realign=sel_freq_strongest_realign(1);

       % seleziono la frequenza con la misura di riallineamento più pronunciata
       sub_realign_freq=freqs(sel_freq_strongest_realign);              

       % seleziono la curva che corrisponde alla ERSP in funzione del tempo nella frequenza che presenta la misura di riallineamento più pronunciata
       realign_freq_curve=ersp_matrix_sub_tw_fb(sel_freq_strongest_realign,:);

       % calcolo la latenza corrispondente al raggiungimento della misura di riallineamento
       % nella frequenza con l'etremo più pronunciata
       sub_realign_freq_value_lat=times(realign_freq_curve==sub_realign_freq_value);

       % anche qui, considero arbitrariamente solo la PRIMA occorrenza
       % dell'etremo
       sub_realign_freq_value_lat=sub_realign_freq_value_lat(1);
       
       % calcolo il limite inferiore della banda subject-adjusted       
       sub_adjusted_fmin=sub_realign_freq-group_dfmin;
       
         % calcolo il limite superiore della banda subject-adjusted       
       sub_adjusted_fmax=sub_realign_freq+group_dfmax;
       
       if sub_adjusted_fmin < group_fmin
            sub_adjusted_fmin = group_fmin;
       end       
       
       if sub_adjusted_fmax > group_fmax
            sub_adjusted_fmax = group_fmax;
       end
       
       sel_freqs_sub=freqs >= sub_adjusted_fmin & freqs <= sub_adjusted_fmax;
      mean_centroid_sub_realign_fb=mean(freqs(sel_freqs_sub).*mean(ersp_matrix_sub_tw_fb(sel_freqs,:),2));
      median_centroid_sub_realign_fb=median(freqs(sel_freqs_sub).*mean(ersp_matrix_sub_tw_fb(sel_freqs,:),2));
       
       

    elseif strcmp(which_realign_measure,'max') 
        
       % vettore con le misure di riallineamento in tutte le frequenze nella finetra temporale
       % selezionata
       realign_freqs_vec=max(ersp_matrix_sub_tw_fb,[],2);

       % valore della misura di riallineamento più pronunciatatra tutte le frequenze
       sub_realign_freq_value=max(realign_freqs_vec);

       % seleziono la frequenza con la misura di riallineamento più pronunciata
       sel_freq_strongest_realign=find(realign_freqs_vec==sub_realign_freq_value);

       % se avessi più frequenze che raggiungono l'etremo, considero
       % arbitrariamente la prima
       sel_freq_strongest_realign=sel_freq_strongest_realign(1);

       % seleziono la frequenza con la misura di riallineamento più pronunciata
       sub_realign_freq=freqs(sel_freq_strongest_realign);              

       % seleziono la curva che corrisponde alla ERSP in funzione del tempo nella frequenza che presenta la misura di riallineamento più pronunciata
       realign_freq_curve=ersp_matrix_sub_tw_fb(sel_freq_strongest_realign,:);

       % calcolo la latenza corrispondente al raggiungimento della misura di riallineamento
       % nella frequenza con l'etremo più pronunciata
       sub_realign_freq_value_lat=times(realign_freq_curve==sub_realign_freq_value);

       % anche qui, considero arbitrariamente solo la PRIMA occorrenza
       % dell'etremo
       sub_realign_freq_value_lat=sub_realign_freq_value_lat(1);
       
       % calcolo il limite inferiore della banda subject-adjusted       
       sub_adjusted_fmin=sub_realign_freq-group_dfmin;
       
         % calcolo il limite superiore della banda subject-adjusted       
       sub_adjusted_fmax=sub_realign_freq+group_dfmax;
       
       if sub_adjusted_fmin < group_fmin
            sub_adjusted_fmin = group_fmin;
       end       
       
       if sub_adjusted_fmax > group_fmax
            sub_adjusted_fmax = group_fmax;
       end
       
       
       sel_freqs_sub=freqs >= sub_adjusted_fmin & freqs <= sub_adjusted_fmax;
      mean_centroid_sub_realign_fb=mean(freqs(sel_freqs_sub).*mean(ersp_matrix_sub_tw_fb(sel_freqs,:),2));
      median_centroid_sub_realign_fb=median(freqs(sel_freqs_sub).*mean(ersp_matrix_sub_tw_fb(sel_freqs,:),2));
      
     
       elseif strcmp(which_realign_measure,'auc') 
        
       % vettore con le misure di riallineamento in  tutte le frequenze nella finetra temporale
       % selezionata
       realign_freqs_vec=sum(abs(ersp_matrix_sub_tw_fb),2);

       % valore della misura di riallineamento più pronunciatatra tutte le frequenze
       sub_realign_freq_value=max(realign_freqs_vec);

       % seleziono la frequenza con la misura di riallineamento più pronunciata
       sel_freq_strongest_realign=find(realign_freqs_vec==sub_realign_freq_value);

       % se avessi più frequenze che raggiungono l'etremo, considero
       % arbitrariamente la prima
       sel_freq_strongest_realign=sel_freq_strongest_realign(1);

       % seleziono la frequenza con la misura di riallineamento più pronunciata
       sub_realign_freq=freqs(sel_freq_strongest_realign);              

       % seleziono la curva che corrisponde alla ERSP in funzione del tempo nella frequenza che presenta la misura di riallineamento più pronunciata
       realign_freq_curve=ersp_matrix_sub_tw_fb(sel_freq_strongest_realign,:);

       % calcolo la latenza corrispondente al raggiungimento della misura di riallineamento
       % nella frequenza con l'etremo più pronunciata
       sub_realign_freq_value_lat=times(realign_freq_curve==sub_realign_freq_value);

       % anche qui, considero arbitrariamente solo la PRIMA occorrenza
       % dell'etremo
       sub_realign_freq_value_lat=sub_realign_freq_value_lat(1);
       
       % calcolo il limite inferiore della banda subject-adjusted       
       sub_adjusted_fmin=sub_realign_freq-group_dfmin;
       
       % calcolo il limite superiore della banda subject-adjusted       
       sub_adjusted_fmax=sub_realign_freq+group_dfmax;
       
       if sub_adjusted_fmin < group_fmin
            sub_adjusted_fmin = group_fmin;
       end       
       
       if sub_adjusted_fmax > group_fmax
            sub_adjusted_fmax = group_fmax;
       end
       
       sel_freqs_sub=freqs >= sub_adjusted_fmin & freqs <= sub_adjusted_fmax;
      mean_centroid_sub_realign_fb=mean(freqs(sel_freqs_sub).*mean(ersp_matrix_sub_tw_fb(sel_freqs,:),2));
      median_centroid_sub_realign_fb=median(freqs(sel_freqs_sub).*mean(ersp_matrix_sub_tw_fb(sel_freqs,:),2));
      
       
       
       

    else
       display('ERROR: select min or max!!!!')
       return;

    end
            


end