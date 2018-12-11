%% [STUDY, EEG] = proj_eeglab_study_plot_roi_ersp_curve_fb(project, analysis_name, mode, varargin)
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
% * project.postprocess.ersp.roi_list;
% * project.postprocess.ersp.roi_names;
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
% 'design_num_vec', 'analysis_name', 'roi_list', 'roi_names', 'study_ls', 'num_permutations', 'correction', 'stat_method', 'filter', 'masked_times_max', ...
% 'display_only_significant', 'display_compact_plots', 'compact_display_h0', 'compact_display_v0', 'compact_display_sem', 'compact_display_stats', 'display_single_subjects', 'compact_display_xlim', 'compact_display_ylim', ...
% 'group_time_windows_list','subject_time_windows_list','group_time_windows_names',
% 'sel_extrema','list_select_subjects','do_plots','num_tails'

function [STUDY, EEG] = proj_eeglab_study_plot_roi_ersp_curve_fb(project, analysis_name, mode, varargin)

if nargin < 1
    help proj_eeglab_study_plot_roi_ersp_curve_fb;
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

roi_list                    = project.postprocess.ersp.roi_list;
roi_names                   = project.postprocess.ersp.roi_names;

frequency_bands_list        = project.postprocess.ersp.frequency_bands_list;
frequency_bands_names       = project.postprocess.ersp.frequency_bands_names;

study_ls                    = project.stats.ersp.pvalue;
num_permutations            = project.stats.ersp.num_permutations;
correction                  = project.stats.eeglab.ersp.correction;
stat_method                 = project.stats.eeglab.ersp.method;

masked_times_max            = project.results_display.ersp.masked_times_max;
display_only_significant    = project.results_display.ersp.display_only_significant_curve;
display_compact_plots       = project.results_display.ersp.compact_plots;
compact_display_h0          = project.results_display.ersp.compact_h0;
compact_display_v0          = project.results_display.ersp.compact_v0;
compact_display_sem         = project.results_display.ersp.compact_sem;
compact_display_stats       = project.results_display.ersp.compact_stats;
display_single_subjects     = project.results_display.ersp.single_subjects;
compact_display_xlim        = project.results_display.ersp.compact_display_xlim;
compact_display_ylim        = project.results_display.ersp.compact_display_ylim;

group_time_windows_list     = arrange_structure(project.postprocess.ersp.design, 'group_time_windows');
subject_time_windows_list   = arrange_structure(project.postprocess.ersp.design, 'subject_time_windows');
group_time_windows_names    = arrange_structure(project.postprocess.ersp.design, 'group_time_windows_names');

ersp_measure                = project.stats.ersp.measure;

do_plots                    = project.results_display.ersp.do_plots;

num_tails                   = project.stats.ersp.num_tails;

do_narrowband               = project.stats.ersp.do_narrowband;
if not(isfield(project.stats.ersp.narrowband,'mode'))
    project.stats.ersp.narrowband.mode = 'subject';
end
narrowband_mode             = project.stats.ersp.narrowband.mode;

group_tmin                  = project.stats.ersp.narrowband.group_tmin;
group_tmax                  = project.stats.ersp.narrowband.group_tmax;
group_dfmin                 = project.stats.ersp.narrowband.dfmin;
group_dfmax                 = project.stats.ersp.narrowband.dfmax;
which_realign_measure_cell  = project.stats.ersp.narrowband.which_realign_measure;
which_realign_param         = project.stats.ersp.narrowband.which_realign_param;

if not(isfield(project.stats.ersp,'alignt0'))
    project.stats.ersp.alignt0 = 0;
end

alignt0                       = project.stats.ersp.alignt0;


if not(isfield(project.stats.ersp,'split_base'))
    project.stats.ersp.split_base = 0;
end

split_base                    = project.stats.ersp.split_base;


%% ANALYSIS MODALITIES
if strcmp(mode.peak_type, 'group') && strcmp(mode.align, 'off')
    which_method_find_extrema = 'group_noalign';
elseif strcmp(mode.peak_type, 'group') && strcmp(mode.align, 'on')
    which_method_find_extrema = 'group_align';
elseif strcmp(mode.peak_type, 'individual') && strcmp(mode.align, 'off')
    which_method_find_extrema = 'individual_noalign';
elseif strcmp(mode.peak_type, 'individual') && strcmp(mode.align, 'on')
    which_method_find_extrema = 'individual_align';
