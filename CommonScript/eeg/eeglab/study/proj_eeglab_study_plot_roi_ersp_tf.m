%% [STUDY, EEG] = proj_eeglab_study_plot_roi_ersp_tf(project, analysis_name, ersp_tf_resolution_mode, varargin)
%
% calculate and display ersp time frequency distribution for groups of scalp channels consdered as regions of interests (ROI) in 
% an EEGLAB STUDY with statistical comparisons based on the factors in the selected design.
%
% ====================================================================================================
% REQUIRED INPUT:
%
% ----------------------------------------------------------------------------------------------------
% project; a structure with the following MANDATORY fields:
% 
% * project.study.filename; the filename of the study
% * project.paths.output_epochs; the path where the study file will be
%   placed (default: the same foleder of the epoched datasets)
% * project.paths.results; the path were the results will be saved
% * project.design; the experimental design:
%   project.design(design_number) = struct(
%                                         'name', design_name, 
%                                         'factor1_name',  factor1_name,  
%                                         'factor1_levels', factor1_levels , 
%                                         'factor1_pairing', 'on', 
%                                         'factor2_name',  factor2_name,  
%                                         'factor2_levels', factor2_levels , 
%                                         'factor2_pairing', 'on'
%                                         )
% * project.postprocess.ersp.roi_list;
% * project.postprocess.ersp.roi_names;
% * project.stats.ersp.pvalue;
% * project.stats.ersp.num_permutations;
% * project.stats.eeglab.ersp.correction;
% * project.stats.eeglab.ersp.method;  
% * project.results_display.ersp.stat_time_windows_list;
% * project.results_display.ersp.display_only_significant_tf;
% * project.results_display.ersp.display_only_significant_tf_mode;
% * project.results_display.ersp.set_caxis_tf;  
% * project.stats.ersp.decimation_factor_times_tf;
% * project.stats.ersp.decimation_factor_freqs_tf;
% * project.results_display.ersp.time_range.ms;
% * project.results_display.ersp.frequency_range;
% * project.postprocess.ersp.frequency_bands_list;
% * project.postprocess.ersp.frequency_bands_names;
% * project.results_display.ersp.freq_scale;
% * project.stats.ersp.tf_resolution_mode;
% * project.stats.ersp.measure;
% * project.postprocess.ersp.design;
% * project.results_display.ersp.do_plots;
% * project.results_display.ersp.display_pmode;
%
% ----------------------------------------------------------------------------------------------------
% analysis_name
%
%
% ----------------------------------------------------------------------------------------------------
% ersp_tf_resolution_mode
%
%
%
% ====================================================================================================
% OPTIONAL INPUT:
%
% list_select_subjects  
% design_num_vec  
% roi_list  
% roi_names  
% study_ls  
% num_permutations  
% correction  
% stat_method  
%stat_time_windows_list  
% display_only_significant  
% display_only_significant_mode  
% set_caxis  
% decimation_factor_times  
% decimation_factor_freqs  
% timerange  
% freqrange  
% frequency_bands_list  
% frequency_bands_names  
% freq_scale  
% ersp_tf_resolution_mode  
%  ersp_mode  
% group_time_windows_list  
% group_time_windows_names
% display_pmode
%
% ====================================================================================================



