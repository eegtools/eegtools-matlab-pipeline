%% [STUDY, EEG] = proj_eeglab_study_export_allch_ersp_single_trial(project, analysis_name, mode, varargin)
%
% export ersp single trial

function [ersp_single_trial_dir] = proj_eeglab_study_export_roi_ersp_single_trial(project, varargin)

if nargin < 1
    help proj_eeglab_study_export_allch_ersp_single_trial;
    return;
    
end


list_select_subjects    = project.subjects.list;
get_filename_step       = 'input_import_data';
custom_suffix           = '';
custom_input_folder     = '';
import_out_suffix   = project.import.output_suffix;
design_num_vec              = [1:length(project.design)];

% allch_list                    = project.postprocess.ersp.allch_list;
% allch_names                   = project.postprocess.ersp.allch_names;

roi_list = project.postprocess.ersp.roi_list;
roi_names = project.postprocess.ersp.roi_names;



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

set_caxis = project.results_display.ersp.set_caxis_tf;
if isempty(set_caxis)
    set_caxis = [-1,1];
end

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'get_filename_step',    ...
                'custom_input_folder',  ...
                'custom_suffix' ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
numsubj = length(list_select_subjects);



epochs_path         = project.paths.output_epochs;


study_path                  = fullfile(project.paths.output_epochs, project.study.filename);
results_path                = project.paths.results;  


str                                    = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
    
ersp_single_trial_dir=fullfile(results_path,['ersp_single_trial','-',str]);
mkdir(ersp_single_trial_dir);


% ersp_single_trial_dir = fullfile(epochs_path,'ersp_single_trial');
% if not(exist(ersp_single_trial_dir))
%     mkdir(ersp_single_trial_dir);
% end

plot_dir = fullfile(ersp_single_trial_dir,'plot');
if not(exist(plot_dir))
    mkdir(plot_dir);
end

% current_data_pow_roi_allsub = 0;
% pow_corr_addictive_roi_allsub = 0;
% pow_corr_divisive_roi_allsub = 0;
% pow_corr_full_roi_allsub = 0;