elseif strcmp(mode.peak_type, 'off')
    which_method_find_extrema = 'continuous';
end

tw_stat_estimator           = mode.tw_stat_estimator;       ... mean, extremum
    time_resolution_mode        = mode.time_resolution_mode;    ... continous, tw
    sel_extrema                 = project.postprocess.ersp.sel_extrema;

for par=1:2:length(varargin)
    switch varargin{par}
        case {'design_num_vec', 'analysis_name', 'roi_list', 'roi_names', 'study_ls', 'num_permutations', 'correction', 'stat_method', 'filter', 'masked_times_max', ...
                'display_only_significant', 'display_compact_plots', 'compact_display_h0', 'compact_display_v0', 'compact_display_sem', 'compact_display_stats', 'display_single_subjects', 'compact_display_xlim', 'compact_display_ylim', ...
                'group_time_windows_list','subject_time_windows_list','group_time_windows_names', 'sel_extrema','list_select_subjects','do_plots','num_tails'}
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


ersp_curve_roi_fb_stat.roi_names                = roi_names;
ersp_curve_roi_fb_stat.roi_list                 = roi_list;
ersp_curve_roi_fb_stat.frequency_bands_names    = frequency_bands_names;
ersp_curve_roi_fb_stat.frequency_bands_list     = frequency_bands_list;
ersp_curve_roi_fb_stat.mode                     = mode;

%% calculate narrowband
% it does not depending even by the design: the ref condition is fixed the
% same for all designs. from the narrowband structure will select the band
% for each subject and this band will be applied to all conditions of the
% same subject
nb = [];

if strcmp(narrowband_mode,'subject')
    
    if strcmp(do_narrowband,'ref')
        nb = proj_eeglab_subject_extract_narrowband(project,analysis_name);
    end
end



for design_num=design_num_vec
    if strcmp(narrowband_mode,'group')
        
        if strcmp(do_narrowband,'ref')
            nb = proj_eeglab_group_extract_narrowband(project,analysis_name,design_num);
        end
    end
    %% select the study design for the analyses
    STUDY                                  = std_selectdesign(STUDY, ALLEEG, design_num);
    
    ersp_curve_roi_fb_stat.study_des       = STUDY.design(design_num);
    ersp_curve_roi_fb_stat.study_des.num   = design_num;
    
    name_f1                                = STUDY.design(design_num).variable(1).label;
    name_f2                                = STUDY.design(design_num).variable(2).label;
    
    levels_f1                              = STUDY.design(design_num).variable(1).value;
    levels_f2                              = STUDY.design(design_num).variable(2).value;
    str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
    plot_dir                               = fullfile(results_path, analysis_name,[STUDY.design(design_num).name,'-ersp_curve_roi_',which_method_find_extrema,'-',str]);
    mkdir(plot_dir);
    
    % lista dei soggetti suddivisi per fattori
    original_list_design_subjects                   = eeglab_generate_subjects_list_by_factor_levels(project,STUDY, design_num);
    original_individual_fb_bands                    = eeglab_generate_subjects_bands_by_factor_levels(STUDY, design_num, subjects_data, frequency_bands_list);  ... {factor1,factor2}{subj}{band}
        


%% set representation to time-frequency representation
STUDY = pop_erspparams(STUDY, 'topotime',[] ,'plotgroups','apart' ,'plotconditions','apart','averagechan','on','method', stat_method);

if split_base
    fname_out = fullfile(STUDY.filepath,[STUDY.design(design_num).name,'.mat']);
    load(fname_out,'erspdata_post_bc','times_post', 'freqs_post');
    allch = [STUDY.changrp.channels];
    ersp_allch = erspdata_post_bc;
    times   = times_post;
    freqs   = freqs_post;
    clear erspdata_post_bc  times_post freqs_post;
end

