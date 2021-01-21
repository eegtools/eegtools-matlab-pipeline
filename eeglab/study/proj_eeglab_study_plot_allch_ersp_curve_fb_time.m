%% [STUDY, EEG] = proj_eeglab_study_plot_allch_ersp_curve_fb(project, analysis_name, mode, varargin)
%
% calculate and display erp time series for groups of scalp channels consdered as regions of interests (allch) in
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
% * project.postprocess.ersp.allch_list;
% * project.postprocess.ersp.allch_names;
% * project.postprocess.ersp.frequency_bands_list;
% * project.postprocess.ersp.frequency_bands_names;
% * project.stats.ersp.pvalue;
% * project.stats.ersp.num_permutations;
% * project.stats.eeglab.ersp.correction;
% * project.stats.eeglab.ersp.method;
% * project.results_display.ersp.masked_times_max;
% * project.results_display.ersp.display_only_significant_curve;
% * project.results_display.ersp.compact_plots;
% * project.results_display.ersp.compact_h0;
% * project.results_display.ersp.compact_v0;
% * project.results_display.ersp.compact_sem;
% * project.results_display.ersp.compact_stats;
% * project.results_display.ersp.single_subjects;
% * project.results_display.ersp.compact_display_xlim;
% * project.results_display.ersp.compact_display_ylim;
% * project.postprocess.ersp.design
% * project.stats.ersp.measure;
% * project.stats.ersp.do_narrowband;
% * project.stats.ersp.narrowband.which_realign_measure;
% * project.stats.ersp.narrowband.which_realign_param

% OPTIONAL ARGUMENTS
% 'design_num_vec', 'analysis_name', 'allch_list', 'allch_names', 'study_ls', 'num_permutations', 'correction', 'stat_method', 'filter', 'masked_times_max', ...
% 'display_only_significant', 'display_compact_plots', 'compact_display_h0', 'compact_display_v0', 'compact_display_sem', 'compact_display_stats', 'display_single_subjects', 'compact_display_xlim', 'compact_display_ylim', ...
% 'group_time_windows_list','subject_time_windows_list','group_time_windows_names',
% 'sel_extrema','list_select_subjects','do_plots','num_tails'

function [STUDY, EEG] = proj_eeglab_study_plot_allch_ersp_curve_fb_time(project, analysis_name,  varargin)

if nargin < 1
    help proj_eeglab_study_plot_allch_ersp_curve_fb;
    return;
end;

dfgroup    = [];
dfcond     = [];
dfinter    = [];
narrowband = [];



study_path                  = fullfile(project.paths.output_epochs, project.study.filename);
results_path                = project.paths.results;

paired_list = cell(length(project.design), 2);
for ds=1:length(project.design)
    paired_list{ds} = {project.design(ds).factor1_pairing, project.design(ds).factor2_pairing};
end

subjects_data               = project.subjects.data;

%% VARARGIN DEFAULTS
list_select_subjects        = {};
design_num_vec              = [1:length(project.design)];

% allch_list                    = project.postprocess.ersp.allch_list;
% allch_names                   = project.postprocess.ersp.allch_names;

frequency_bands_list        = project.postprocess.ersp.frequency_bands_list;
frequency_bands_names       = project.postprocess.ersp.frequency_bands_names;

study_ls                    = project.stats.ersp.pvalue;
num_permutations            = project.stats.ersp.num_permutations;
correction                  = project.stats.eeglab.ersp.correction;
stat_method                 = project.stats.eeglab.ersp.method;

% masked_times_max            = project.results_display.ersp.masked_times_max;
% display_only_significant    = project.results_display.ersp.display_only_significant_curve;
% display_compact_plots       = project.results_display.ersp.compact_plots;
% compact_display_h0          = project.results_display.ersp.compact_h0;
% compact_display_v0          = project.results_display.ersp.compact_v0;
% compact_display_sem         = project.results_display.ersp.compact_sem;
% compact_display_stats       = project.results_display.ersp.compact_stats;
% display_single_subjects     = project.results_display.ersp.single_subjects;
xlim        = project.results_display.ersp.compact_display_xlim;
% compact_display_ylim        = project.results_display.ersp.compact_display_ylim;

% group_time_windows_list     = arrange_structure(project.postprocess.ersp.design, 'group_time_windows');
% subject_time_windows_list   = arrange_structure(project.postprocess.ersp.design, 'subject_time_windows');
% group_time_windows_names    = arrange_structure(project.postprocess.ersp.design, 'group_time_windows_names');


