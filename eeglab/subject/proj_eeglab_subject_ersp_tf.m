%% EEG = proj_eeglab_subject_add_factor(project, varargin)
%
%%
function EEG = proj_eeglab_subject_ersp_tf(project, varargin)

if sum(ismember({project.study.factors.factor},'condition'))
    disp('the factor name condition is reserved by eeglab: please change name e.g. to cond')
    return
end

if not(isfield(project.epoching, 'custom_suffix') )
    project.epoching.custom_suffix = '';
end

if not(isfield(project.epoching, 'custom_input_folder') )
    project.epoching.custom_input_folder = '';
end

custom_suffix = project.epoching.custom_suffix;
custom_input_folder     = project.epoching.custom_input_folder;


list_select_subjects    = project.subjects.list;
get_filename_step       = 'subject_ersp_tf';
% custom_suffix           = '';
% custom_input_folder     = '';

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

troi = length(project.postprocess.ersp.roi_list);

frequency_bands_list        = project.postprocess.ersp.frequency_bands_list;


str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
results_path                = project.paths.results;
subject_ersp_curve_path = fullfile(results_path,['subject_ersp_tf','_',str]);
if not(exist(subject_ersp_curve_path))
    mkdir(subject_ersp_curve_path)
end

% -------------------------------------------------------------------------------------------------------------------------------------
if not(isempty(project.subject_compare_cond))
    tcomp = length(project.subject_compare_cond);
    
    
    for nroi = 1:troi
        current_roi = project.postprocess.ersp.roi_list{nroi};
        current_roi_name = project.postprocess.ersp.roi_names{nroi};
        
        for subj=1:numsubj
            subj_name       = list_select_subjects{subj};
            
            eeg_input_path  = project.paths.output_epochs;
            close all
            
            str_plot = [current_roi_name,'_', subj_name];
            
            
            for ncomp = 1:tcomp
                current_comparison = project.subject_compare_cond{ncomp};
                tcond = length(current_comparison);
                
                
                
                %                     fig = figure;
                fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
                for nc=1:tcond
                    cond_name                               = current_comparison{nc};
                    
                    % ----------------------------------------------------------------------------------------------------------------------------
                    
                    input_file                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
                    [input_path,input_name_noext,input_ext] = fileparts(input_file);
                    
                    if exist(input_file, 'file')
                        [fpath,fname,fext] = fileparts(input_file);
                        EEG = pop_loadset('filepath',fpath,'filename',[fname,fext]);
                        allch = {EEG.chanlocs.labels};
                        %                         ersp_curve_allch = squeeze(mean(EEG.data,3));
                        sel_ch = ismember(allch,current_roi);
                        ersp_curve_roi = squeeze(mean(EEG.data(sel_ch,:,:),1));
                        
                        
                        
                        subplot(1,tcond,nc)
                        
                        
                        [ersp,itc,powbase,times,freqs,erspboot,itcboot] = ...
                            newtimef(ersp_curve_roi, EEG.pnts, [EEG.xmin EEG.xmax]*1000, ...
                            EEG.srate, project.study.ersp.cycles,...
                            'timesout',project.study.ersp.timeout_analysis_interval.ms,...
                            'freqs',project.study.ersp.freqout_analysis_interval,...
                            'padratio',project.study.ersp.padratio,...
                            'plotersp','off',...
                            'plotitc','off',...
                            'plotphasesign','off',...
                            'plotphaseonly','off'...
                            );
                        
                        
                        imagesc(times,freqs,ersp);
                        title(cond_name);
                        
                        set(gca,'YDir','normal');
                        
                        xlabel('Time (ms)');
                        ylabel('Freq (Hz)');
                        if not(isempty(project.results_display.ersp.set_caxis_tf))
                            caxis(project.results_display.ersp.set_caxis_tf);
                        end
                        line('XData', [0 0], 'YData', [1 max(freqs)], 'LineStyle', '--','LineWidth', 2, 'Color','k');
                        for nfb = 1:length(frequency_bands_list)
                            current_band = frequency_bands_list{nfb};
                            for nf = 1:2
                                line('XData', [times(1) times(end)], 'YData', [current_band(nf) current_band(nf)], 'LineStyle', '--','LineWidth', 2, 'Color','k')
                                
                            end
                        end
                        
                        
                        
                        
                        cbar;
                        title('ERSP(dB)');
                        
                        %                         plot(EEG.times,ersp_curve_roi);
                        hold on
                    else
                        disp(['error: condition file name (' input_name_noext ') not found!!!! exiting .....']);
                    end
                end
                if not(isempty(project.results_display.ersp.compact_display_ylim))
                    ylim(project.results_display.ersp.compact_display_ylim);
                end
                
                %                 yline(0,'--');
                %                 xline(0,'--');
                %                 xlabel('Times (ms)');
                %                 ylabel('ersp (uV)');
                %                 legend(current_comparison)
                
                suptitle(str_plot);

                
                inputsf.plot_dir    = subject_ersp_curve_path;
                inputsf.fig         = fig;
                inputsf.name_embed  = 'subject_ersp_tf';
                inputsf.suffix_plot = str_plot;
                save_figures(inputsf,'res','-r100','exclude_format','svg');
                close all
            end
            
            
        end
    end
end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name