%% for each roi in the list
for nroi = 1:length(roi_list)
    ersp=[];
    list_design_subjects                   = eeglab_generate_subjects_list_by_factor_levels(project,STUDY, design_num);
    
    roi_channels=roi_list{nroi};
    roi_name=roi_names{nroi};
    STUDY = pop_statparams(STUDY, 'groupstats','off','condstats','off','method', stat_method);
    
    %             %% calculate ersp in the channels corresponding to the selected roi
    %             [STUDY, ersp, times, freqs]=std_erspplot(STUDY,ALLEEG,'channels',roi_list{nroi},'noplot','on');
    %
    
    if not(split_base)        
        [STUDY, ersp, times, freqs]=std_erspplot(STUDY,ALLEEG,'channels',roi_channels,'noplot','on');
    else
       sel_ch_roi = ismember(allch,roi_channels);
       [trr, tcc] = size(ersp_allch);
       for nrr = 1:trr
           for ncc = 1:tcc
               ersp{nrr,ncc} = ersp_allch{nrr,ncc}(:,:,sel_ch_roi,:);
           end
       end
    end
    
    
    
    
    
    if alignt0
        
        sel_times = times >= 0;
        tsel_times = sum(sel_times);
        [trr, tcc] = size(ersp);
        
        for nrr = 1:trr
            for ncc = 1:tcc
                ersp_mat = ersp{nrr,ncc}(:,sel_times,:,:);
                ersp_mat0 = repmat(ersp_mat(:,1,:,:),1,tsel_times,1);
                ersp{nrr,ncc} = ersp_mat - ersp_mat0;
            end
        end
        times = times(sel_times);
    end
    
    
    if strcmp(ersp_measure, 'Pfu')
        for nf1=1:length(levels_f1)
            for nf2=1:length(levels_f2)
                ersp{nf1,nf2}=(10.^(ersp{nf1,nf2}/10)-1)*100;
            end
        end
    end
    
    %% select subjects
    for nf1=1:length(levels_f1)
        for nf2=1:length(levels_f2)
            if ~isempty(list_select_subjects)
                vec_select_subjects=ismember(original_list_design_subjects{nf1,nf2},list_select_subjects);
                if ~sum(vec_select_subjects)
                    disp('Error: the selected subjects are not represented in the selected design')
                    return;
                end
                ersp{nf1,nf2}=ersp{nf1,nf2}(:,:,:,vec_select_subjects);
                individual_fb_bands{nf1,nf2} = {original_individual_fb_bands{nf1,nf2}{vec_select_subjects}};
                list_design_subjects{nf1,nf2} = {original_list_design_subjects{nf1,nf2}{vec_select_subjects}};
            else
                individual_fb_bands{nf1,nf2} = original_individual_fb_bands{nf1,nf2};
            end
        end
    end
    ersp_curve_roi_fb_stat.individual_fb_bands  = individual_fb_bands;
    
    %% averaging channels in the roi
    ersp_roi=[];
    for nf1=1:length(levels_f1)
        for nf2=1:length(levels_f2)
            ersp_roi{nf1,nf2}=squeeze(mean(ersp{nf1,nf2},3));
        end
    end
    
    %% selecting and averaging powers in a frequency band
    for nband=1:length(frequency_bands_list)
        
        dfgroup    = [];
        dfcond     = [];
        dfinter    = [];
        narrowband = [];
        
        ersp_curve_roi_fb=[];
        for nf1=1:length(levels_f1)
            for nf2=1:length(levels_f2)
                subjs = length(individual_fb_bands{nf1,nf2});
                for nsub=1:subjs
                    
                    fmin = individual_fb_bands{nf1,nf2}{nsub}{nband}(1);
                    fmax = individual_fb_bands{nf1,nf2}{nsub}{nband}(2);
                    
                    ...[nfmin, nfmax] = eeglab_get_narrowband(ersp_curve_roi_fb{nf1,nf2}(:,nsub), [fmin fmax], [tmin tmax], [dfmin dfmax]);
                        sel_freqs = freqs >= fmin & freqs <= fmax;
                    
                    % cla sposto qui per il narrowband
                    
                    group_time_windows_list_design                          = group_time_windows_list{design_num};
                    group_time_windows_names_design                         = group_time_windows_names{design_num};
                    
                    ersp_curve_roi_fb_stat.group_time_windows_list_design   = group_time_windows_list_design;
                    ersp_curve_roi_fb_stat.group_time_windows_names_design  = group_time_windows_list_design;
                    
                    which_extrema_design_continuous                         = project.postprocess.ersp.design(design_num).which_extrema_curve_continuous; ...which_extrema_ersp_curve_fb{design_num};
                        
                which_extrema_design_roi_continuous                     = which_extrema_design_continuous{nroi};
                %                             which_extrema_design_roi_band_continuous                = which_extrema_design_roi_continuous{nband};
                
                ersp_matrix_sub                                         = ersp_roi{nf1,nf2}(:,:,nsub);
                
                if isempty(group_tmin)
                    group_tmin = min(times);
                end
                %                 if isempty(group_fmin)
                group_fmin = fmin;
                %                 end
                
                if isempty(group_tmax)
                    group_tmax = max(times);
                end
                
                %                 if isempty(group_fmax)
                group_fmax = fmax;
                %                 end
                
                narrowband_output = [];
                
                %% narrowband
                % the possibility of restrict and recenter the band considered based on the activity of the single subject
                % (thus obtaining theoretically more reliable results, eliminating physiological inter subject variability.
                % assume that for each band there is a reference condition
                % and a reference roi. for this condition and roi,
                % calculate for each subject the frequency with the strongest activity
                % (fnb). Then, using calculated fnb and [dfmin dmfmax], use the same narrow band for all conditions of the single considered subject.
                % so, in a first step (depending only by band) calculate
                % fnb for each subject. in a second steps apply fnb to all
                % conditions of the corresponding subject.
                
                if strcmp(do_narrowband,'ref')||strcmp(do_narrowband,'auto')
                    
                    group_fmin = fmin;
                    group_fmax = fmax;
                    
                    % narrowband input structure
                    narrowband_input.times                  = times;
                    narrowband_input.freqs                  = freqs;
                    narrowband_input.ersp_matrix_sub        = ersp_matrix_sub;
                    narrowband_input.group_tmin             = group_tmin;
                    narrowband_input.group_tmax             = group_tmax;
                    narrowband_input.group_fmin             = group_fmin;
                    narrowband_input.group_fmax             = group_fmax ;
                    narrowband_input.group_dfmin            = group_dfmin;
                    narrowband_input.group_dfmax            = group_dfmax;
                    narrowband_input.which_realign_measure  = which_realign_measure_cell{nband};
                    
                    [project, narrowband_output]            = eeglab_get_narrowband(project,narrowband_input);
                    
                    
                    %                     if ~isempty([sub_adjusted_fmin, sub_adjusted_fmax])
                    which_realign_param_band                = which_realign_param{nband};
                    if strcmp(do_narrowband,'auto')
                        if strcmp(which_realign_param_band, 'fnb')
                            fmin                                    = narrowband_output.results.sub.fmin;
                            fmax                                    = narrowband_output.results.sub.fmax;
                        else
                            fmin                                    = narrowband_output.results.sub.fb.fcog - narrowband_input.group_dfmin;
                            fmax                                    = narrowband_output.results.sub.fb.fcog + narrowband_input.group_dfmax;
                        end
                    end
                    %                     end
                    
                    narrowband_output.adjusted_frequency_band{nf1,nf2}(nsub,:)          = [narrowband_output.results.sub.fmin, narrowband_output.results.sub.fmax];
                    narrowband_output.realign_freq{nf1,nf2}(nsub)                       = narrowband_output.results.sub.realign_freq;
                    narrowband_output.realign_freq_value{nf1,nf2}(nsub)                 = narrowband_output.results.sub.realign_freq;
                    narrowband_output.realign_freq_value_lat{nf1,nf2}{nsub}             = narrowband_output.results.sub.realign_freq_value_lat;
                    
                    narrowband_output.mean_centroid_group_fb{nf1,nf2}(nsub)             = narrowband_output.results.group.fb.centroid_mean; ...   mean_centroid_group_fb;
                        narrowband_output.mean_centroid_sub_realign_fb{nf1,nf2}(nsub)       = narrowband_output.results.sub.fb.centroid_mean;   ...mean_centroid_sub_realign_fb;
                        narrowband_output.median_centroid_group_fb{nf1,nf2}(nsub)           = narrowband_output.results.group.fb.centroid_median;  ...results.group.fb.centroid_median ...median_centroid_group_fb;
                        ...narrowband_output.median_centroid_sub_realign_fb{nf1,nf2}(nsub) = 0; ...narrowband_output.results.sub.fb.centroid_median;  ...median_centroid_sub_realign_fb;
                        
                    narrowband{nf1,nf2,nsub}            = narrowband_output;
                    
                    if strcmp(do_narrowband,'ref')
                        switch which_realign_param_band
                            case 'fnb'
                                fmin                                    = nb.results.nb.band(nband).sub(nsub).fnb - project.postprocess.ersp.frequency_bands(nband).dfmin;
                                fmax                                    = nb.results.nb.band(nband).sub(nsub).fnb + project.postprocess.ersp.frequency_bands(nband).dfmax;
                                
                            case 'cog_pos'
                                fmin                                    = nb.results.nb.band(nband).sub(nsub).fcog.pos - project.postprocess.ersp.frequency_bands(nband).dfmin;
                                fmax                                    = nb.results.nb.band(nband).sub(nsub).fcog.pos + project.postprocess.ersp.frequency_bands(nband).dfmax;
                                
                            case 'cog_neg'
                                fmin                                    = nb.results.nb.band(nband).sub(nsub).fcog.neg - project.postprocess.ersp.frequency_bands(nband).dfmin;
                                fmax                                    = nb.results.nb.band(nband).sub(nsub).fcog.neg + project.postprocess.ersp.frequency_bands(nband).dfmax;
                        end
                    end
                end
                
                sel_freqs                           = freqs >= fmin & freqs <= fmax;
                ersp_curve_roi_fb{nf1,nf2}(:,nsub)  = mean(ersp_roi{nf1,nf2}(sel_freqs,:,nsub),1);
                end
            end
        end
        
        %% involve functions based on finding extrema of time
        % windows
        
        if strcmp(time_resolution_mode,'tw')
            
            
            group_time_windows_list_design      = group_time_windows_list{design_num};
            group_time_windows_names_design     = group_time_windows_names{design_num};
            
            ersp_curve_roi_fb_stat.group_time_windows_list_design  = group_time_windows_list_design;
            ersp_curve_roi_fb_stat.group_time_windows_names_design = group_time_windows_names_design;
            
            which_extrema_design_tw             = project.postprocess.ersp.design(design_num).which_extrema_curve_tw; ...which_extrema_ersp_curve_fb{design_num};
                which_extrema_design_roi_tw         = which_extrema_design_tw{nroi};
            which_extrema_design_roi_band_tw    = which_extrema_design_roi_tw{nband};
            
            
            % check if estimated TIMES is contained within intervals of interests
            max_times   = max(times);
            max_v       = -10000;
            for nwin=1:length(group_time_windows_list_design)
                max_v = max(max_v, group_time_windows_list_design{nwin}(2));
            end
            if max_v > max_times
                disp(['error !!: higher latency of available ERSP window' num2str(max_times) 'is less than highest latency of input windows' num2str(max_v)]);
                return;
            end
            
            %             switch which_method_find_extrema
            %
            %                 case 'group_noalign'
            %                     ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).datatw.find_extrema = ...
            %                         eeglab_study_plot_find_extrema_avg(ersp_curve_roi_fb,levels_f1,levels_f2,group_time_windows_list_design,times,which_extrema_design_roi_band_tw,sel_extrema);
            %                 case 'group_align'
            %                     disp('ERROR: still not implemented!!! adopting individual_align ');
            %                     subject_time_windows_list_design=subject_time_windows_list{design_num};
            %                     ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).datatw.find_extrema = ...
            %                         eeglab_study_plot_find_extrema_single(ersp_curve_roi_fb,levels_f1,levels_f2,group_time_windows_list_design,subject_time_windows_list_design,times,...
            %                         which_extrema_design_roi_band_tw,sel_extrema);
            %                     ...ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).datatw.find_extrema = ...
            %                         ...  eeglab_study_plot_find_extrema_avg(ersp_curve_roi_fb,levels_f1,levels_f2,group_time_windows_list_design,times,which_extrema_design_roi_band,sel_extrema);
            %
            %                 case 'individual_noalign'
            %                     ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).datatw.find_extrema = ...
            %                         eeglab_study_plot_find_extrema_gru(ersp_curve_roi_fb,levels_f1,levels_f2,group_time_windows_list_design,times,which_extrema_design_roi_band_tw,sel_extrema);
            %                 case 'individual_align'
            %                     subject_time_windows_list_design=subject_time_windows_list{design_num};
            %                     ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).datatw.find_extrema = ...
            %                         eeglab_study_plot_find_extrema_single(ersp_curve_roi_fb,levels_f1,levels_f2,group_time_windows_list_design,subject_time_windows_list_design,times,...
            %                         which_extrema_design_roi_band_tw,sel_extrema);
            %             end
            
            
            input_find_extrema.which_method_find_extrema             = which_method_find_extrema;
            input_find_extrema.design_num                            = design_num;
            input_find_extrema.roi_name                              = roi_name;
            input_find_extrema.curve                                 = ersp_curve_roi_fb;
            input_find_extrema.levels_f1                             = levels_f1;
            input_find_extrema.levels_f2                             = levels_f2;
            input_find_extrema.group_time_windows_list_design        = group_time_windows_list_design;
            input_find_extrema.subject_time_windows_list             = subject_time_windows_list;
            input_find_extrema.times                                 = times;
            input_find_extrema.which_extrema_design_roi              = which_extrema_design_roi_band_tw;
            input_find_extrema.sel_extrema                           = sel_extrema;
            
            ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).datatw.find_extrema  = eeglab_study_plot_find_extrema(input_find_extrema);
            
            
            
            
            deflection_polarity_list                                       = project.postprocess.ersp.design(design_num).deflection_polarity_list;
            
            deflection_polarity_roi                                        =  deflection_polarity_list{nroi};
            deflection_polarity_band                                       =  deflection_polarity_roi{nband};
            
            input_onset_offset.curve                                       = ersp_curve_roi_fb;
            input_onset_offset.levels_f1                                   = levels_f1;
            input_onset_offset.levels_f2                                   = levels_f2;
            input_onset_offset.group_time_windows_list_design              = group_time_windows_list_design;
            input_onset_offset.times                                       = times;
            input_onset_offset.deflection_polarity_list                    = deflection_polarity_band;
            input_onset_offset.min_duration                                = project.postprocess.ersp.design(design_num).min_duration ;
            input_onset_offset.base_tw                                     = [project.epoching.bc_st.ms project.epoching.bc_end.ms] ;                           % baseline in ms
            input_onset_offset.pvalue                                      = study_ls;                          % default will be 0.05
            input_onset_offset.correction                                  = correction ;                       % string. correction for multiple comparisons 'none'| 'fdr' | 'holms' | 'bonferoni'
            
            ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).datatw.onset_offset = eeglab_study_curve_tw_onset_offset(input_onset_offset);
            
            
            
            
            
            
        end
        
        times_plot=times;
        
        if strcmp(time_resolution_mode,'tw')
            if strcmp(which_method_find_extrema,'group_align')
                tw_stat_estimator = 'tw_mean';
            end
            
            switch tw_stat_estimator
                case 'tw_mean'
                    ersp_curve_roi_fb=ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).datatw.find_extrema.curve;
                case 'tw_extremum'
                    ersp_curve_roi_fb=ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).datatw.find_extrema.extr;
            end
            
            times_plot=1:length(group_time_windows_list_design);
            
            %% calculate statistics
            [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = std_stat_corr(ersp_curve_roi_fb,num_tails,'groupstats','on','condstats','on','mcorrect','none','threshold',NaN,'naccu',num_permutations,'method', stat_method,'paired',paired_list{design_num});
            for ind = 1:length(pcond),  pcond{ind}    =  abs(pcond{ind}) ; end;
            for ind = 1:length(pgroup),  pgroup{ind}  =  abs(pgroup{ind}) ; end;
            for ind = 1:length(pinter),  pinter{ind}  =  abs(pinter{ind}) ; end;
            
            [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
            
            
            input_graph.STUDY                                               = STUDY;
            input_graph.design_num                                          = design_num;
            input_graph.roi_name                                            = roi_name;
            input_graph.name_f1                                             = name_f1;
            input_graph.name_f2                                             = name_f2;
            input_graph.levels_f1                                           = levels_f1;
            input_graph.levels_f2                                           = levels_f2;
            input_graph.ersp_curve_fb                                       = ersp_curve_roi_fb;
            input_graph.times                                               = times_plot;
            input_graph.frequency_band_name                                 = frequency_bands_names{nband};
            input_graph.time_windows_design_names                           = group_time_windows_names{design_num};
            input_graph.pcond                                               = pcond_corr;
            input_graph.pgroup                                              = pgroup_corr;
            input_graph.pinter                                              = pinter_corr;
            input_graph.study_ls                                            = study_ls;
            input_graph.plot_dir                                            = plot_dir;
            input_graph.display_only_significant                            = display_only_significant;
            input_graph.display_compact_plots                               = display_compact_plots;
            input_graph.compact_display_h0                                  = compact_display_h0;
            input_graph.compact_display_v0                                  = compact_display_v0;
            input_graph.compact_display_sem                                 = compact_display_sem;
            input_graph.compact_display_stats                               = compact_display_stats;
            input_graph.compact_display_xlim                                = compact_display_xlim;
            input_graph.compact_display_ylim                                = compact_display_ylim;
            input_graph.ersp_measure                                        = ersp_measure;
            input_graph.list_design_subjects                                = list_design_subjects;
            
            
            if (strcmp(do_plots,'on'))
                eeglab_study_roi_ersp_curve_tw_fb_graph(input_graph);
            end
            
            
            [stat df pvals] = statcond_corr(ersp_curve_roi_fb, 2, 'alpha',NaN,'naccu',num_permutations,'method', stat_method);
            
            if iscell(df)
                if length(pcond)
                    dfcond=df{1};
                end
                if length(pgroup)
                    dfgroup=df{1};
                end
                if length(pinter)
                    dfinter=df{1};
                end
                
            else
                if length(pcond)
                    dfcond=df(1,:);
                end
                if length(pgroup)
                    dfgroup=df(1,:);
                end
                if length(pinter)
                    dfinter=df(1,:);
                end
                
                
            end
            
            
            
        else
            %% calculate statistics
            [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = std_stat_corr(ersp_curve_roi_fb,num_tails,'groupstats','on','condstats','on','mcorrect','none','threshold',NaN,'naccu',num_permutations,'method', stat_method,'paired',paired_list{design_num});
            for ind = 1:length(pcond),  pcond{ind}    =  abs(pcond{ind}) ; end;
            for ind = 1:length(pgroup),  pgroup{ind}  =  abs(pgroup{ind}) ; end;
            for ind = 1:length(pinter),  pinter{ind}  =  abs(pinter{ind}) ; end;
            
            [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
            
            
            [stat df pvals] = statcond_corr(ersp_curve_roi_fb, 2, 'alpha',NaN,'naccu',num_permutations,'method', stat_method);
            
            if iscell(df)
                if length(pcond)
                    dfcond=df{1};
                end
                if length(pgroup)
                    dfgroup=df{1};
                end
                if length(pinter)
                    dfinter=df{1};
                end
                
            else
                if length(pcond)
                    dfcond=df(1,:);
                end
                if length(pgroup)
                    dfgroup=df(1,:);
                end
                if length(pinter)
                    dfinter=df(1,:);
                end
                
                
            end
            
            
            if ~ isempty(masked_times_max)
                [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_roi_curve_maskp(pcond_corr, pgroup_corr, pinter_corr,times_plot, masked_times_max);
            end
            if (strcmp(do_plots,'on'))
                %
                %                 STUDY, design_num, roi_name, name_f1, name_f2, levels_f1,levels_f2, ersp_curve_roi_fb, times_plot, frequency_bands_names{nband}, ...
                %                     pcond_corr, pgroup_corr, pinter_corr,study_ls,plot_dir,display_only_significant,...
                %                     display_compact_plots, compact_display_h0,compact_display_v0,compact_display_sem,compact_display_stats,...
                %                     display_single_subjects,compact_display_xlim,compact_display_ylim,ersp_measure
                
                input_graph.STUDY                                           = STUDY;
                input_graph.design_num                                      = design_num;
                input_graph.roi_name                                        = roi_name;
                input_graph.name_f1                                         = name_f1;
                input_graph.name_f2                                         = name_f2;
                input_graph.levels_f1                                       = levels_f1;
                input_graph.levels_f2                                       = levels_f2;
                input_graph.ersp_curve_fb                                   = ersp_curve_roi_fb;
                input_graph.times                                           = times_plot;
                input_graph.frequency_band_name                             = frequency_bands_names{nband};
                input_graph.pcond                                           = pcond_corr;
                input_graph.pgroup                                          = pgroup_corr;
                input_graph.pinter                                          = pinter_corr;
                input_graph.study_ls                                        = study_ls;
                input_graph.plot_dir                                        = plot_dir;
                input_graph.display_only_significant                        = display_only_significant;
                input_graph.display_compact_plots                           = display_compact_plots;
                input_graph.compact_display_h0                              = compact_display_h0;
                input_graph.compact_display_v0                              = compact_display_v0;
                input_graph.compact_display_sem                             = compact_display_sem;
                input_graph.compact_display_stats                           = compact_display_stats;
                input_graph.display_single_subjects                         = display_single_subjects;
                input_graph.compact_display_xlim                            = compact_display_xlim;
                input_graph.compact_display_ylim                            = compact_display_ylim;
                input_graph.ersp_measure                                    = ersp_measure;
                input_graph.time_windows_design_names                       = group_time_windows_names{design_num};
                input_graph.list_design_subjects                            = list_design_subjects;
                
                eeglab_study_roi_ersp_curve_fb_graph(input_graph);
                
            end
        end
        
        
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).frequency_band_name   = frequency_bands_names{nband};
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).frequency_band        = frequency_bands_list{nband};
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).ersp_curve_roi_fb     = ersp_curve_roi_fb;
        
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).pcond                 = pcond;
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).pgroup                = pgroup;
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).pinter                = pinter;
        
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).statscond             = statscond;
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).statsgroup            = statsgroup;
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).statsinter            = statsinter;
        
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).pcond_corr            = pcond_corr;
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).pgroup_corr           = pgroup_corr;
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).pinter_corr           = pinter_corr;
        
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).dfcond                = dfcond;
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).dfgroup               = dfgroup;
        ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).dfinter               = dfinter;
        
        
        %         ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).narrowband            = narrowband;
        
        
    end
    
    ersp_curve_roi_fb_stat.dataroi(nroi).roi_channels=roi_channels;
    ersp_curve_roi_fb_stat.dataroi(nroi).roi_name=roi_name;
    
