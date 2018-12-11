%% [STUDY, EEG] = proj_eeglab_study_plot_roi_erp_curve(project, analysis_name, mode, varargin)
%
% calculate and display erp time series for groups of scalp channels consdered as regions of interests (ROI) in
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
% * project.postprocess.erp.roi_list;
% * project.postprocess.erp.roi_names;
% * project.stats.erp.pvalue;
% * project.stats.erp.num_permutations;
% * project.stats.eeglab.erp.correction;
% * project.stats.eeglab.erp.method;
% * project.results_display.erp.time_smoothing;
% * project.results_display.erp.masked_times_max;
% * project.results_display.erp.display_only_significant_curve;
% * project.results_display.erp.compact_plots;
% * project.results_display.erp.compact_h0;
% * project.results_display.erp.compact_v0;
% * project.results_display.erp.compact_sem;
% * project.results_display.erp.compact_stats;
% * project.results_display.erp.single_subjects;
% * project.results_display.erp.compact_display_xlim;
% * project.results_display.erp.compact_display_ylim;
% * project.postprocess.erp.design
%
% ----------------------------------------------------------------------------------------------------
% analysis_name
%
%
% ----------------------------------------------------------------------------------------------------
% mode
%
%
%
% ====================================================================================================
% OPTIONAL INPUT:
%
% design_num_vec
% analysis_name
% roi_list
% roi_names
% study_ls
% num_permutations
% correction
% stat_method
% filter
% masked_times_max
% display_only_significant
% display_compact_plots
% compact_display_h0
% compact_display_v0
% compact_display_sem
% compact_display_stats
% display_single_subjects
% compact_display_xlim
% compact_display_ylim
% group_time_windows_list
% subject_time_windows_list
% group_time_windows_names
% sel_extrema
% list_select_subjects
% do_plots
% ====================================================================================================

function [STUDY, EEG] = proj_eeglab_study_erp_define_roi_tw_datadriven(project, analysis_name,  varargin)

if nargin < 1
    help proj_eeglab_study_plot_roi_erp_curve;
    return;
end;

study_path                  = fullfile(project.paths.output_epochs, project.study.filename);
results_path                = project.paths.results;


% data_driven_path = fullfile(results_path,'data_driven','erp');
% if not(exist(data_driven_path))
%     mkdir(data_driven_path)
% end

paired_list = cell(length(project.design), 2);
for ds=1:length(project.design)
    paired_list{ds} = {project.design(ds).factor1_pairing, project.design(ds).factor2_pairing};
end

% VARARGIN DEFAULTS
list_select_subjects        = {};
design_num_vec              = [1:length(project.design)];

% roi_list                    = project.postprocess.erp.roi_list;
% roi_names                   = project.postprocess.erp.roi_names;

study_ls                    = project.stats.erp.pvalue;
% num_permutations            = project.stats.erp.num_permutations;
correction                  = project.stats.eeglab.erp.correction;
stat_method                 = project.stats.eeglab.erp.method;

% filter                      = project.results_display.erp.time_smoothing;
% masked_times_max            = project.results_display.erp.masked_times_max;
% display_only_significant    = project.results_display.erp.display_only_significant_curve;
% display_compact_plots       = project.results_display.erp.compact_plots;
% compact_display_h0          = project.results_display.erp.compact_h0;
% compact_display_v0          = project.results_display.erp.compact_v0;
% compact_display_sem         = project.results_display.erp.compact_sem;
% compact_display_stats       = project.results_display.erp.compact_stats;
% display_single_subjects     = project.results_display.erp.single_subjects;
xlim        = project.results_display.erp.compact_display_xlim;
amplim        = project.results_display.erp.compact_display_ylim;


% group_time_windows_list     = arrange_structure(project.postprocess.erp.design, 'group_time_windows');
% subject_time_windows_list   = arrange_structure(project.postprocess.erp.design, 'subject_time_windows');
% group_time_windows_names    = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');

do_plots                    = project.results_display.erp.do_plots;


