%% EEG = proj_eeglab_subject_microstates(project, varargin)
%
%
% project.microstates.cond_list = {'s-s2-1sc-1tc','s-s2-1sc-1tl','s-s2-1sl-1tc','s-s2-1sl-1tl'}; % condizioni epocate dall'epoching
% project.microstates.micro_selectdata.datatype = 'ERPavg';
% project.microstates.micro_selectdata.avgref = 0;
% project.microstates.micro_selectdata.normalise = 1;
%
% project.microstates.micro_segment.algorithm = 'taahc';
% project.microstates.micro_segment.sorting = 'Global explained variance';
% project.microstates.micro_segment.normalise = 1;
% project.microstates.micro_segment.Nmicrostates = 3:8;
% project.microstates.micro_segment.verbose = 1;
% project.microstates.micro_segment.determinism = 1;
% project.microstates.micro_segment.polarity = 1;
%
% project.microstates.selectNmicro.Nmicro = 4;
%
% project.microstates.micro_fit.polarity = 0;
%
% project.microstates.micro_smooth.label_type ='segmentation';
% project.microstates.micro_smooth.smooth_type ='reject segments';
% project.microstates.micro_smooth.minTime =30;
% project.microstates.micro_smooth.polarity =1;
%
% project.microstates.micro_stats.label_type ='segmentation';
% project.microstates.micro_stats.polarity =0;
%
%
% project.microstates.MicroPlotSegments.label_type ='segmentation';
% project.microstates.MicroPlotSegments.plotsegnos ='all';
% project.microstates.MicroPlotSegments.plot_time =[];
% project.microstates.MicroPlotSegments.plottopos =1;
function EEG = proj_eeglab_subject_microstates(project, varargin)

analysis_name = 'microstates';
results_path                = project.paths.results;
str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
plot_dir=fullfile(results_path,[analysis_name,'-',str]);
mkdir(plot_dir);

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
custom_suffix = '';

list_select_subjects    = project.subjects.list;
get_filename_step       = 'microstates';
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
% -------------------------------------------------------------------------------------------------------------------------------------

