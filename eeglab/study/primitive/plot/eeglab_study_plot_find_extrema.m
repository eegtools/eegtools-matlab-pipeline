function output = eeglab_study_plot_find_extrema(input)
% function output = eeglab_study_plot_find_extrema(input)
%
% % general parameters
% times                                                                      = input.times;
% which_method_find_extrema                                                  = input.which_method_find_extrema;
% design_num                                                                 = input.design_num;
% roi_name                                                                   = input.roi_name;
% 
% % parameters of the low level functions
% erp_curve_roi                                                              = input.curve;
% levels_f1                                                                  = input.levels_f1;
% levels_f2                                                                  = input.levels_f2;
% group_time_windows_list_design                                             = input.group_time_windows_list_design;
% subject_time_windows_list                                                  = input.subject_time_windows_list;
% which_extrema_design_roi                                                   = input.which_extrema_design_roi;
% sel_extrema                                                                = input.sel_extrema;
%
%
% output.curve{nf1,nf2}                     % (nsubj) MEAN per ogni soggetto nella finestra
% output.curve_tw{nf1,nf2}                  % (nsubj x ntp) serie temporale per ogni soggetto nella finestra
%
% output.extr{nf1,nf2}                      % (nsubj) EXTR per ogni soggetto nella finestra  
%
% output.extr_mean{nf1,nf2}                 % (1) MEAN di ampiezza nella finestra
% output.extr_sd{nf1,nf2}                   % (1) SD di ampiezza nella finestra
% output.extr_median{nf1,nf2}               % (1) MEDIAN di ampiezza nella finestra
% output.extr_range{nf1,nf2}                % (2) MAX e MIN delle ampiezze tra tutti i soggetti
%      
% output.extr_lat{nf1,nf2}                  % (nsubj) EXTR LATENCY (in funzione pero del criterio di occorrenza definito nel project config....e.g la prima occorrenza o la media delle occorrenze...)
% output.extr_lat_mean{nf1,nf2}             % (1) MEAN di latenza nella finestra
% output.extr_lat_sd{nf1,nf2}               % (1) SD di latenza nella finestra
% output.extr_lat_median{nf1,nf2}           % (1) MEDIAN di latenza nella finestra
% output.extr_lat_range{nf1,nf2}            % (2) MAX e MIN delle latenza tra tutti i soggetti
%
% output.extr_lat_vec{nf1,nf2}              % (nsubj x n) vettore con tutte le occorrenze dell'estremo per ogni soggetto  
%
% output.extr_pattern_subject{nf1,nf2}      % (nsubj x ntp), inizializzata a NaN, per ogni soggetto contiene i valori della serie temporale nelle posizioni riallineate
% output.extr_pattern_lat_range{nf1,nf2}    %  (nsubj x 2), inizio e fine della finestra riallineata





% general parameters
times                                                                      = input.times;
which_method_find_extrema                                                  = input.which_method_find_extrema;
design_num                                                                 = input.design_num;
roi_name                                                                   = input.roi_name;

% parameters of the low level functions
erp_curve_roi                                                              = input.curve;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
group_time_windows_list_design                                             = input.group_time_windows_list_design;
subject_time_windows_list                                                  = input.subject_time_windows_list;
which_extrema_design_roi                                                   = input.which_extrema_design_roi;
sel_extrema                                                                = input.sel_extrema;


if ~eeglab_check_tw_compliancy(group_time_windows_list_design, times)
    disp('Failed: eeglab_check_tw_compliancy(group_time_windows_list_design, times)')
    return;
end


if isempty(which_extrema_design_roi)
    disp(['which_extrema_design_roi of design num:' num2str(design_num) ' and roi ' roi_name ' is empty']);
    return;
end

switch which_method_find_extrema
    
    case 'group_noalign'
        
       input_find_extrema.curve                                            = erp_curve_roi;               
       input_find_extrema.levels_f1                                        = levels_f1;
       input_find_extrema.levels_f2                                        = levels_f2;
       input_find_extrema.group_time_windows_list_design                   = group_time_windows_list_design;
       input_find_extrema.times                                            = times;
       input_find_extrema.which_extrema_design_roi                         = which_extrema_design_roi;
       input_find_extrema.sel_extrema                                      = sel_extrema;
       
       output = eeglab_study_plot_find_extrema_avg(input_find_extrema);
    
    case 'group_align'
        disp('ERROR: still not implemented!!!');       
    
    case 'individual_noalign'
        
       input_find_extrema.curve                                            = erp_curve_roi;               
       input_find_extrema.levels_f1                                        = levels_f1;
       input_find_extrema.levels_f2                                        = levels_f2;
       input_find_extrema.group_time_windows_list_design                   = group_time_windows_list_design;
       input_find_extrema.times                                            = times;
       input_find_extrema.which_extrema_design_roi                         = which_extrema_design_roi;
       input_find_extrema.sel_extrema                                      = sel_extrema;
     
       output = eeglab_study_plot_find_extrema_gru(input_find_extrema);
       
    case 'individual_align'        
        
       input_find_extrema.curve                                            = erp_curve_roi;               
       input_find_extrema.levels_f1                                        = levels_f1;
       input_find_extrema.levels_f2                                        = levels_f2;
       input_find_extrema.group_time_windows_list_design                   = group_time_windows_list_design;
       input_find_extrema.times                                            = times;
       input_find_extrema.which_extrema_design_roi                         = which_extrema_design_roi;
       input_find_extrema.sel_extrema                                      = sel_extrema;
       
       % only in this case we need to set the individual time window
       input_find_extrema.subject_time_windows_list_design                 = subject_time_windows_list{design_num};
       
       output = eeglab_study_plot_find_extrema_single(input_find_extrema);

end

end