recompute_precompute                   = project.postprocess.datadriven.erp.recompute_precompute;

select_tw_des_ga_plot=project.postprocess.datadriven.erp.ga.select_tw_des_plot;
recompute_ga                = project.postprocess.datadriven.erp.ga.recompute;
levels_f1_ga             = project.postprocess.datadriven.erp.ga.levels_f1;
levels_f2_ga             = project.postprocess.datadriven.erp.ga.levels_f2;

select_tw_des_gf_plot=project.postprocess.datadriven.erp.gf.select_tw_des_plot;
recompute_gf                = project.postprocess.datadriven.erp.gf.recompute;
levels_f1_gf             = project.postprocess.datadriven.erp.gf.levels_f1;
levels_f2_gf             = project.postprocess.datadriven.erp.gf.levels_f2;

select_tw_des_stat = project.postprocess.datadriven.erp.select_tw_des_stat;

% % ANALYSIS MODALITIES
% if strcmp(mode.peak_type, 'group') && strcmp(mode.align, 'off')
%     which_method_find_extrema = 'group_noalign';
% elseif strcmp(mode.peak_type, 'group') && strcmp(mode.align, 'on')
%     which_method_find_extrema = 'group_align';
% elseif strcmp(mode.peak_type, 'individual') && strcmp(mode.align, 'off')
%     which_method_find_extrema = 'individual_noalign';
% elseif strcmp(mode.peak_type, 'individual') && strcmp(mode.align, 'on')
%     which_method_find_extrema = 'individual_align';
% elseif strcmp(mode.peak_type, 'off')
%     which_method_find_extrema = 'continuous';
% end

% tw_stat_estimator           = mode.tw_stat_estimator;
% time_resolution_mode        = mode.time_resolution_mode;
% sel_extrema                 = project.postprocess.erp.sel_extrema;