end
ersp_curve_roi_fb_stat.times=times_plot;


if strcmp(time_resolution_mode,'tw')
    ersp_curve_roi_fb_stat.group_time_windows_list                 = group_time_windows_list_design;
    ersp_curve_roi_fb_stat.group_time_windows_names                = group_time_windows_names_design;
    ersp_curve_roi_fb_stat.which_extrema_design                    = which_extrema_design_tw;
    ersp_curve_roi_fb_stat.sel_extrema                             = sel_extrema;
    
    if strcmp(mode.peak_type,'individual')
        ersp_curve_roi_fb_stat.subject_time_windows_list = subject_time_windows_list;
    end
end

ersp_curve_roi_fb_stat.list_select_subjects = list_select_subjects;
ersp_curve_roi_fb_stat.list_design_subjects = list_design_subjects;

ersp_curve_roi_fb_stat.study_ls             = study_ls;
ersp_curve_roi_fb_stat.num_permutations     = num_permutations;
ersp_curve_roi_fb_stat.correction           = correction;


%% EXPORTING DATA AND RESULTS OF ANALYSIS
out_file_name = fullfile(plot_dir,'ersp_curve_roi_fb-stat')
save([out_file_name,'.mat'],'ersp_curve_roi_fb_stat','project');

% if ~ ( strcmp(which_method_find_extrema,'group_noalign') || strcmp(which_method_find_extrema,'continuous') );
%     [dataexpcols, dataexp]=text_export_ersp_struct([out_file_name,'.txt'],ersp_curve_roi_fb_stat);
% end