for subj=1:numsubj
    
    data_out = [];
    
    subj_name               = list_select_subjects{subj};
    
    input_file_name = [...
        project.import.original_data_prefix,...
        subj_name,...
        project.import.original_data_suffix,...
        import_out_suffix project.epoching.input_suffix '.dattimef'];
    
    input_file_path=fullfile(epochs_path,input_file_name,'');
    
    disp(input_file_path);
    
    baseline_lim_ms = [project.epoching.bc_st.ms, project.epoching.bc_end.ms];
    
    
    
    ersp_struct = load(input_file_path, '-mat');
    event_fields = fieldnames(ersp_struct.trialinfo);
    
    
    tch = length(ersp_struct.labels);
    ttimes= length(ersp_struct.times);
    tfreqs = length(ersp_struct.freqs);
    ttrials = length(ersp_struct.trialinfo);
    
    data_out.freqsout = repmat(ersp_struct.freqs',ttimes*ttrials,1);
    
    timesout_mat = repmat(ersp_struct.times,tfreqs,1);
    timesout_vec = reshape(timesout_mat,ttimes*tfreqs,1);
    data_out.timesout = repmat(timesout_vec,ttrials,1);
    
    trialinfo_names = fieldnames(ersp_struct.trialinfo);
    ttin = length(trialinfo_names);
    
    for ntin = 1:ttin
        current_field = trialinfo_names{ntin};
        current_info = {ersp_struct.trialinfo.(current_field)};
        current_info_mat = repmat(current_info,tfreqs*ttimes,1);
        current_info_vec = reshape(current_info_mat,tfreqs*ttimes*ttrials,1);
        
        str_current_info = ['data_out.',current_field, '=','current_info_vec;'];
        eval(str_current_info);
        
    end
    
    
    %     project.postprocess.ersp.roi_list = { ...
    %             {'F5','F7','AF7','FT7'};  ... left IFG
    %           {'F6','F8','AF8','FT8'};  ... right IFG
    %           {'FC3','FC5'};            ... l PMD
    %           {'FC4','FC6'};            ... r PMD
    %           {'C3'};                   ... iM1 hand
    %           {'C4'};                   ... cM1 hand
    %           {'Cz'}
    % };
    % project.postprocess.ersp.roi_names                              = {'contralateral-SM1','ipsilateral-SM1','SMA','ipsilateral-PMd','contralateral-PMd','ipsilateral-ifg','contralateral-ifg'}; ... ,'left-ipl','right-ipl','left-spl','right-spl','left-sts','right-sts','left-occipital','right-occipital'};
    % project.postprocess.ersp.numroi                                 = length(project.postprocess.ersp.roi_list);
    %
    
    for nroi = 1:project.postprocess.ersp.numroi
        current_roi_ch = project.postprocess.ersp.roi_list{nroi};
        current_roi_name =project.postprocess.ersp.roi_names{nroi};
        vch_roi = find(ismember(ersp_struct.labels,current_roi_ch));
        disp(current_roi_name);
        current_data_pow_roi = [];
        pow_corr_addictive_roi = [];
        pow_corr_divisive_roi=[];
        pow_corr_full_roi= [];
        
        
        for nch = vch_roi
            tch_roi = length(vch_roi);
            current_lab = ersp_struct.labels{nch};
            current_chan = ['chan',num2str(nch)];
            disp(current_lab);
            str_command = ['current_data = ','ersp_struct.' current_chan,';'];
            eval(str_command);
            current_data_pow = current_data.*conj(current_data);
            sel_baseline = ersp_struct.times >= baseline_lim_ms(1) & ersp_struct.times <= baseline_lim_ms(2);
            current_data_pow_baseline = current_data_pow(:,sel_baseline,:);
            
            
            mean_current_data_pow_baseline = mean(current_data_pow_baseline,2);
            rep_current_data_pow_baseline = repmat(mean_current_data_pow_baseline,[1,ttimes,1]);
            
            
            mean_current_data_pow_epoch = mean(current_data_pow,2);
            rep_current_data_pow_epoch = repmat(mean_current_data_pow_epoch,[1,ttimes,1]);
            
            
            pow_corr_addictive = current_data_pow - rep_current_data_pow_baseline;
            
            pow_corr_divisive = current_data_pow ./ rep_current_data_pow_baseline;
            
            pow_corr_divisive_epoch = current_data_pow ./ rep_current_data_pow_epoch;
            
            
            
            pow_corr_divisive_epoch_baseline = pow_corr_divisive_epoch(:,sel_baseline,:);
            mean_pow_corr_divisive_epoch_baseline = mean(pow_corr_divisive_epoch_baseline,2);
            rep_pow_corr_divisive_epoch_baseline = repmat(mean_pow_corr_divisive_epoch_baseline,[1,ttimes,1]);
            pow_corr_full = pow_corr_divisive_epoch ./ rep_pow_corr_divisive_epoch_baseline;
            
            
