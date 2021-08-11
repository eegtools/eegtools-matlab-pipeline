%% EEG = proj_eeglab_subject_preprocessing(project, varargin)

%
%%
function project = proj_eeglab_subject_detect_spindle_eeglab(project, varargin)


list_select_subjects    = project.subjects.list;
get_filename_step       = 'output_import_data';
custom_suffix           = '';
custom_input_folder     = '';

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

project.sleep.detect_spindle_eeglab.goodsleepstages = '';% keep empty!


%% copy forked functions into vised eeglab directory (to recover, remove and git pull)
DS_export_Spindles_csv_m = fullfile(project.paths.framework_root,'eeg_tools','utilities',['DS_export_Spindles_csv.m']);

eeglab_plugin_dir = fullfile(project.paths.eeglab, 'plugins');
eeglab_plugin_list = {dir(eeglab_plugin_dir).name};
select_plugin = strfind_index(eeglab_plugin_list,'detect_spindles');
detect_spindles_dir = eeglab_plugin_list{select_plugin};
DS_export_Spindles_csv_dir = fullfile(project.paths.eeglab, 'plugins',detect_spindles_dir,'src');
copyfile( DS_export_Spindles_csv_m, DS_export_Spindles_csv_dir);
% C:\work\work-matlab\matlab_toolbox\eeglab\plugins\detect_spindles2.2.1\src


 % dir with files procuced by detect_spindle_eeglab
    detect_spindle_eeglabdir = fullfile(project.paths.project, 'detect_spindle_eeglab');
    if not(exist(detect_spindle_eeglabdir))
        mkdir(detect_spindle_eeglabdir);
    end
    
    disp(detect_spindle_eeglabdir);

% -------------------------------------------------------------------------------------------------------------------------------------

for subj=1:numsubj
    
    subj_name               = list_select_subjects{subj};
    input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    disp(input_file_name);
    
    
    if exist(input_file_name)
        try
            EEG                     = pop_loadset(input_file_name);
        catch
            [fpath,fname,fext] = fileparts(input_file_name);
            EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
            EEG.setname = EEG.filename(1:end-4);
        end
    else
        disp('no such file!');
    end
    
    % cleanup old events
    cleaneve = not(ismember({EEG.event.type},project.sleep.detect_spindle_eeglab.eventName_list));
    EEG.event = EEG.event(cleaneve);
    
    PARAM = project.sleep.detect_spindle_eeglab;
    
    tot_chan = length(project.sleep.detect_spindle_eeglab.channels_of_interest_list);
    for nchan = 1:tot_chan
        current_ch = project.sleep.detect_spindle_eeglab.channels_of_interest_list(nchan);
        if (sum(ismember({EEG.chanlocs.labels},current_ch)))
            PARAM.channels_of_interest = current_ch;
            PARAM.eventName = project.sleep.detect_spindle_eeglab.eventName_list(nchan);
            PARAM.suffix = [...
                project.sleep.detect_spindle_eeglab.suffix,'_',...
                char(PARAM.channels_of_interest),'_',...
                char(PARAM.eventName)...
                ];
            
            [EEG] = detect_spindles(EEG,PARAM);
            FileName = fullfile(EEG.filepath, [EEG.setname, '.csv']);
            movefile(FileName,detect_spindle_eeglabdir);
            
            
            EEG.setname = EEG.filename(1:end-4);
        end
    end
    
    
end
EEG = eeg_checkset(EEG);
EEG  = pop_saveset( EEG, 'filename', EEG.filename, 'filepath', EEG.filepath);
    
end