ersp_measure                = project.stats.ersp.measure;

do_plots                    = project.results_display.ersp.do_plots;

num_tails                   = project.stats.ersp.num_tails;

% do_narrowband               = project.stats.ersp.do_narrowband;
%
% group_tmin                  = project.stats.ersp.narrowband.group_tmin;
% group_tmax                  = project.stats.ersp.narrowband.group_tmax;
% group_dfmin                 = project.stats.ersp.narrowband.dfmin;
% group_dfmax                 = project.stats.ersp.narrowband.dfmax;
% which_realign_measure_cell  = project.stats.ersp.narrowband.which_realign_measure;
% which_realign_param         = project.stats.ersp.narrowband.which_realign_param;




% %% ANALYSIS MODALITIES
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

% tw_stat_estimator           = mode.tw_stat_estimator;       ... mean, extremum
%     time_resolution_mode        = mode.time_resolution_mode;    ... continous, tw
%     sel_extrema                 = project.postprocess.ersp.sel_extrema;
%
% for par=1:2:length(varargin)
%     switch varargin{par}
%         case {'design_num_vec', 'analysis_name', 'allch_list', 'allch_names', 'study_ls', 'num_permutations', 'correction', 'stat_method', 'filter', 'masked_times_max', ...
%                 'display_only_significant', 'display_compact_plots', 'compact_display_h0', 'compact_display_v0', 'compact_display_sem', 'compact_display_stats', 'display_single_subjects', 'compact_display_xlim', 'compact_display_ylim', ...
%                 'group_time_windows_list','subject_time_windows_list','group_time_windows_names', 'sel_extrema','list_select_subjects','do_plots','num_tails'}
%             if isempty(varargin{par+1})
%                 continue;
%             else
%                 assign(varargin{par}, varargin{par+1});
%             end
%     end
% end


for par=1:2:length(varargin)
    switch varargin{par}
        case {'design_num_vec', 'list_select_subjects','do_plots','num_tails'}
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



chanlocs = eeg_mergelocs(ALLEEG.chanlocs);
allch         = {chanlocs.labels};
sel_cheeg = 1:project.eegdata.nch_eeg;
allch_eeg = allch(sel_cheeg);


ersp_curve_allch_fb_stat.frequency_bands_names    = frequency_bands_names;
ersp_curve_allch_fb_stat.frequency_bands_list     = frequency_bands_list;







for design_num=design_num_vec
    
    %% select the study design for the analyses
    STUDY                                  = std_selectdesign(STUDY, ALLEEG, design_num);
    
    ersp_curve_allch_fb_stat.study_des       = STUDY.design(design_num);
    ersp_curve_allch_fb_stat.study_des.num   = design_num;
    
    name_f1                                = STUDY.design(design_num).variable(1).label;
    levels_f1                              = STUDY.design(design_num).variable(1).value;
    levels_f2 = [];
    name_f2 = [];
    
    if(length(STUDY.design(design_num).variable) > 1 )
        levels_f2                              = STUDY.design(design_num).variable(2).value;
        name_f2                                = STUDY.design(design_num).variable(2).label;
    end
    
    
    str                                    = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
    
    
    % lista dei soggetti suddivisi per fattori
    original_list_design_subjects                   = eeglab_generate_subjects_list_by_factor_levels(project,STUDY, design_num);
    original_individual_fb_bands                    = eeglab_generate_subjects_bands_by_factor_levels(STUDY, design_num, subjects_data, frequency_bands_list);  ... {factor1,factor2}{subj}{band}
        


%% set representation to time-frequency representation
STUDY = pop_erspparams(STUDY, 'topotime',[] ,'plotgroups','apart' ,'plotconditions','apart','averagechan','off','method', stat_method);

%% for each allch in the list
%         for nallch = 1:length(allch_list)
ersp=[];
list_design_subjects                   = eeglab_generate_subjects_list_by_factor_levels(project,STUDY, design_num);


STUDY = pop_statparams(STUDY, 'groupstats','off','condstats','off','method', stat_method);

%% calculate ersp in the channels corresponding to the selected allch
[STUDY ersp times freqs]=std_erspplot(STUDY,ALLEEG,'channels',allch,'noplot','on');
% ersp: [freqs,times,channels,subjects]