%             th=5;
            sel_pow_corr_full = pow_corr_full<set_caxis(1);
            pow_corr_full(sel_pow_corr_full) = nan;%set_caxis(1);
            
            
            sel_pow_corr_full = pow_corr_full>set_caxis(2);
            pow_corr_full(sel_pow_corr_full) = nan;%set_caxis(2);
            
            
            current_data_pow_roi(:,:,:,nch) =  current_data_pow;
            pow_corr_addictive_roi(:,:,:,nch) =  pow_corr_addictive;
            pow_corr_divisive_roi(:,:,:,nch)= pow_corr_divisive;
            pow_corr_full_roi (:,:,:,nch)= pow_corr_full;
            
            
        end
        
        current_data_pow_roi = squeeze(nanmean(current_data_pow_roi,4));%./tch_roi;
        pow_corr_addictive_roi = squeeze(nanmean(pow_corr_addictive_roi,4));%./tch_roi;
        pow_corr_divisive_roi= squeeze(nanmean(pow_corr_divisive_roi,4));%./tch_roi;
        pow_corr_full_roi= squeeze(nanmean(pow_corr_full_roi,4));%./tch_roi;
        
        data_out.pow_ncorr = reshape(current_data_pow_roi,[tfreqs*ttimes*ttrials,1]);
        data_out.pow_corr_addictive = reshape(pow_corr_addictive_roi,[tfreqs*ttimes*ttrials,1]);
        data_out.pow_corr_divisive = reshape(pow_corr_divisive_roi,[tfreqs*ttimes*ttrials,1]);
        data_out.pow_corr_full = reshape(pow_corr_full_roi,[tfreqs*ttimes*ttrials,1]);
        
        out_name = [subj_name,'_',current_roi_name];
        
        data_out_cell = struct2table(data_out);
        outpath_ersp_txt = fullfile(ersp_single_trial_dir,[out_name,'.txt']);
        writetable(data_out_cell,outpath_ersp_txt,"Delimiter" ,"\t");
        disp(outpath_ersp_txt);
        trialinfo_catsub = {ersp_struct.trialinfo.condition_catsub};
        catsub_levels = unique(trialinfo_catsub);
        
        
        outpath_ersp_mat = fullfile(ersp_single_trial_dir,[out_name,'.mat']);
        
        times_ersp = ersp_struct.times;
        freqs_ersp = ersp_struct.freqs;
        trialinfo = ersp_struct.trialinfo;
        
        save(outpath_ersp_mat,...
            'current_data_pow_roi','pow_corr_addictive_roi',...
            'pow_corr_divisive_roi','pow_corr_full_roi',...
            'times_ersp','freqs_ersp','trialinfo')
        
        for ncl = 1:length(catsub_levels)
            
            current_catsub_level = catsub_levels{ncl};
            sel_catsub_level = ismember(trialinfo_catsub,current_catsub_level);
            
            ersp_out(ncl,nroi).current_data_pow_roi(:,:,subj) = squeeze(nanmean(current_data_pow_roi(:,:,sel_catsub_level),3));
            ersp_out(ncl,nroi).pow_corr_addictive_roi(:,:,subj) = squeeze(nanmean(pow_corr_addictive_roi(:,:,sel_catsub_level),3));
            ersp_out(ncl,nroi).pow_corr_divisive_roi(:,:,subj) = squeeze(nanmean(pow_corr_divisive_roi(:,:,sel_catsub_level),3));
            ersp_out(ncl,nroi).pow_corr_full_roi(:,:,subj) = squeeze(nanmean(pow_corr_full_roi(:,:,sel_catsub_level),3));
            ersp_out(ncl,nroi).roi = current_roi_name;
            ersp_out(ncl,nroi).catsub_level = current_catsub_level;
            ersp_out(ncl,nroi).times_ersp = times_ersp;
            ersp_out(ncl,nroi).freqs_ersp = freqs_ersp;
            
        end
        
    end
end

outpath_ersp_out_mat = fullfile(ersp_single_trial_dir,['ersp_out','.mat']);
save(outpath_ersp_out_mat,'ersp_out')
list_normalizations = {'pow_corr_full_roi'};...{'pow_corr_addictive_roi','pow_corr_divisive_roi','pow_corr_full_roi'};
for nln = 1:length(list_normalizations)
    current_normalization = list_normalizations{nln} ;
    disp(current_normalization);
    for ncl = 1:length(catsub_levels)
        
        current_catsub_level = catsub_levels{ncl};
        for nroi = 1:project.postprocess.ersp.numroi
            %         current_roi_ch = project.postprocess.ersp.roi_list{nroi};
            current_roi_name =project.postprocess.ersp.roi_names{nroi};
            %         vch_roi = find(ismember(ersp_struct.labels,current_roi_ch));
            disp(current_roi_name);
            
            
            
            tf_mat_uv2 = ersp_out(ncl,nroi).(current_normalization);