if not( strcmp(which_method_find_extrema,'group_noalign') || strcmp(which_method_find_extrema,'continuous') );
    [dataexpcols, dataexp]=text_export_ersp_struct([out_file_name,'.txt'],ersp_curve_roi_fb_stat);
    %             text_export_ersp_resume_struct(ersp_curve_roi_fb_stat, [out_file_name '_resume']);
    %             text_export_ersp_resume_struct(ersp_curve_roi_fb_stat, [out_file_name '_resume_signif'], 'p_thresh', ersp_curve_roi_fb_stat.study_ls);
    %
end

if  strcmp(which_method_find_extrema,'continuous') ;
    [dataexpcols, dataexp]=text_export_ersp_continuous_struct([out_file_name,'.txt'],ersp_curve_roi_fb_stat);
end

if strcmp(time_resolution_mode,'tw')
    [dataexpcols, dataexp] = text_export_ersp_onset_offset_sub_struct([out_file_name,'_sub_onset_offset.txt'],ersp_curve_roi_fb_stat);
    [dataexpcols, dataexp] = text_export_ersp_onset_offset_avgsub_struct([out_file_name,'_avgsub_onset_offset.txt'],ersp_curve_roi_fb_stat);
    
    [dataexpcols, dataexp] = text_export_ersp_onset_offset_sub_continuous_struct([out_file_name,'_sub_onset_offset_continuous.txt'],ersp_curve_roi_fb_stat);
    [dataexpcols, dataexp] = text_export_ersp_onset_offset_avgsub_continuous_struct([out_file_name,'_avgsub_onset_offset_continuous.txt'],ersp_curve_roi_fb_stat);
end
end
end

% CHANGE LOG
% 14/4/2016
% added text_export_ersp_resume_struct to export singificant values to a text file
% 19/6/15
% added the possibility to calculte narrowband analysis also on the NB COG, not the NB MAX.
