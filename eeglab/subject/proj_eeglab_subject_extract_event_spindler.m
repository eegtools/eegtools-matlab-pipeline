%% EEG = proj_eeglab_subject_preprocessing(project, varargin)
% exctract sleep events and staging from EEGlab dataset for input in
% spindler
%%
function project = proj_eeglab_subject_extract_event_spindler(project, varargin)


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

% dir with files procuced by spindler
spindlerdir = fullfile(project.paths.project, 'spindler');
if not(exist(spindlerdir))
    mkdir(spindlerdir);
end

stageDir = fullfile(spindlerdir,'stageDir');
if not(exist(stageDir))
    mkdir(stageDir);
end

%     dataDir = 'C:\projects\sonno_mondino\epochs';
resultsDir = fullfile(spindlerdir,'resultsDir');
if not(exist(resultsDir))
    mkdir(resultsDir);
end


imageDir = fullfile(spindlerdir,'imageDir');
if not(exist(imageDir))
    mkdir(imageDir);
end

eventDir = fullfile(spindlerdir,'eventDir');
if not(exist(eventDir))
    mkdir(eventDir);
end
%% nota introdurre 2 analisi una automatica, l'altra basata sugli spindle identificati dall'operatore.

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
    
    %% extract each sleep event on a separate mat file
    extr_eve = project.sleep.spindler.eventLabels;
    extr_ch = project.sleep.spindler.channelLabels;
    tot_extr_eve = length(extr_eve);
    alleve_set = {EEG.event.type};
    for neve_extr = 1:tot_extr_eve
        current_eve_extr = extr_eve{neve_extr};
        current_ch_extr = extr_ch{neve_extr};

        disp(['Extracting ', current_eve_extr]);
        ind_eve_spindler = find(ismember(alleve_set,current_eve_extr));
        if isempty(ind_eve_spindler)
            disp('no such event!')
        else
            t1 = [EEG.event(ind_eve_spindler).latency];
            t2 = t1 + [EEG.event(ind_eve_spindler).duration];
            events =  [t1;t2]'/EEG.srate;
            file_eve_extr = fullfile(eventDir,[EEG.filename(1:end-4),'_',...
                current_eve_extr,'_',current_ch_extr,'.mat']);
            disp(file_eve_extr);
            save(file_eve_extr,'events');
        end
    end
    
    %% extract recordin periods with a staging
    allch_set = {EEG.chanlocs.labels};
    stad_ch = ismember(allch_set,'SS');
    if sum(stad_ch)
        disp(['Extracting sleep staging from SS channel']);
        stadvec = EEG.data(stad_ch,:);
        stad_present = not(isnan(stadvec));
        % assumo inzio e fine non siano stadiati (lasciare margine)
        stad_on_off = find([0,abs(diff(stad_present))]);
        tot_stad_on_off = length(stad_on_off)/2;
        events = reshape(stad_on_off,2,tot_stad_on_off)'/EEG.srate;
        
        file_stad_extr = fullfile(stageDir,[EEG.filename(1:end-4),'_',...
            'stad','.mat']);
        disp(file_stad_extr);
        save(file_stad_extr,'events');
        
    else
        disp('No sleep staging (SS) channel present in the dataset!')
    end
    
    
    
    
end