if not(isempty(project.microstates.cond_list))
    tcl = length(project.microstates.cond_list);
    for ncl = 1:tcl
        current_cond_list = project.microstates.cond_list{ncl};
        current_cond_name = project.microstates.cond_names{ncl};
        
        [ALLEEG EEG CURRENTSET] = eeglab;
        
        for subj=1:numsubj
            subj_name       = list_select_subjects{subj};
            
            eeg_input_path  = project.paths.output_epochs;
            tc = length(current_cond_list);
            
            % ----------------------------------------------------------------------------------------------------------------------------
            if not(isempty(current_cond_list))
                for nc=1:tc
                    cond_name                               = current_cond_list{nc};
                    input_file_name                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
                    [input_path,input_name_noext,input_ext] = fileparts(input_file_name);
                    
                    if exist(input_file_name, 'file')
                        tmpEEG                 = pop_loadset(input_file_name);
                        tmpEEG = pop_select(tmpEEG,'channel' ,1:project.eegdata.nch_eeg);
                        tmpEEG = eeg_checkset(tmpEEG);
                        ALLEEG = eeg_store(ALLEEG,tmpEEG, CURRENTSET);
                    end
                end
            end
        end
        
        times_ms = tmpEEG.times;
        xmin_ms = tmpEEG.xmin;
        xmax_ms = tmpEEG.xmax;
        
        
        tset = length(ALLEEG);
        % % % % end
        eeglab redraw
        
        
        % [EEG, ALLEEG, CURRENTSET, NewEEG] =....
        %     pop_micro_selectdata( EEG, ALLEEG, ...
        %                          'datatype', 'ERPavg', ...
        %                          'avgref', 0, ...
        %                          'normalise', 0,...
        %                          'dataset_idx', 1:length(ALLEEG) );
        
        [EEG, ALLEEG, CURRENTSET, NewEEG] =....
            pop_micro_selectdata( EEG, ALLEEG, ...
            'datatype', project.microstates.micro_selectdata.datatype, ...
            'avgref', project.microstates.micro_selectdata.avgref, ...
            'normalise', project.microstates.micro_selectdata.normalise,...
            'dataset_idx', 1:length(ALLEEG) );
        EEG.times = times_ms;
        EEG.xmin = xmin_ms;
        EEG.xmax = xmax_ms;
        
        
        eeglab redraw
        ind_ms_set = tset+1;
        [ALLEEG EEG] = eeg_store(ALLEEG, NewEEG, ind_ms_set);
        eeglab redraw
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, ind_ms_set,'overwrite','on','gui','off');
        eeglab redraw
        
        % EEG = pop_micro_segment( EEG, ...
        %                         'algorithm', 'taahc', ...
        %                         'sorting', 'Global explained variance',...
        %                         'normalise', 1, ...
        %                         'Nmicrostates', 3:8,...
        %                         'verbose', 1,...
        %                         'determinism', 1,...
        %                         'polarity', 1 );
        EEG.times = times_ms;
        EEG.xmin = xmin_ms;
        EEG.xmax = xmax_ms;
        
        EEG = pop_micro_segment( EEG, ...
            'algorithm', project.microstates.micro_segment.algorithm, ...
            'sorting', project.microstates.micro_segment.sorting,...
            'normalise', project.microstates.micro_segment.normalise, ...
            'Nmicrostates', project.microstates.micro_segment.Nmicrostates,...
            'verbose', project.microstates.micro_segment.verbose,...
            'determinism', project.microstates.micro_segment.determinism,...
            'polarity', project.microstates.micro_segment.polarity );
        
        
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        
        % EEG = pop_micro_selectNmicro( EEG,...
        %                             'Nmicro', 4 );
        
        EEG.times = times_ms;
        EEG.xmin = xmin_ms;
        EEG.xmax = xmax_ms;
        
        EEG = pop_micro_selectNmicro( EEG,...
            'Nmicro', project.microstates.selectNmicro.Nmicro );
        
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        
        % EEG = pop_micro_fit( EEG,...
        %                     'polarity', 0 );
        
        EEG.times = times_ms;
        EEG.xmin = xmin_ms;
        EEG.xmax = xmax_ms;
        
        EEG = pop_micro_fit( EEG,...
            'polarity', project.microstates.micro_fit.polarity );
        
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        
        % EEG = pop_micro_smooth( EEG, ...
        %                         'label_type', 'segmentation',...
        %                         'smooth_type', 'reject segments',...
        %                         'minTime', 30,...
        %                         'polarity', 1 );
        
        EEG.times = times_ms;
        EEG.xmin = xmin_ms;
        EEG.xmax = xmax_ms;
        
        EEG = pop_micro_smooth( EEG, ...
            'label_type', project.microstates.micro_smooth.label_type,...
            'smooth_type', project.microstates.micro_smooth.smooth_type,...
            'minTime', project.microstates.micro_smooth.minTime,...
            'polarity', project.microstates.micro_smooth.polarity );
        
        
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        % EEG = pop_micro_stats( EEG,...
        %                        'label_type', 'segmentation',...
        %                        'polarity', 0 );
        
        EEG.times = times_ms;
        EEG.xmin = xmin_ms;
        EEG.xmax = xmax_ms;
        
        EEG = pop_micro_stats( EEG,...
            'label_type', project.microstates.micro_stats.label_type,...
            'polarity', project.microstates.micro_stats.polarity );
        
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        
        fig=figure( 'color', 'w', 'Visible', 'off');
        % MicroPlotSegments( EEG, ...
        %                    'label_type', 'segmentation',...
        %                    'plotsegnos', 'all',...
        %                    'plot_time', [],...
        %                    'plottopos', 1 );
        
        
        EEG.times = times_ms;
        EEG.xmin = xmin_ms;
        EEG.xmax = xmax_ms;
        
        MicroPlotSegments( EEG, ...
            'label_type', project.microstates.MicroPlotSegments.label_type,...
            'plotsegnos', project.microstates.MicroPlotSegments.plotsegnos,...
            'plot_time', project.microstates.MicroPlotSegments.plot_time,...
            'plottopos', project.microstates.MicroPlotSegments.plottopos );
        
        handles=findobj(fig,'Type','axes');
        axes(handles((project.microstates.selectNmicro.Nmicro+1)))
        ylim manual
        ylim(project.microstates.MicroPlotSegments.plot_ylim)
        
        str =  ['microstates','_',project.microstates.suffix];
        str2 = [str,'_',current_cond_name];
        
        suptitle(str2)
        
        input_save_fig.plot_dir               = plot_dir;
        input_save_fig.fig                    = fig;
        input_save_fig.name_embed             = str;
        input_save_fig.suffix_plot            = current_cond_name;
        save_figures( input_save_fig , 'renderer', 'opengl');
        
        EEG.filename = str2;
        EEG.filepath = eeg_input_path;
        
        EEG.times = times_ms;
        EEG.xmin = xmin_ms;
        EEG.xmax = xmax_ms;
        
        EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',EEG.filepath);
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