function [STUDY, EEG] = proj_eeglab_study_plot_roi_ersp_tf(project, analysis_name, varargin)

    if nargin < 1
        help proj_eeglab_study_plot_roi_ersp_tf;
        return;
    end;
    
    study_path                  = fullfile(project.paths.output_epochs, project.study.filename);
    results_path                = project.paths.results;
    
    paired_list = cell(length(project.design), 2);
    for ds=1:length(project.design)
        paired_list{ds} = {project.design(ds).factor1_pairing, project.design(ds).factor2_pairing}; 
    end

    % VARARGIN DEFAULTS
    list_select_subjects        = {};
    design_num_vec              = [1:length(project.design)];
    
    roi_list                    = project.postprocess.ersp.roi_list;
    roi_names                   = project.postprocess.ersp.roi_names;
    
    study_ls                    = project.stats.ersp.pvalue;
    num_permutations            = project.stats.ersp.num_permutations;
    correction                  = project.stats.eeglab.ersp.correction;
    stat_method                 = project.stats.eeglab.ersp.method;  
    
   stat_time_windows_list            = project.results_display.ersp.stat_time_windows_list;
    display_only_significant    = project.results_display.ersp.display_only_significant_tf;
    display_only_significant_mode= project.results_display.ersp.display_only_significant_tf_mode;
    set_caxis                   = project.results_display.ersp.set_caxis_tf;  
    
    decimation_factor_times     = project.stats.ersp.decimation_factor_times_tf;
    decimation_factor_freqs     = project.stats.ersp.decimation_factor_freqs_tf;
    
    timerange                   = project.results_display.ersp.time_range.ms;
    freqrange                   = project.results_display.ersp.frequency_range;
    
    frequency_bands_list        = project.postprocess.ersp.frequency_bands_list;
    frequency_bands_names       = project.postprocess.ersp.frequency_bands_names;
    
    freq_scale                  = project.results_display.ersp.freq_scale;
    ersp_tf_resolution_mode     = project.stats.ersp.tf_resolution_mode;
    ersp_mode                   = project.stats.ersp.measure;
    
    group_time_windows_list     = arrange_structure(project.postprocess.ersp.design, 'group_time_windows');
    group_time_windows_names    = arrange_structure(project.postprocess.ersp.design, 'group_time_windows_names');
    
    do_plots=project.results_display.ersp.do_plots;
     num_tails                            = project.stats.ersp.num_tails;
     display_pmode=project.results_display.ersp.display_pmode;


    for par=1:2:length(varargin)
       switch varargin{par}
           case {'list_select_subjects', 'design_num_vec', 'roi_list', 'roi_names', 'study_ls', 'num_permutations', 'correction', 'stat_method', 'stat_time_windows_list', ...
                   'display_only_significant', 'display_only_significant_mode', 'set_caxis', 'decimation_factor_times', 'decimation_factor_freqs', ...
                   'timerange','freqrange','frequency_bands_list','frequency_bands_names','freq_scale', 'ersp_tf_resolution_mode', 'ersp_mode', ...
                   'group_time_windows_list','group_time_windows_names','do_plots','num_tails','stat_freq_bands_list','mask_coef','display_pmode'}
                if isempty(varargin{par+1})
                    continue;
                else
                    assign(varargin{par}, varargin{par+1});
                end
       end
    end

    
    %% =================================================================================================================================================================
    [study_path,study_name_noext,study_ext] = fileparts(study_path);  

	%% start EEGLab
	[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
	STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

	%% load the study and working with the study structure 
	[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);
    
    for design_num=design_num_vec 
        
        plot_dir=fullfile(results_path,analysis_name,[STUDY.design(design_num).name,'-ersp_tf_roi','-',ersp_tf_resolution_mode,'-',datestr(now,30)]);         
        mkdir(plot_dir);
         
        %% subjects list divided by factor levels
        list_design_subjects = eeglab_generate_subjects_list_by_factor_levels(STUDY, design_num);
    
        %% set representation to time-frequency representation
        STUDY = pop_erspparams(STUDY, 'topotime',[] ,'topofreq', [],'timerange',timerange,'freqrange',freqrange);

        %% select the study design for the analyses
        STUDY = std_selectdesign(STUDY, ALLEEG, design_num);

        ersp_tf_stat.study_des      = STUDY.design(design_num);
        ersp_tf_stat.study_des.num  = design_num;      
        ersp_tf_stat.roi_names      = roi_names;

        %% exctract names of the factores and the names of the corresponding levels for the selected design 
        name_f1                     = STUDY.design(design_num).variable(1).label;
        name_f2                     = STUDY.design(design_num).variable(2).label;

        levels_f1                   = STUDY.design(design_num).variable(1).value;
        levels_f2                   = STUDY.design(design_num).variable(2).value;
        
        switch ersp_tf_resolution_mode
        
%         if isempty(group_time_windows_list) && isempty(frequency_bands_list)

           %% time frequency representation with raw time and frequency resolution%             
            case 'continuous' % if decimation_factor_times == 1 &&  decimation_factor_freqs == 1                
               for nroi = 1:length(roi_list)
                   roi_channels=roi_list{nroi};
                   roi_name=roi_names(nroi);
                   [ersp_tf times freqs pcond, pgroup, pinter] = eeglab_study_roi_ersp_tf_simple(STUDY, ALLEEG, roi_channels, levels_f1, levels_f2,num_permutations,...
                                                                                                 stat_time_windows_list,paired_list{design_num},stat_method,...
                                                                                                  list_select_subjects,list_design_subjects,ersp_mode,num_tails,stat_freq_bands_list,mask_coef);
                    
                                                                                              
                    [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);                                                                       
                                                                                              
                    if (strcmp(do_plots,'on'))                                                                                                  
                        eeglab_study_roi_ersp_tf_graph(STUDY, design_num, roi_names{nroi}, name_f1, name_f2, levels_f1,levels_f2, ersp_tf, times, freqs, pcond_corr, pgroup_corr, pinter_corr, ...
                                                        set_caxis,study_ls,plot_dir,freq_scale,...
                                                        display_only_significant,display_only_significant_mode,ersp_mode, group_time_windows_list,frequency_bands_list,display_pmode)
                    end
                    ersp_tf_stat.data(nroi).roi_name=roi_name;
                    ersp_tf_stat.data(nroi).roi_channels=roi_channels;
                    ersp_tf_stat.data(nroi).ersp_tf=ersp_tf;                
                    ersp_tf_stat.data(nroi).pcond=pcond;
                    ersp_tf_stat.data(nroi).pgroup=pgroup;
                    ersp_tf_stat.data(nroi).pinter=pinter;
               end
               
            %% time frequency representation with lowered time resolution and raw frequency resolution
            case 'decimate_times'  % if decimation_factor_times > 1 &&  decimation_factor_freqs == 1                              
                for nroi = 1:length(roi_names)
                    roi_channels=roi_list{nroi};
                    roi_name=roi_names(nroi);
                    [ersp_tf times freqs pcond, pgroup, pinter] = eeglab_study_roi_ersp_tf_decimate_times(STUDY, ALLEEG, roi_channels, levels_f1, levels_f2,num_permutations,...
                                                                                                         stat_time_windows_list,paired_list{design_num},stat_method,...
                                                                                                          decimation_factor_times,...
                                                                                                          list_select_subjects,list_design_subjects,ersp_mode);
                    [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);     
                                                                                                      
                     if (strcmp(do_plots,'on'))                                                                             
                         eeglab_study_roi_ersp_tf_graph(STUDY, design_num, roi_names{nroi}, name_f1, name_f2, levels_f1,levels_f2, ersp_tf, times, freqs, pcond_corr, pgroup_corr, pinter_corr, ...
                                                        set_caxis,study_ls,plot_dir,freq_scale,...
                                                        display_only_significant,display_only_significant_mode,ersp_mode,display_pmode)
                     end
                    ersp_tf_stat.data(nroi).roi_name=roi_name;               
                    ersp_tf_stat.data(nroi).roi_channels=roi_channels;                
                    ersp_tf_stat.data(nroi).ersp_tf=ersp_tf;
                    ersp_tf_stat.data(nroi).pcond=pcond;
                    ersp_tf_stat.data(nroi).pgroup=pgroup;
                    ersp_tf_stat.data(nroi).pinter=pinter;
                end             
        
                %% time frequency representation with raw time resolution and lowered frequency resolution
            
            case 'decimate_freqs' % if decimation_factor_times == 1 &&  decimation_factor_freqs > 1           
               for nroi = 1:length(roi_names)
                    roi_channels=roi_list{nroi};
                    roi_name=roi_names(nroi);
                    [ersp_tf times freqs pcond, pgroup, pinter] = eeglab_study_roi_ersp_tf_decimate_freqs(STUDY, ALLEEG, roi_channels, levels_f1, levels_f2,num_permutations,...
                                                                                                         stat_time_windows_list,paired_list{design_num},stat_method,...
                                                                                                          decimation_factor_freqs,...
                                                                                                          list_select_subjects,list_design_subjects,ersp_mode);
                                                                                                      
                                                                                                      
                   [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);     
                   
                     if (strcmp(do_plots,'on'))                                                                             
                         eeglab_study_roi_ersp_tf_graph(STUDY, design_num, roi_names{nroi}, name_f1, name_f2, levels_f1,levels_f2, ersp_tf, times, freqs, pcond_corr, pgroup_corr, pinter_corr, ...
                                                        set_caxis,study_ls,plot_dir,freq_scale,...

                                                        display_only_significant,display_only_significant_mode,ersp_mode, group_time_windows_list,frequency_bands_list,display_pmode)
                     end                            
                    ersp_tf_stat.data(nroi).roi_name=roi_name;
                    ersp_tf_stat.data(nroi).roi_channels=roi_channels;                
                    ersp_tf_stat.data(nroi).ersp_tf=ersp_tf;
                    ersp_tf_stat.data(nroi).pcond=pcond;
                    ersp_tf_stat.data(nroi).pgroup=pgroup;
                    ersp_tf_stat.data(nroi).pinter=pinter;
               end
               
            %% time frequency representation with lowered time resolution and lowered frequency resolution   
            case 'decimate_times_freqs' %if decimation_factor_times > 1 &&  decimation_factor_freqs > 1
               for nroi = 1:length(roi_names)
                    roi_channels=roi_list{nroi};
                    roi_name=roi_names(nroi);
                    [STUDY ersp_tf times freqs pcond, pgroup, pinter] = eeglab_study_roi_ersp_tf_decimate_tf(STUDY, ALLEEG, roi_channels, levels_f1, levels_f2,num_permutations,...
                                                                                                         stat_time_windows_list,paired_list{design_num},stat_method,...
                                                                                                          decimation_factor_times,decimation_factor_freqs,...
                                                                                                          list_select_subjects,list_design_subjects,ersp_mode);
                                                                                                      
 [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);                                                                                                           
                                                                                                      
                     if (strcmp(do_plots,'on'))                                                                             
                         eeglab_study_roi_ersp_tf_graph(STUDY, design_num, roi_names{nroi}, name_f1, name_f2, levels_f1,levels_f2, ersp_tf, times, freqs, pcond_corr, pgroup_corr, pinter_corr, ...
                                                        set_caxis,study_ls,correction,plot_dir,freq_scale,...
                                                        display_only_significant,display_only_significant_mode,ersp_mode,display_pmode)
                     end                                                                            
                    ersp_tf_stat.data(nroi).roi_name=roi_name;
                    ersp_tf_stat.data(nroi).roi_channels=roi_channels;
                    ersp_tf_stat.data(nroi).ersp_tf=ersp_tf;
                    ersp_tf_stat.data(nroi).pcond=pcond;
                    ersp_tf_stat.data(nroi).pgroup=pgroup;
                    ersp_tf_stat.data(nroi).pinter=pinter;
               end
               
            %% time frequency representation with free grouping in time (using time
            % windows) and in frequency (using frequency bands).  both
            % time windows can frequency bands can overlap (are automatically
            % sorted)
            case 'tw_fb' % if ~isempty(group_time_windows_list) && ~isempty(frequency_bands_list) && decimation_factor_times == 1 &&  decimation_factor_freqs == 1     
                
                for nroi = 1:length(roi_names)
                   roi_channels=roi_list{nroi};
                   roi_name=roi_names(nroi);
                   [STUDY ersp_tf times freqs pcond, pgroup, pinter]= eeglab_study_roi_ersp_tf_tw_fb(STUDY, ALLEEG,  roi_channels, levels_f1, levels_f2,...
                                                                                                    group_time_windows_list{design_num},frequency_bands_list,...
                                                                                                    num_permutations,paired_list{design_num},stat_method,...
                                                                                                    list_select_subjects,list_design_subjects,ersp_mode);

                   [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);     
 
 
                   if (strcmp(do_plots,'on'))                                                                                
                       eeglab_study_roi_ersp_tf_tw_fb_graph(STUDY, design_num, roi_names{nroi}, name_f1, name_f2, levels_f1,levels_f2, ersp_tf, times, freqs, pcond_corr, pgroup_corr, pinter_corr, ...
                                                            set_caxis,study_ls, group_time_windows_names{design_num}, frequency_bands_names,plot_dir,freq_scale,...
                                                            display_only_significant,display_only_significant_mode,ersp_mode,display_pmode)
                   end
                   ersp_tf_stat.data(nroi).roiname=roi_names{nroi};
                   ersp_tf_stat.data(nroi).ersp_tf=ersp_tf;          
                   ersp_tf_stat.data(nroi).pcond=pcond;
                   ersp_tf_stat.data(nroi).pgroup=pgroup;
                   ersp_tf_stat.data(nroi).pinter=pinter;
                end  
             
            otherwise
                disp(['variable ersp_tf_resolution_mode (' ersp_tf_resolution_mode ') was not properly defined']);
                return
        end

        ersp_tf_stat.times=times;
        ersp_tf_stat.freqs=freqs;
        ersp_tf_stat.selected_time_windows_list=group_time_windows_list;
        ersp_tf_stat.selected_frequency_bands_list=frequency_bands_list;   
        ersp_tf_stat.selected_time_windows_names=group_time_windows_names;


        save(fullfile(plot_dir,'ersp_tf-stat.mat'),'ersp_tf_stat');    
        
    end
end