for par=1:2:length(varargin)
    switch varargin{par}
        case {'design_num_vec', ...
                'analysis_name', ...
                'roi_list', ...
                'roi_names', ...
                'study_ls', ...
                'num_permutations', ...
                'correction', ...
                'stat_method', ...
                'filter', ...
                'masked_times_max', ...
                'display_only_significant', ...
                'display_compact_plots', ...
                'compact_display_h0', ...
                'compact_display_v0', ...
                'compact_display_sem', ...
                'compact_display_stats', ...
                'display_single_subjects', ...
                'compact_display_xlim', ...
                'compact_display_ylim', ...
                'group_time_windows_list', ...
                'subject_time_windows_list', ...
                'group_time_windows_names', ...
                'sel_extrema', ...
                'list_select_subjects', ...
                'do_plots',...
                'recompute_precompute',...
                'recompute_grand_average',...
                'recompute_grouping_factor',...
                'levels_f1_grand_average_dd',...
                'levels_f2_grand_average_dd'...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

dfcond=[];
dfgroup=[];
dfinter=[];


%=================================================================================================================================================================
%=================================================================================================================================================================
%=================================================================================================================================================================
%=================================================================================================================================================================
%=================================================================================================================================================================
[study_path,study_name_noext,study_ext] = fileparts(study_path);

% start EEGLab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

% load the study and working with the study structure
[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);

chanlocs = eeg_mergelocs(ALLEEG.chanlocs);
allch0         = {chanlocs.labels}; % comprende eventuali poligrafici

allch = allch0(project.eegdata.eeg_channels_list);


for design_num=design_num_vec
    
    fprintf('design %d\n',design_num);
    
    
    % select the study design for the analyses
    STUDY                              = std_selectdesign(STUDY, ALLEEG, design_num);
    
    erp_curve_roi_stat.study_des       = STUDY.design(design_num);
    erp_curve_roi_stat.study_des.num   = design_num;
    %     erp_curve_roi_stat.roi_names       = roi_names;
    
    name_f1                            = STUDY.design(design_num).variable(1).label;
    name_f2                            = STUDY.design(design_num).variable(2).label;
    
    levels_f1                          = STUDY.design(design_num).variable(1).value;
    levels_f2                          = STUDY.design(design_num).variable(2).value;
    
    name_gf                    = project.design(design_num).grouping_factor;
    name_cf                    = project.design(design_num).comparing_factor;
    
    % lista dei soggetti suddivisi per fattori
    list_design_subjects               = eeglab_generate_subjects_list_by_factor_levels(project,STUDY, design_num);
    
    
    
    
    
    if isempty(project.postprocess.datadriven.ersp.precompute_folder) || not(exist(project.postprocess.datadriven.ersp.precompute_folder))
        
        str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
        plot_dir                           = fullfile(results_path,analysis_name,[STUDY.design(design_num).name,'-datadriven_erp','-',str]);
        mkdir(plot_dir);
        
    else
        plot_dir = project.postprocess.datadriven.ersp.precompute_folder;
    end
    
    data_driven_path = plot_dir;
    
    
    STUDY = pop_erpparams(STUDY, 'topotime',[] ,'plotgroups','apart' ,'plotconditions','apart','averagechan','off','method', stat_method);
    
    precompute_file = fullfile(results_path ,['precompute_erp_allch_', char(STUDY.design(design_num).name), '.mat']);
    exist_precompute = exist(precompute_file);
    
    if (strcmp(recompute_precompute, 'on')  || not(exist_precompute))
        
        % erp_curve_allch cell array of dimension tlf1 x tlf2 , each cell of
        % dimension times x channels x subjects
        [STUDY, erp_curve_allch, times]=std_erpplot(STUDY,ALLEEG,'channels',allch,'noplot','on');
        
        out_precompute.erp_curve_allch = erp_curve_allch;
        out_precompute.times = times;
        
        
        save(precompute_file,'out_precompute')
    else
        load(precompute_file);
        erp_curve_allch =  out_precompute.erp_curve_allch;
        times = out_precompute.times;
        
    end
    
    erp_curve_allch_collsub = {};
    
    for nf1=1:length(levels_f1)
        for nf2=1:length(levels_f2)
            if ~isempty(list_select_subjects)
                vec_select_subjects=ismember(list_design_subjects{nf1,nf2},list_select_subjects);
                if ~sum(vec_select_subjects)
                    disp('Error: the selected subjects are not represented in the selected design')
                    return;
                end
                %                     erp_curve_roi{nf1,nf2}=erp_curve_roi{nf1,nf2}(:,vec_select_subjects);
                erp_curve_allch{nf1,nf2}=erp_curve_allch{nf1,nf2}(:,1:length(allch),vec_select_subjects);
                erp_curve_allch_collsub{nf1,nf2} = mean(erp_curve_allch{nf1,nf2},3)';
                list_design_subjects{nf1,nf2}=list_design_subjects{nf1,nf2}(vec_select_subjects);
            end
        end
    end
    
    
    
    %% compute grand average file
    ga_mat_dir = fullfile(data_driven_path,'ga','mat');
    ga_file = fullfile(ga_mat_dir,['ga_erp_allch_', char(STUDY.design(design_num).name), '.mat']);
    exist_grand_average = exist(ga_file);
    
    if (strcmp(recompute_ga, 'on')  || not(exist_grand_average))
        
        if not(exist(ga_mat_dir))
            mkdir(ga_mat_dir)
        end
        
        sel_levels_f1_ga_dd = ismember(levels_f1,levels_f1_ga{design_num});
        sel_levels_f2_ga_dd = ismember(levels_f2,levels_f2_ga{design_num});
        
        erp_curve_allch_ga = erp_curve_allch(sel_levels_f1_ga_dd,sel_levels_f2_ga_dd);
        
        %         medie per ogni livello di gf e cf (grouping e comparing factor)
        %         in cui i soggetti sono collassati
        
        
        erp_curve_allch_collsub_grand_average = erp_curve_allch_collsub(sel_levels_f1_ga_dd,sel_levels_f2_ga_dd);
        
        
        
        %% calcolo medione
        
        disp('compute grand average');
        
                dim_erp_curve_allch = size(erp_curve_allch_ga{1});
        %         collapsing_dimension = dim_erp_curve_allch+1;
        %
        %         % collapse the cells into a matrix, along an additional dimesion
        %
        %         mat_collapsed_cell = cat(collapsing_dimension, erp_curve_allch_ga{:});
        %
        %         % compute the average along dim_current_cells+1,
        %         mean_collapsed_cell_single_sub = mean(mat_collapsed_cell,collapsing_dimension);
        %
        %
        %
        %
        %
        %         mean_collapsed_cell_all_sub = {mean(mean_collapsed_cell_single_sub,3)'};
        
        
        num_current_cells = numel(erp_curve_allch_ga);
        
        sum_collapsed_cell_all_sub = zeros(dim_erp_curve_allch(1:2));
        
        
        for nc = 1:num_current_cells
            sum_collapsed_cell_all_sub = sum_collapsed_cell_all_sub + squeeze(mean(erp_curve_allch_ga{nc},3));
        end
        
        mean_collapsed_cell_all_sub = {sum_collapsed_cell_all_sub'/num_current_cells};
        
        
        
        
        input_dd.curve         = mean_collapsed_cell_all_sub;
        input_dd.base_tw       = [project.epoching.bc_st.ms project.epoching.bc_end.ms];
        input_dd.times        = times;
        input_dd.levels_gf                                                     = {'grand_average'};
        input_dd.min_duration                                                               = project.postprocess.erp.design(design_num).min_duration ;                      % ha senso settare una diversa lunghezza minima a seconda della banda o del tipo del sgnale?
        input_dd.pvalue                                                                     = study_ls;                            % default will be 0.05
        input_dd.correction                                                                 = correction;                        % string. correction for multiple comparisons 'none'| 'fdr' | 'holms' | 'bonferoni'
        input_dd.select_tw_des_stat = select_tw_des_stat;
        
        output_dd_ga = eeglab_study_curve_data_driven_onset_offset(input_dd);
        
        output_ga.mean_collapsed_cell_all_sub = mean_collapsed_cell_all_sub;
        output_ga.times = times;
        output_ga.allch = allch;
        output_ga.output_dd_ga = output_dd_ga;
        
        
        
        
        save(ga_file,'output_ga')
    else
        
        load(ga_file);
        mean_collapsed_cell_all_sub = output_ga.mean_collapsed_cell_all_sub;
        times =         output_ga.times;
        allch = output_ga.allch ;
        output_dd_ga = output_ga.output_dd_ga;
    end
    
    
    %% project time window on each condtion and extract parameters
    
    % cell array a cui applicare la maschera delle p: ha selezionato i
    % soggetti e i livelli dei fattori da considerare MA non ha fatto
    % nessuna media
    %     erp_curve_allch_ga
    
    
    %  struttura in cui ho le tw per ogni canale
    %     output_dd_grand_average
    
    
    
    %% plot grand average
    if strcmp(do_plots,'on')
        disp('plot grand average');
        
        plot_dir_ga = fullfile(data_driven_path,'ga','plot');
        mkdir(plot_dir_ga);
        
        input_ga.erp_grand_average = mean_collapsed_cell_all_sub{:};
        input_ga.p_grand_average  = output_dd_ga.sigcell_pruned_gf{:};
        input_ga.erp_avgsub = erp_curve_allch_collsub_grand_average;
        input_ga.pvalue = study_ls;
        input_ga.allch = allch;
        input_ga.xlim = xlim;
        input_ga.amplim = amplim;
        input_ga.times = times;
        input_ga.levels_f1 = levels_f1(sel_levels_f1_ga_dd);
        input_ga.levels_f2 = levels_f2 (sel_levels_f2_ga_dd);
        input_ga.plot_dir = plot_dir_ga;
        input_ga.select_tw_des=select_tw_des_ga_plot{design_num};
        
        
        eeglab_study_allch_erp_time_dd_grand_average_graph(input_ga);
    end
    
    
    %% applicazione maschera a ciascun livello di ogni fattore usando le tw estratte raggruppando per gf
    
    %
    %            cell array a cui applicare la maschera delle p: ha selezionato i
    %     soggetti e i livelli dei fattori da considerare MA non ha fatto
    %     nessuna media
    input_mask.curve_allch = erp_curve_allch;
    %
    %
    %      struttura in cui ho le tw per ogni canale
    input_mask.output_dd_ga = output_dd_ga;
    input_mask.name_f1 =   name_f1;
    input_mask.name_f2 =   name_f2;
    input_mask.levels_f1 =   levels_f1;
    input_mask.levels_f2 =   levels_f2;
    input_mask.allch     =   allch;
    input_mask.times    =  times;
    %         input_mask.levels_gf  = levels_gf;
    %         input_mask.name_gf = name_gf;
    %         input_mask.levels_cf = levels_cf;
    %         input_mask.name_cf = name_cf;
    
    
    disp('mask grand average')
    mask_cell_p_ga_file = fullfile(data_driven_path,'ga','mat',['mask_cell_p_ga_', char(STUDY.design(design_num).name), '.mat']);
    
    output_dd_eeglab_mask_cell_p_ga= eeglab_mask_cell_p_ga(input_mask);
    save(mask_cell_p_ga_file,'output_dd_eeglab_mask_cell_p_ga')
    
    
    
    %         output_mask_cell_p_gf.cell_gf = cell_gf;
    %         output_mask_cell_p_ga.times = times;
    output_mask_cell_p_ga.output_dd_eeglab_mask_cell_p_gf = output_dd_eeglab_mask_cell_p_ga;
    output_mask_cell_p_ga.allch = allch;
    output_mask_cell_p_ga.list_design_subjects = list_design_subjects;
    output_mask_cell_p_ga.levels_f1 = levels_f1;
    output_mask_cell_p_ga.levels_f2 = levels_f2;
    output_mask_cell_p_ga.name_f1 = name_f1;
    output_mask_cell_p_ga.name_f2 = name_f2;
    %         output_mask_cell_p_gf.name_gf = name_gf;
    %         output_mask_cell_p_gf.name_cf = name_cf;
    
    
    
    disp('text export grand average')
    
    out_dir = fullfile(data_driven_path,'ga','text');
    if not(exist(out_dir))
        mkdir(out_dir);
    end
    [dataexpcols, dataexp] = text_export_allch_erp_time_dd_ga(out_dir,output_mask_cell_p_ga);
    
    
    clear dataexpcols dataexp output_mask_cell_p_ga
    
    %% export grand average
    %input_ga_exp.p_grand_average  = output_dd_grand_average.sigcell_pruned_gf{:};
    %input_ga_exp.erp_avgsub = erp_curve_allch_collsub_grand_average;
    %input_ga_exp.levels_f1 = levels_f1(sel_levels_f1_ga_dd);
    %input_ga_exp.levels_f2 = levels_f2 (sel_levels_f2_ga_dd);
    %input_ga_exp.erp_curve_allch = erp_curve_allch;
    
    %text_export_allch_erp_time_dd_grand_average(input_ga_exp);
    
    
    %% compute grouping factor
    if (isempty(name_gf) || isempty(name_cf))
        disp('missing grouping or comparing factor: calculate only significant deflections based on the grand average!!!')
    else
        gf_mat_dir = fullfile(data_driven_path,'gf','mat');
        gf_file = fullfile(gf_mat_dir,['gf_erp_allch_', char(STUDY.design(design_num).name), '.mat']);
        exist_grouping_factor = exist(gf_file);
        
        if (strcmp(recompute_gf, 'on')  || not(exist_grouping_factor))
            
            if not(exist(gf_mat_dir))
                mkdir(gf_mat_dir)
            end
            
            
            % we have 2 kind of facors: 1 grouping factor and 1 comparing factor.
            % all levels of comparing factors will be averaged within each level of
            % grouping factor, therefore we can get an estiation of rois and tw
            % which is UNBIASED with respect to comparing factor: levels of
            % comparing factor will be compared considering the umbiased roi and
            % tw.
            
            
            if strcmp(name_gf, name_f1)
                levels_gf = levels_f1;
                name_gf   = name_f1;
                levels_cf = levels_f2;
                name_cf   = name_f2;
                
            else
                levels_gf = levels_f2;
                name_gf   = name_f2;
                levels_cf = levels_f1;
                name_cf   = name_f1;
            end
            tl_gf = length(levels_gf);
            cell_gf = {};
            
            %     for each level of grouping factor
            for nl_gf = 1:tl_gf
                %                 disp(sprintf('compute grouping factor level %d / %d',nl_gf,tl_gf));
                
                %     each cell grouped factor = mean of all levels of comparing factor
                if strcmp(name_gf, name_f1)
                    % select all the cells (levels) of the comparing factor corresponding to the current level (nl_gf) of grouping factor
                    current_cells = erp_curve_allch(nl_gf,:);
                else
                    current_cells = erp_curve_allch(:,nl_gf);
                end
                %                 collapsing_dimension = dim_current_cells+1;
                
                % collapse the cells into a matrix, along an additional dimesion
                % corresponding to the cells (levels) of the comparing factor
                
                %                 mat_collapsed_cell = cat(collapsing_dimension, current_cells{:});
                
                %                 % compute the average along dim_current_cells+1, i.e. collapse cells (levels) of the comparing factor, but preserving single subjects. i.e. the dimensions will be channels x times x subjects
                %                 mean_collapsed_cell_single_sub = mean(mat_collapsed_cell,collapsing_dimension);
                %
                %                 % compute the average along third dimension, i.e. subjects, will result in
                %                 % a matrix channels x times
                %
                %                 mean_collapsed_cell_all_sub = mean(mean_collapsed_cell_single_sub,3);
                               
                dim_erp_curve_allch = size(erp_curve_allch_ga{1});

                
                num_current_cells = length(current_cells);                
        
                sum_collapsed_cell_all_sub = zeros(dim_erp_curve_allch(1:2));
                
                
                for nc = 1:num_current_cells
                    sum_collapsed_cell_all_sub = sum_collapsed_cell_all_sub + mean(current_cells{nc},3);
                end
                
                mean_collapsed_cell_all_sub = sum_collapsed_cell_all_sub/num_current_cells;
                
                %         put the matrix into the cell corrsponding to the nl_gf level of
                %         grouping factor
                
                cell_gf{nl_gf} = mean_collapsed_cell_all_sub';
            end
            
            disp('compute grouping factor');
            
            input_dd.curve         = cell_gf;
            input_dd.base_tw       = [project.epoching.bc_st.ms project.epoching.bc_end.ms];
            input_dd.times        = times;
            input_dd.levels_gf                                                     = levels_gf;
            input_dd.min_duration                                                               = project.postprocess.erp.design(design_num).min_duration ;                      % ha senso settare una diversa lunghezza minima a seconda della banda o del tipo del sgnale?
            input_dd.pvalue                                                                     = study_ls;                            % default will be 0.05
            input_dd.correction                                                                 = correction;                        % string. correction for multiple comparisons 'none'| 'fdr' | 'holms' | 'bonferoni'
            input_dd.select_tw_des_stat = select_tw_des_stat;
            
            output_dd_gf = eeglab_study_curve_data_driven_onset_offset(input_dd);
            
            output_data_driven.cell_gf = cell_gf;
            output_data_driven.times = times;
            output_data_driven.output_dd_gf = output_dd_gf;
            output_data_driven.allch = allch;
            
            
            
            save(gf_file,'output_data_driven')
        else
            
            load(gf_file);
            
            
            cell_gf= output_data_driven.cell_gf;
            times=output_data_driven.times;
            output_dd_gf=output_data_driven.output_dd_gf;
            allch=output_data_driven.allch ;
            
        end
        
        
        %% plot grouping_factor
        
        
        if strcmp(do_plots,'on')
            disp('plot grouping factor')
            
            plot_dir_gf = fullfile(data_driven_path,'gf','plot');
            mkdir(plot_dir_gf);
            
            %         input_gf.erp_grand_average = mean_collapsed_cell_all_sub{:};
            input_gf.p_gf  = output_dd_gf.sigcell_pruned_gf;
            input_gf.erp_avgsub = erp_curve_allch_collsub;
            input_gf.erp_gf    = cell_gf;
            
            input_gf.pvalue = study_ls;
            input_gf.allch = allch;
            input_gf.xlim = xlim;
            input_gf.amplim = amplim;
            input_gf.times = times;
            input_gf.levels_f1 = levels_f1;
            input_gf.levels_f2 = levels_f2;
            input_gf.plot_dir = plot_dir_gf;
            input_gf.name_f1 = name_f1;
            input_gf.name_f2 = name_f2;
            
            input_gf.levels_gf = levels_gf;
            input_gf.name_gf   = name_gf;
            input_gf.levels_cf = levels_cf;
            input_gf.name_cf   = name_cf;
            input_gf.select_tw_des=select_tw_des_gf_plot{design_num};
            
        
            
%             eeglab_study_allch_erp_time_dd_grouping_factor_graph(input_gf);
            
        end
        
        %% applicazione maschera a ciascun livello di ogni fattore usando le tw estratte raggruppando per gf
        
        %
        %            cell array a cui applicare la maschera delle p: ha selezionato i
        %     soggetti e i livelli dei fattori da considerare MA non ha fatto
        %     nessuna media
        input_mask.curve_allch = erp_curve_allch;
        %
        %
        %      struttura in cui ho le tw per ogni canale
        input_mask.output_dd_gf = output_dd_gf;
        input_mask.name_f1 =   name_f1;
        input_mask.name_f2 =   name_f2;
        input_mask.levels_f1 =   levels_f1;
        input_mask.levels_f2 =   levels_f2;
        input_mask.allch     =   allch;
        input_mask.times    =  times;
        input_mask.levels_gf  = levels_gf;
        input_mask.name_gf = name_gf;
        input_mask.levels_cf = levels_cf;
        input_mask.name_cf = name_cf;
        
        
        disp('mask grouping factor')
        
        mask_cell_p_gf_file = fullfile(data_driven_path,'gf','mat',['mask_cell_p_gf_', char(STUDY.design(design_num).name), '.mat']);
        
        output_dd_eeglab_mask_cell_p_gf= eeglab_mask_cell_p_gf(input_mask);
        
        output_mask_cell_p_gf.cell_gf = cell_gf;
        output_mask_cell_p_gf.times = times;
        output_mask_cell_p_gf.output_dd_eeglab_mask_cell_p_gf = output_dd_eeglab_mask_cell_p_gf;
        output_mask_cell_p_gf.allch = allch;
        output_mask_cell_p_gf.list_design_subjects = list_design_subjects;
        output_mask_cell_p_gf.levels_f1 = levels_f1;
        output_mask_cell_p_gf.levels_f2 = levels_f2;
        output_mask_cell_p_gf.name_f1 = name_f1;
        output_mask_cell_p_gf.name_f2 = name_f2;
        output_mask_cell_p_gf.name_gf = name_gf;
        output_mask_cell_p_gf.name_cf = name_cf;
        
        
        
        
        
        
        save(mask_cell_p_gf_file,'output_mask_cell_p_gf')
        disp('text extport grouping factor')
        
        out_dir = fullfile(data_driven_path,'gf','text',name_gf);
        if not(exist(out_dir))
            mkdir(out_dir);
        end
        [dataexpcols, dataexp] = text_export_allch_erp_time_dd_gf(out_dir,output_mask_cell_p_gf);
        
        clear dataexpcols dataexp output_mask_cell_p_gf
        
        
    end
    
    
    
end
end
