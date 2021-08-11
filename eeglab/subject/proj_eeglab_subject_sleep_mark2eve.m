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
function project = proj_eeglab_subject_sleep_mark2eve(project, varargin)


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

sleep_stages.markers = project.sleep.sleep_stages.markers;...{'N1','N2','N3','REM','W'};
    sleep_stages.colors =  project.sleep.sleep_stages.colors;...{[1 0 0],[0 1 0],[0 0 1],[0 1 1],[1 0 1]};
    
tot_ss = length(sleep_stages.markers); %total sleep stages


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
    
    %% clean EEG event
    alleve = {EEG.event.type};
    cleaneve = not(ismember(alleve,{EEG.marks.time_info.label}));
    EEG.event = EEG.event(cleaneve);
    
    
    tot_marks = length(EEG.marks.time_info);
    
    mark2eve = tot_marks - tot_ss - 1; % il numero di mark da convertire in eventi è il totale di marks meno i marks degli sleep stages meno 1 che corrisponde al mark manual
    for nm = 1:mark2eve
        ind_current_mark = 1 + tot_ss + nm;
        label_current_mark =  EEG.marks.time_info(ind_current_mark).label;
        onset_offset = logical([0,abs(diff(EEG.marks.time_info(ind_current_mark).flags))]);
        tot_new_eve = sum(onset_offset)/2;
        allpt = 1:EEG.pnts;
        ind_onset_offset = reshape(allpt(onset_offset),2,tot_new_eve)';
        tot_old_eve = length(EEG.event);
        
        for neve = 1:tot_new_eve
            
            t1 = ind_onset_offset(neve,1);
            t2 = ind_onset_offset(neve,2);
            EEG.event(tot_old_eve + neve) = EEG.event(1);
            EEG.event(tot_old_eve + neve).type = label_current_mark;
            EEG.event(tot_old_eve + neve).duration = t2-t1;
            EEG.event(tot_old_eve + neve).latency = t1;
            EEG.event(tot_old_eve + neve).timestamp = nan;
            EEG.event(tot_old_eve + neve).urevent = nan;
        end
    end
    [sorted, ind_sort] = sort([EEG.event.latency]);
    EEG.event = EEG.event(ind_sort);
    
    
    allch = {EEG.chanlocs.labels};
    
    nchstad = ismember(allch, 'SS');% mi facciod are indice canale con la stadiazione

    if not(sum(nchstad))
        % creo canale stadiazione se non presente (cioè se faccio lo scoring
        % dentro eeglab tramite vised e NON dentro hume)
        stadvec = [];
        for nss = 1:tot_ss
            stadvec = stadvec + EEG.marks.time_info(nss+1).flags*nss;
        end
        
        stadvec(stadvec == 0) = nan;
        stadvec = stadvec-1; % ora la wake è a zero e dove non ho stadiato ho nan
        
        nchstad = EEG.nbchan + 1;
        EEG.data = [EEG.data;stadvec];
        EEG.chanlocs(nchstad) = EEG.chanlocs(1);
        EEG.chanlocs(nchstad).labels = 'SS';% sleep staging eeglab
    end
    
    EEG = eeg_checkset(EEG);
    eeglab redraw;
    EEG  = pop_saveset( EEG, 'filename', EEG.filename, 'filepath', EEG.filepath);
    
    
    
    
end


end