%% select subjects
if isempty(levels_f2)
    if strcmp(ersp_measure, 'Pfu')
        for nf1=1:length(levels_f1)
                ersp{nf1,1}=(10.^(ersp{nf1,1}/10)-1)*100;
            
        end
    end
    
    for nf1=1:length(levels_f1)
            if ~isempty(list_select_subjects)
                vec_select_subjects=ismember(original_list_design_subjects{nf1,1},list_select_subjects);
                if ~sum(vec_select_subjects)
                    disp('Error: the selected subjects are not represented in the selected design')
                    return;
                end
                ersp{nf1,1}=ersp{nf1,1}(:,:,sel_cheeg,vec_select_subjects);
                individual_fb_bands{nf1,1} = {original_individual_fb_bands{nf1,1}{vec_select_subjects}};
                list_design_subjects{nf1,1} = {original_list_design_subjects{nf1,1}{vec_select_subjects}};
            else
                individual_fb_bands{nf1,1} = original_individual_fb_bands{nf1,1};
            end
    end
else
    if strcmp(ersp_measure, 'Pfu')
        for nf1=1:length(levels_f1)
            for nf2=1:length(levels_f2)
                ersp{nf1,nf2}=(10.^(ersp{nf1,nf2}/10)-1)*100;
            end
        end
    end
    for nf1=1:length(levels_f1)
        for nf2=1:length(levels_f2)
            if ~isempty(list_select_subjects)
                vec_select_subjects=ismember(original_list_design_subjects{nf1,nf2},list_select_subjects);
                if ~sum(vec_select_subjects)
                    disp('Error: the selected subjects are not represented in the selected design')
                    return;
                end
                ersp{nf1,nf2}=ersp{nf1,nf2}(:,:,sel_cheeg,vec_select_subjects);
                individual_fb_bands{nf1,nf2} = {original_individual_fb_bands{nf1,nf2}{vec_select_subjects}};
                list_design_subjects{nf1,nf2} = {original_list_design_subjects{nf1,nf2}{vec_select_subjects}};
            else
                individual_fb_bands{nf1,nf2} = original_individual_fb_bands{nf1,nf2};
            end
        end
    end
end
ersp_curve_allch_fb_stat.individual_fb_bands  = individual_fb_bands;