%             th=5;
%             sel_tf_mat_uv2 = tf_mat_uv2>th;
%             tf_mat_uv2(sel_tf_mat_uv2) = th;
            tf_mat_pfu= tf_mat_uv2*100;
            tf_mat_cell = {tf_mat_uv2,tf_mat_pfu};
            tf_label = {'AU','%'};
             tf_set_caxis={set_caxis,set_caxis*100}  ; 
            for nplot = 1:length(tf_label)
                current_set_caxis = tf_set_caxis{nplot};
                tf_mat = tf_mat_cell{nplot};
                sel_t_baseline = ...
                    times_ersp >= project.epoching.bc_st.ms & ...
                    times_ersp <= project.epoching.bc_end.ms;
                tf_mat_baseline = tf_mat(:,sel_t_baseline,:);
                tfmean_baseline = mean(tf_mat_baseline,2);
                tfmean_baseline_rep = repmat(tfmean_baseline,1,length(times_ersp),1);
                
                tf_mat_norm = tf_mat-tfmean_baseline_rep;
                tf_mat_zeros = zeros(size(tfmean_baseline_rep));
                %             cell_comparison = {tf_mat_norm,tf_mat_zeros};
                
                cell_comparison = {tf_mat,tfmean_baseline_rep};
                
%                 [t df pvals surog] = statcond_corr(cell_comparison, num_tails, 'method', stat_method, 'naccu', num_permutations,'paired', 'on');
%                 corrected_pvals = mcorrect(pvals, correction);
%                 masked_pvals = corrected_pvals < study_ls;
%                 
                
                
                tf_plot = (squeeze(mean(tf_mat,3)))';
                
                
                
%                 tf_plot_masked = tf_plot .* masked_pvals';
                
                fig=figure( 'color', 'w', 'Visible', 'off');
                
                
                subplot(1,2,1);
                imagesc(times_ersp,freqs_ersp,tf_plot);
                set(gca,'YDir','normal');
                
                xlabel('Time (ms)');
                ylabel('Freq (Hz)');
                caxis(current_set_caxis);
                line('XData', [0 0], 'YData', [1 max(freqs_ersp)], 'LineStyle', '--','LineWidth', 2, 'Color','k');
                for nfb = 1:length(frequency_bands_list)
                    current_band = frequency_bands_list{nfb};
                    for nf = 1:2
                        line('XData', [times_ersp(1) times_ersp(end)], 'YData', [current_band(nf) current_band(nf)], 'LineStyle', '--','LineWidth', 2, 'Color','k')
                        
                    end
                end
                
                
                
                
                
                
%                 subplot(1,2,2);
%                 imagesc(times_ersp,freqs_ersp,tf_plot_masked);
%                 set(gca,'YDir','normal');
%                 ylabel('Freq (Hz)');
%                 caxis(current_set_caxis);
%                 line('XData', [0 0], 'YData', [1 max(freqs_ersp)], 'LineStyle', '--','LineWidth', 2, 'Color','k');
%                 for nfb = 1:length(frequency_bands_list)
%                     current_band = frequency_bands_list{nfb};
%                     for nf = 1:2
%                         line('XData', [times_ersp(1) times_ersp(end)], 'YData', [current_band(nf) current_band(nf)], 'LineStyle', '--','LineWidth', 2, 'Color','k')
%                         
%                     end
%                 end
                strplot = [current_normalization, '_',current_catsub_level,'-' , current_roi_name];
                suptitle(strplot);
                cbar;
                title(tf_label{nplot});
                
                
                input_save_fig.plot_dir = plot_dir;
                input_save_fig.fig = fig;
                input_save_fig.name_embed = ['ersp_tf_baseline'];
                input_save_fig.suffix_plot = strplot;
                save_figures( input_save_fig );
                
                outpath_ersp_plot_mat = fullfile(ersp_single_trial_dir,['ersp_plot',strplot,'.mat']);
                save(outpath_ersp_plot_mat,...'tf_plot_masked',
                    'strplot','times_ersp','freqs_ersp','frequency_bands_list','tf_plot','cell_comparison',...
                    'num_tails',  'stat_method', 'num_permutations','correction','study_ls','set_caxis','current_catsub_level','current_normalization')
            end
        end
    end
    


    
end
end