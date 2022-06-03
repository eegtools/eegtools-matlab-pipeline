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



%% copy forked functions into vised eeglab directory (to recover, remove and git pull)
MicroStats_m = fullfile(project.paths.framework_root,'eeg_tools','utilities',['MicroStats.m']);

eeglab_plugin_dir = fullfile(project.paths.eeglab, 'plugins');
dir_list = dir(eeglab_plugin_dir);
eeglab_plugin_list = {dir_list.name};
select_plugin = strfind_index(eeglab_plugin_list,'MST');
MicroStats_m_dir = eeglab_plugin_list{select_plugin};
export_MicroStats_m_dir = fullfile(project.paths.eeglab, 'plugins',MicroStats_m_dir);
copyfile( fullfile(export_MicroStats_m_dir,'MicroStats.m'), fullfile(export_MicroStats_m_dir,[str,'MicroStats.m']));

copyfile( MicroStats_m, export_MicroStats_m_dir);



% ms_dir=fullfile(plot_dir,'ms');
% mkdir(ms_dir);
% 
% gevtotal_dir=fullfile(plot_dir,'gevtotal');
% mkdir(gevtotal_dir);
% 
% mat_dir=fullfile(plot_dir,'mat');
% mkdir(mat_dir);

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
if isempty(project.microstates.group_list)
    project.microstates.group_list = project.subjects.group_names;
end
vec_select_groups  = find(ismember(project.subjects.group_names,  project.microstates.group_list));


for ng = vec_select_groups
    list_select_subjects_g = intersect(list_select_subjects,project.subjects.groups{ng});
    
    if not(isempty(list_select_subjects_g))
        
        numsubj = length(list_select_subjects_g);
        % -------------------------------------------------------------------------------------------------------------------------------------
        
        if project.microstates.do_spontaneous
            microstate_type = 'spontaneous';
            str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
            str2 = [str,'_',project.subjects.group_names{ng}];
            
            type_dir = fullfile(plot_dir,microstate_type);
            ms_dir=fullfile(type_dir,'ms');
            mkdir(ms_dir);
            
            gevtotal_dir=fullfile(type_dir,'gevtotal');
            mkdir(gevtotal_dir);
            
            mat_dir=fullfile(type_dir,'mat');
            mkdir(mat_dir);
            
            
            get_filename_step       = ['microstates_',microstate_type];
            if project.microstates.do_backfit
                project.microstates.do_selectdata = 1;
            end
            if project.microstates.do_selectdata
                [ALLEEG EEG CURRENTSET] = eeglab;
                for subj=1:numsubj
                    subj_name       = list_select_subjects_g{subj};
                    eeg_input_path  = project.paths.output_epochs;
                    input_file_name             = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
                    [input_path,input_name_noext,input_ext] = fileparts(input_file_name);
                    
                    
                    if exist(input_file_name, 'file')
                        input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
                        try
                            tmpEEG                     = pop_loadset(input_file_name);
                        catch
                            [fpath,fname,fext] = fileparts(input_file_name);
                            tmpEEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
                        end