%% selecting and averaging powers in a frequency band
for nband=1:length(frequency_bands_list)
    
    plot_dir                               = fullfile(results_path, analysis_name,[STUDY.design(design_num).name,'-ersp_curve_allch_',frequency_bands_names{nband},'-',str]);
    mkdir(plot_dir);
    
    dfgroup    = [];
    dfcond     = [];
    dfinter    = [];
    
    if isempty(levels_f2)
        ersp_curve_allch_fb=[];
        for nf1=1:length(levels_f1)
            subjs = length(individual_fb_bands{nf1,1});
            for nsub=1:subjs
                
                fmin = individual_fb_bands{nf1,1}{nsub}{nband}(1);
                fmax = individual_fb_bands{nf1,1}{nsub}{nband}(2);
                
                sel_freqs = freqs >= fmin & freqs <= fmax;
                ersp_curve_allch_fb{nf1,1}(:,:,nsub)  = squeeze(mean(ersp{nf1,1}(sel_freqs,:,:,nsub),1));
            end
        end
    else
        ersp_curve_allch_fb=[];
        for nf1=1:length(levels_f1)
            for nf2=1:length(levels_f2)
                subjs = length(individual_fb_bands{nf1,nf2});
                for nsub=1:subjs
                    
                    fmin = individual_fb_bands{nf1,nf2}{nsub}{nband}(1);
                    fmax = individual_fb_bands{nf1,nf2}{nsub}{nband}(2);
                    
                    sel_freqs = freqs >= fmin & freqs <= fmax;
                    ersp_curve_allch_fb{nf1,nf2}(:,:,nsub)  = squeeze(mean(ersp{nf1,nf2}(sel_freqs,:,:,nsub),1));
                end
            end
        end
    end
    
    times_plot=times;
    
    
    %% calculate statistics
    [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = std_stat_corr(ersp_curve_allch_fb,num_tails,'groupstats','on','condstats','on','mcorrect','none','threshold',NaN,'naccu',num_permutations,'method', stat_method,'paired',paired_list{design_num});
    for ind = 1:length(pcond),  pcond{ind}    =  abs(pcond{ind}) ; end;
    for ind = 1:length(pgroup),  pgroup{ind}  =  abs(pgroup{ind}) ; end;
    for ind = 1:length(pinter),  pinter{ind}  =  abs(pinter{ind}) ; end;
    
    [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
    
    
    %% spostare a valle questa parte di plot per separare la rappresentazione dalla statistica e consentire di far girare la stessa funzione anche con l'output
    if (strcmp(do_plots,'on'))
        %
        %                 STUDY, design_num, allch_name, name_f1, name_f2, levels_f1,levels_f2, ersp_curve_allch_fb, times_plot, frequency_bands_names{nband}, ...
        %                     pcond_corr, pgroup_corr, pinter_corr,study_ls,plot_dir,display_only_significant,...
        %                     display_compact_plots, compact_display_h0,compact_display_v0,compact_display_sem,compact_display_stats,...
        %                     display_single_subjects,compact_display_xlim,compact_display_ylim,ersp_measure
        
        
        %                         ersp_curve_allch_fb_stat.STUDY                                           = STUDY;
        %         ersp_curve_allch_fb_stat.design_num                                      = design_num;
        %                         ersp_curve_allch_fb_stat.allch_name                                        = allch_name;
        %                         ersp_curve_allch_fb_stat.name_f1                                         = name_f1;
        %                         ersp_curve_allch_fb_stat.name_f2                                         = name_f2;
        ersp_curve_allch_fb_stat.ersp_curve_fb                                   = ersp_curve_allch_fb;
        ersp_curve_allch_fb_stat.study_ls                                        = study_ls;
        ersp_curve_allch_fb_stat.allch = allch_eeg;
        ersp_curve_allch_fb_stat.amplim                                         = project.results_display.erp.compact_display_ylim;
        ersp_curve_allch_fb_stat.times                                           = times_plot;
        
        
        ersp_curve_allch_fb_stat.levels_f1                                       = levels_f1;
        ersp_curve_allch_fb_stat.levels_f2                                       = levels_f2;
        
        
        
        ersp_curve_allch_fb_stat.frequency_band_name                             = frequency_bands_names{nband};
        ersp_curve_allch_fb_stat.pcond_corr                                           = pcond_corr;
        ersp_curve_allch_fb_stat.pgroup_corr                                          = pgroup_corr;
        %                         ersp_curve_allch_fb_stat.pinter                                          = pinter_corr;
        
        ersp_curve_allch_fb_stat.plot_dir                                        = plot_dir;
        %                         ersp_curve_allch_fb_stat.display_only_significant                        = display_only_significant;
        %                         ersp_curve_allch_fb_stat.display_compact_plots                           = display_compact_plots;
        %                         ersp_curve_allch_fb_stat.compact_display_h0                              = compact_display_h0;
        %                         ersp_curve_allch_fb_stat.compact_display_v0                              = compact_display_v0;
        %                         ersp_curve_allch_fb_stat.compact_display_sem                             = compact_display_sem;
        %                         ersp_curve_allch_fb_stat.compact_display_stats                           = compact_display_stats;
        %                         ersp_curve_allch_fb_stat.display_single_subjects                         = display_single_subjects;
        %                         ersp_curve_allch_fb_stat.compact_display_xlim                            = compact_display_xlim;
        %                         ersp_curve_allch_fb_stat.compact_display_ylim                            = compact_display_ylim;
        ersp_curve_allch_fb_stat.ersp_measure                                    = ersp_measure;
        %                         ersp_curve_allch_fb_stat.time_windows_design_names                       = group_time_windows_names{design_num};
        %                         ersp_curve_allch_fb_stat.list_design_subjects                            = list_design_subjects;
        ersp_curve_allch_fb_stat.xlim                                    = xlim;
        
        eeglab_study_allch_ersp_curve_fb_time_graph(ersp_curve_allch_fb_stat);
        
    end
    
    
    
    ersp_curve_allch_fb_stat.databand(nband).frequency_band_name   = frequency_bands_names{nband};
    ersp_curve_allch_fb_stat.databand(nband).frequency_band        = frequency_bands_list{nband};
    ersp_curve_allch_fb_stat.databand(nband).ersp_curve_allch_fb     = ersp_curve_allch_fb;
    
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).pcond                 = pcond;
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).pgroup                = pgroup;
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).pinter                = pinter;
    %
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).statscond             = statscond;
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).statsgroup            = statsgroup;
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).statsinter            = statsinter;
    %
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).pcond_corr            = pcond_corr;
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).pgroup_corr           = pgroup_corr;
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).pinter_corr           = pinter_corr;
    %
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).dfcond                = dfcond;
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).dfgroup               = dfgroup;
    %     ersp_curve_allch_fb_stat.datach(nallch).databand(nband).dfinter               = dfinter;
    
    
    %         ersp_curve_allch_fb_stat.datach(nallch).databand(nband).narrowband            = narrowband;
    
    %% EXPORTING DATA AND RESULTS OF ANALYSIS
    out_file_name = fullfile(plot_dir,'ersp_curve_allch_fb-stat')
    save([out_file_name,'.mat'],'ersp_curve_allch_fb_stat','project');
    
