%% EEG = proj_eeglab_subject_preprocessing(project, varargin)
%
% function to preprocess already imported and filtered data
%
% SUBSAMPLING
% CHANNELS TRANSFORMATION
% INTERPOLATION
% EVENT FILTERING
% SPECIFIC FILTERING
%
%%
function project = proj_eeglab_subject_sleep_eve_ss(project, varargin)


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
        end
    else
        disp('no such file!');
    end
    
    
    
    
    allch = {EEG.chanlocs.labels};
    tot_ss = length(EEG.sleep_stages);
    vec_ind_ss = 1:tot_ss;
    vec_lab_ss = vec_ind_ss - 1;
    nchstad = ismember(allch, 'SS');% mi facciod are indice canale con la stadiazione
    for ne =1:length(EEG.event)
        EEG.event(ne).latency = round(EEG.event(ne).latency);
        evelat = EEG.event(ne).latency;
        stad_ss_eve = EEG.data(nchstad,evelat);% 0 is wake, 1:4 n1:n4, 5 rem, 6 mt, 7 nan
        if isnan(stad_ss_eve)
            evestad = 'MT';
        else
            sel_stad = vec_lab_ss == stad_ss_eve;
            ind_ss = vec_ind_ss(sel_stad);
            evestad = EEG.sleep_stages{ind_ss};
        end
        EEG.event(ne).SleepStage = evestad;
    end
    
    
    
    EEG = eeg_checkset(EEG);
    eeglab redraw;
    EEG  = pop_saveset( EEG, 'filename', EEG.filename, 'filepath', EEG.filepath);
    
    
    
    
end


end