%                         tmpEEG                 = pop_loadset(input_file_name);
                        tmpEEG = pop_select(tmpEEG,'channel' ,1:project.eegdata.nch_eeg);
                        tmpEEG = eeg_checkset(tmpEEG);
                        ALLEEG = eeg_store(ALLEEG,tmpEEG, CURRENTSET);
                    end
                    
                    
                    times_ms = tmpEEG.times;
                    xmin_ms = tmpEEG.xmin;
                    xmax_ms = tmpEEG.xmax;
                    
                    
                    tset = length(ALLEEG);
                    eeglab redraw
                    
                end
                
                
                
                [EEG, ALLEEG, CURRENTSET, NewEEG] =....
                    pop_micro_selectdata( EEG, ALLEEG, ...
                    'datatype', microstate_type, ...
                    'avgref', project.microstates.micro_selectdata.avgref, ...
                    'normalise', project.microstates.micro_selectdata.normalise,...
                    'MinPeakDist',project.microstates.micro_selectdata.MinPeakDist,...
                    'Npeaks',project.microstates.micro_selectdata.Npeaks,...
                    'GFPthresh',project.microstates.micro_selectdata.GFPthresh,...
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
                
                
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                
                
            end
            
            if project.microstates.do_segment
                
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                
                
                EEG = pop_micro_segment( EEG, ...
                    'algorithm', project.microstates.micro_segment.algorithm, ...
                    'sorting', project.microstates.micro_segment.sorting,...
                    'normalise', project.microstates.micro_segment.normalise, ...
                    'Nmicrostates', project.microstates.micro_segment.Nmicrostates,...
                    'verbose', project.microstates.micro_segment.verbose,...
                    'determinism', project.microstates.micro_segment.determinism,...
                    'polarity', project.microstates.micro_segment.polarity );
                
                
                [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                
                EEG.times = times_ms;
                EEG.xmin = xmin_ms;
                EEG.xmax = xmax_ms;
                
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                
                
                
            end
            
            
            
            if project.microstates.do_viewNmicro
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                %open figure to select
                EEG = pop_micro_selectNmicro( EEG );
            end
            if project.microstates.do_selectNmicro
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                EEG = pop_micro_selectNmicro( EEG,...
                    'Nmicro', project.microstates.selectNmicro.Nmicro_spontaneous );
                [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                
            end
            
            if project.microstates.do_fit
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                
                % EEG = pop_micro_fit( EEG,...
                %                     'polarity', 0 );
                
                EEG.times = times_ms;
                EEG.xmin = xmin_ms;
                EEG.xmax = xmax_ms;
                
                EEG = pop_micro_fit( EEG,...
                    'polarity', project.microstates.micro_fit.polarity );
                
                [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                
                
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                
                EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                
                
                % EEG = pop_micro_smooth( EEG, ...
                %                         'label_type', 'segmentation',...
                %                         'smooth_type', 'reject segments',...
                %                         'minTime', 30,...
                %                         'polarity', 1 );
                
                EEG.times = times_ms;
                EEG.xmin = xmin_ms;
                EEG.xmax = xmax_ms;
            end
            
            
            if project.microstates.do_smooth
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                
                EEG = pop_micro_smooth( EEG, ...
                    'label_type', project.microstates.micro_smooth.label_type,...
                    'smooth_type', project.microstates.micro_smooth.smooth_type,...
                    'minTime', project.microstates.micro_smooth.minTime,...
                    'polarity', project.microstates.micro_smooth.polarity );
                
                
                [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                
                EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                
                % EEG = pop_micro_stats( EEG,...
                %                        'label_type', 'segmentation',...
                %                        'polarity', 0 );
                
                EEG.times = times_ms;
                EEG.xmin = xmin_ms;
                EEG.xmax = xmax_ms;
                
            end
            
            if project.microstates.do_stats
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                EEG = pop_micro_stats( EEG,...
                    'label_type', project.microstates.micro_stats.label_type,...
                    'polarity', project.microstates.micro_stats.polarity );
                
                [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                
%                 str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                 str2 = [str,'_',project.subjects.group_names{ng}];
                
                EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                
            end
            
            if project.microstates.do_backfit
                outpath_gevtotal = fullfile(gevtotal_dir,'gevtotal.txt');
                fid_gevtotal = fopen(outpath_gevtotal, 'a+');
                fprintf(fid_gevtotal, '%s\t%s\n','subject','gevtotal');
                for nf = 1:tset
                    fprintf('Importing prototypes and backfitting for dataset %i\n',nf)
                    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',nf,'study',0);
                    EEG = pop_micro_import_proto( EEG, ALLEEG, ind_ms_set);
                    
                    
                    %% 3.6 Back-fit microstates on EEG
                    EEG = pop_micro_fit( EEG, 'polarity', 0 );
                    %% 3.7 Temporally smooth microstates labels
                    % EEG = pop_micro_smooth( EEG, 'label_type', 'backfit', ...
                    % 'smooth_type', 'reject segments', ...
                    % 'minTime', 30, ...
                    % 'polarity', 0 );
                    
                    EEG = pop_micro_smooth( EEG, ...
                        'label_type', 'backfit',...
                        'smooth_type', project.microstates.micro_smooth.smooth_type,...
                        'minTime', project.microstates.micro_smooth.minTime,...
                        'polarity', project.microstates.micro_smooth.polarity );
                    %% 3.9 Calculate microstate statistics
                    EEG = pop_micro_stats( EEG, 'label_type', 'backfit', ...
                        'polarity', 0 );
                    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                    fout  = [EEG.filename(1:end-4)];
                    %                     fout  = [EEG.filename(1:end-4),'_ms'];
                    EEG = pop_saveset( EEG, 'filename',[fout,'.set'],'filepath',input_path);
                    allfields = fields(EEG.microstate.stats) ;
                    
                    fields2keep = {'Gfp','Occurence','Duration','Coverage','GEV','MspatCorr'};
                    select_fields = not(ismember(allfields,fields2keep));
                    fields2rm = allfields(select_fields);
                    data_ms = rmfield(EEG.microstate.stats,fields2rm);
                    data_ms.microstate = 1:length(data_ms.Coverage);
                    data_ms = structfun(@transpose,data_ms,'UniformOutput',false);
                    data_ms = struct2table(data_ms);
                    outpath_ms = fullfile(ms_dir,[fout,'_ms','.txt']);
                    writetable(data_ms,outpath_ms,"Delimiter" ,"\t")
                    
                    fprintf(fid_gevtotal, '%s\t%d\n',fout,EEG.microstate.stats.GEVtotal);
                    
                    tmat = numel(EEG.microstate.stats.TP);
                    LIDX = 1:tmat;
                    data_mat.TP = reshape(EEG.microstate.stats.TP,1,tmat);
                    [data_mat.row, data_mat.col] = ind2sub(size(EEG.microstate.stats.TP), LIDX);
                    
                    data_mat = structfun(@transpose,data_mat,'UniformOutput',false);
                    data_mat = struct2table(data_mat);
                    outpath_mat = fullfile(mat_dir,[fout,'_mat','.txt']);
                    writetable(data_mat,outpath_mat,"Delimiter" ,"\t")
                    
                    clear data_mat data_ms
                end
                fclose(fid_gevtotal);
            end
            
        end
        if project.microstates.do_ERPavg
            microstate_type = 'ERPavg';
            
            type_dir = fullfile(plot_dir,microstate_type);
            ms_dir=fullfile(type_dir,'ms');
            mkdir(ms_dir);
            
            gevtotal_dir=fullfile(type_dir,'gevtotal');
            mkdir(gevtotal_dir);
            
            mat_dir=fullfile(type_dir,'mat');
            mkdir(mat_dir);
            
            get_filename_step       = ['microstates_',microstate_type];
            
            if project.microstates.do_backfit
                project.microstates.do_selectdata = 1;
            end
            
            tcl = length(project.microstates.cond_list);
            for ncl = 1:tcl
                current_cond_list = project.microstates.cond_list{ncl};
                current_cond_name = project.microstates.cond_names{ncl};
                
                str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
                str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                
                [ALLEEG EEG CURRENTSET] = eeglab;
                if project.microstates.do_selectdata
                    for subj=1:numsubj
                        subj_name       = list_select_subjects_g{subj};
                        
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
                        'datatype', microstate_type, ...
                        'avgref', project.microstates.micro_selectdata.avgref, ...
                        'normalise', project.microstates.micro_selectdata.normalise,...
                        ... 'MinPeakDist',project.microstates.micro_selectdata.MinPeakDist,...
                        ...'Npeaks',project.microstates.micro_selectdata.Npeaks,...
                        ...'GFPthresh',project.microstates.micro_selectdata.GFPthresh,...
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
                    
%                     str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                     str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                    EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                    
                    
                end
                
                if project.microstates.do_segment
                    
%                     str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                     str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                    EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                    
                    
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
                    
                    
%                     str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                     str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                    EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                    
                    
                end
                
                
                if project.microstates.do_viewNmicro
%                     str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                     str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                    EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                    %open figure to select
                    EEG = pop_micro_selectNmicro( EEG );
                end
                
                
                if project.microstates.do_selectNmicro
%                     str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                     str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                    EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                    
                    EEG = pop_micro_selectNmicro( EEG,...
                        'Nmicro', project.microstates.selectNmicro.Nmicro_ERPavg(ncl) );
                    
                    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                    
                    
                    % EEG = pop_micro_fit( EEG,...
                    %                     'polarity', 0 );
                    
                    EEG.times = times_ms;
                    EEG.xmin = xmin_ms;
                    EEG.xmax = xmax_ms;
                    
                    EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                    
                end
                if project.microstates.do_fit
%                     str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                     str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                    EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                    
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
                    
                    EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                    
                    
                end
                if project.microstates.do_smooth
                    
%                     str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                     str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                    EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                    
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
                    
                    EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                    
                end
                
                
                if project.microstates.do_stats
                    
%                     str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                     str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                    EEG = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                    
                    
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
                    axes(handles((project.microstates.selectNmicro.Nmicro_ERPavg(ncl)+1)))
                    ylim manual
                    ylim(project.microstates.MicroPlotSegments.plot_ylim)
                    
%                     str =  ['microstates','_',project.microstates.suffix];
%                     str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                    
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
                    
                    EEG = pop_saveset( EEG, 'filename',[str2,'.set'],'filepath',input_path);
                    
                    
                end
                
                if project.microstates.do_backfit
                    
%                     str =  ['microstates','_',microstate_type,'_',project.microstates.suffix];
%                     str2 = [str,'_',project.subjects.group_names{ng},'_',current_cond_name];
                    [ NewEEG] = pop_loadset( 'filename',[str2,'.set'],'filepath',input_path);
                    
                    eeglab redraw
                    ind_ms_set = tset+1;
                    [ALLEEG EEG] = eeg_store(ALLEEG, NewEEG, ind_ms_set);
                    eeglab redraw
%                     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, ind_ms_set,'overwrite','on','gui','off');
%                     eeglab redraw                    
                    outpath_gevtotal = fullfile(gevtotal_dir,['gevtotal','_',current_cond_name,'.txt']);
                    fid_gevtotal = fopen(outpath_gevtotal, 'a+');
                    fprintf(fid_gevtotal, '%s\t%s\n','subject','gevtotal');
                    for nf = 1:tset
                        fprintf('Importing prototypes and backfitting for dataset %i\n',nf)
                        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',nf,'study',0);
                        EEG = pop_micro_import_proto( EEG, ALLEEG, ind_ms_set);
                        
                        
                        %% 3.6 Back-fit microstates on EEG
                        EEG = pop_micro_fit( EEG, 'polarity', 0 );
                        %% 3.7 Temporally smooth microstates labels
                        % EEG = pop_micro_smooth( EEG, 'label_type', 'backfit', ...
                        % 'smooth_type', 'reject segments', ...
                        % 'minTime', 30, ...
                        % 'polarity', 0 );
                        
                        EEG = pop_micro_smooth( EEG, ...
                            'label_type', 'backfit',...
                            'smooth_type', project.microstates.micro_smooth.smooth_type,...
                            'minTime', project.microstates.micro_smooth.minTime,...
                            'polarity', project.microstates.micro_smooth.polarity );
                        %% 3.9 Calculate microstate statistics
                        EEG = pop_micro_stats( EEG, 'label_type', 'backfit', ...
                            'polarity', 0 );
                        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                        fout  = [EEG.filename(1:end-4)];
                        %                     fout  = [EEG.filename(1:end-4),'_ms'];
                        EEG = pop_saveset( EEG, 'filename',[fout,'.set'],'filepath',input_path);
                        allfields = fields(EEG.microstate.stats) ;
                        
                        fields2keep = {'Gfp','Occurence','Duration','Coverage','GEV','MspatCorr'};
                        select_fields = not(ismember(allfields,fields2keep));
                        fields2rm = allfields(select_fields);
                        data_ms0 = rmfield(EEG.microstate.stats,fields2rm);
                        tot_ms = size(EEG.microstate.prototypes,2);
                        tot_pt = EEG.trials*tot_ms;
                        for nf2k = 1:length(fields2keep)
                            current_field = fields2keep{nf2k};
                            data_ms.(current_field) = reshape(data_ms0.(current_field),1,tot_pt);
                        end
                        data_ms.epoch = repmat(1:EEG.trials,1,tot_ms);
                        data_ms.microstate = reshape(repmat(1:tot_ms,EEG.trials,1),1,tot_pt);
                        data_ms = structfun(@transpose,data_ms,'UniformOutput',false);
                        data_ms = struct2table(data_ms);
                        outpath_ms = fullfile(ms_dir,[fout,'_',current_cond_name,'_ms','.txt']);
                        writetable(data_ms,outpath_ms,"Delimiter" ,"\t")
                        
                        fprintf(fid_gevtotal, '%s\t%d\n',fout,EEG.microstate.stats.GEVtotal);
                        TP_epoch = [];
                        row_epoch = [];
                        col_epoch = [];
                        epoch = [];

                        for nepo = 1:EEG.trials
                            mat_epoch = EEG.microstate.stats.TP(:,:,nepo);
                            tmat = numel(mat_epoch);
                            LIDX = 1:tmat;
                            TP_epoch = [TP_epoch,reshape(mat_epoch,1,tmat)];
                            [rrow, ccol] = ind2sub(size(EEG.microstate.stats.TP), LIDX);
                            row_epoch = [row_epoch, rrow];
                            col_epoch = [col_epoch, ccol];
                            epoch = [epoch, repmat(nepo,1,tmat)];                            
                        end
                        data_mat.epoch = epoch;
                        data_mat.row = row_epoch;
                        data_mat.col = col_epoch;
                        data_mat.TP = TP_epoch;


                        data_mat = structfun(@transpose,data_mat,'UniformOutput',false);
                        data_mat = struct2table(data_mat);
                        outpath_mat = fullfile(mat_dir,[fout,'_',current_cond_name,'_mat','.txt']);
                        writetable(data_mat,outpath_mat,"Delimiter" ,"\t")
                        
                        clear data_mat data_ms
                    end
                    fclose(fid_gevtotal);
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