end

% ersp_curve_allch_fb_stat.datach(nallch).allch_channels=allch_channels;
% ersp_curve_allch_fb_stat.datach(nallch).allch_name=allch_name;
%
%
% ersp_curve_allch_fb_stat.times=times_plot;


% if strcmp(time_resolution_mode,'tw')
%     ersp_curve_allch_fb_stat.group_time_windows_list                 = group_time_windows_list_design;
%     ersp_curve_allch_fb_stat.group_time_windows_names                = group_time_windows_names_design;
%     ersp_curve_allch_fb_stat.which_extrema_design                    = which_extrema_design_tw;
%     ersp_curve_allch_fb_stat.sel_extrema                             = sel_extrema;
%
%     if strcmp(mode.peak_type,'individual')
%         ersp_curve_allch_fb_stat.subject_time_windows_list = subject_time_windows_list;
%     end
% end

% ersp_curve_allch_fb_stat.list_select_subjects = list_select_subjects;
ersp_curve_allch_fb_stat.list_design_subjects = list_design_subjects;
%
% ersp_curve_allch_fb_stat.study_ls             = study_ls;
% ersp_curve_allch_fb_stat.num_permutations     = num_permutations;
% ersp_curve_allch_fb_stat.correction           = correction;



% if ~ ( strcmp(which_method_find_extrema,'group_noalign') || strcmp(which_method_find_extrema,'continuous') );
%     [dataexpcols, dataexp]=text_export_ersp_struct([out_file_name,'.txt'],ersp_curve_allch_fb_stat);
% end


% if not( strcmp(which_method_find_extrema,'group_noalign') || strcmp(which_method_find_extrema,'continuous') );
%     [dataexpcols, dataexp]=text_export_ersp_struct([out_file_name,'.txt'],ersp_curve_allch_fb_stat);
%     text_export_ersp_resume_struct(ersp_curve_allch_fb_stat, [out_file_name '_resume']);
%     text_export_ersp_resume_struct(ersp_curve_allch_fb_stat, [out_file_name '_resume_signif'], 'p_thresh', ersp_curve_allch_fb_stat.study_ls);
%
% end

% if  strcmp(which_method_find_extrema,'continuous') ;
[dataexpcols, dataexp]=text_export_ersp_allch_sub_continuous_struct(plot_dir,ersp_curve_allch_fb_stat);
% end

% if strcmp(time_resolution_mode,'tw')
%     [dataexpcols, dataexp] = text_export_ersp_onset_offset_sub_struct([out_file_name,'_sub_onset_offset.txt'],ersp_curve_allch_fb_stat);
%     [dataexpcols, dataexp] = text_export_ersp_onset_offset_avgsub_struct([out_file_name,'_avgsub_onset_offset.txt'],ersp_curve_allch_fb_stat);
%
%     [dataexpcols, dataexp] = text_export_ersp_onset_offset_sub_continuous_struct([out_file_name,'_sub_onset_offset_continuous.txt'],ersp_curve_allch_fb_stat);
%     [dataexpcols, dataexp] = text_export_ersp_onset_offset_avgsub_continuous_struct([out_file_name,'_avgsub_onset_offset_continuous.txt'],ersp_curve_allch_fb_stat);
% end

end
end

% CHANGE LOG
% 14/4/2016
% added text_export_ersp_resume_struct to export singificant values to a text file
% 19/6/15
% added the possibility to calculte narrowband analysis also on the NB COG, not the NB MAX.
