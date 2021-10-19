%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_extract_trigger_duration(project, varargin)





list_select_subjects    = project.subjects.list;
get_filename_step       = 'extract_trigger';
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

tot_labels = length(project.extract_trigger.duration.trigger_lab);

for subj=1:numsubj
    
    subj_name   = list_select_subjects{subj};
    inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'export_data', custom_suffix, 'custom_input_folder', custom_input_folder);
    
    [filepath,name_noext,ext] = fileparts(inputfile);
    
    if exist(inputfile)
        try
            EEG                     = pop_loadset(inputfile);
        catch
            [fpath,fname,fext] = fileparts(inputfile);
            EEG = pop_loadset('filename',fname,'filepath',fpath);
        end
        EEG = pop_saveset('filename',[fname,'_trigger_bck'],'filepath',fpath);
        
        project.extract_trigger.ranges_duration_pt = ...
            round(project.extract_trigger.ranges_duration_ms/1000*EEG.srate);%points
        
        
        allch_lab = {EEG.chanlocs.labels};
        sel_ch = ismember(allch_lab, project.extract_trigger.channel_lab);
        data_ch = EEG.data(sel_ch,:);
        
        if strcmp(project.extract_trigger.do_rectification, 'on')
            data_ch = abs(data_ch - mean(data_ch)); % in uV
        end
        
        
        if strcmp(project.extract_trigger.mode, 'abs_th')
            data_ch_th = data_ch > project.extract_trigger.abs_th.th_amplitude; % in uV
        end
        
        if strcmp(project.extract_trigger.mode, 'stat_th')
            % project.extract_trigger.stat_th.baseline.nsd = 3; % number of sd from the mean of the baseline period, 3 corrsponds rawly to 99% CI, 2 to 95% CI
            % project.extract_trigger.stat_th.baseline.limits_s = [1,5]; % baseline begin/end in seconds
            baseline_pt =  round(project.extract_trigger.stat_th.baseline.limits_s*EEG.srate);
            b1 = baseline_pt(1);
            b2 = baseline_pt(2);
            sel_baseline = EEG.times >= b1 & EEG.times <= b2;
            data_baseline = data_ch(sel_baseline);
            mean_baseline = mean(data_baseline);
            sd_baseline = std(data_baseline);
            
            th_pos = mean_baseline + project.extract_trigger.stat_th.baseline.nsd * sd_baseline;
            sel_pos = data_ch > th_pos;
            
            th_neg = mean_baseline - project.extract_trigger.stat_th.baseline.nsd * sd_baseline;
            sel_neg = data_ch < th_neg;
            
            sel_both = sel_pos & sel_neg;
            
            if strcmp(project.extract_trigger.stat_th.side, 'neg')
                data_ch_th = sel_neg;
            end
            
            if strcmp(project.extract_trigger.stat_th.side, 'pos')
                data_ch_th = sel_pos;
            end
            
            if strcmp(project.extract_trigger.stat_th.side, 'both')
                data_ch_th = sel_both;
            end
            
            data_ch_diff = [0,diff(data_ch_th)];
            data_ch_on = data_ch_diff > 0;
            data_ch_off = data_ch_diff < 0;
            trigger_onset = find(data_ch_on);
            trigger_offset = find(data_ch_off);
            trigger_duration = trigger_offset - trigger_onset;
            trigger_duration_label = cell(1,tot_labels);
            
            
            for nlabel = 1:tot_labels
                sel_duration = trigger_duration >= project.extract_trigger.ranges_duration_pt(nlabel, 1)& trigger_duration <= project.extract_trigger.ranges_duration_pt(nlabel, 2);
                trigger_duration_label{nlabel}= find(sel_duration);
                
            end
            
            count = 1;
            for nlabel = 1:tot_labels
                trigger2insert = trigger_duration_label{nlabel};
                onset2insert = trigger_onset(trigger2insert);
                tot_triggers = length(onset2insert);
                for ntrigger = 1:tot_triggers
                    EEG.event(count).type = project.extract_trigger.duration.trigger_lab{nlabel};
                    EEG.event(count).latency = onset2insert(ntrigger);
                    EEG.event(count).duration = trigger_duration(trigger2insert(ntrigger));
                    count = count+1;
                end
            end
            
            all_latencies=[EEG.event.latency];
            [sort_lat, indsort] = sort(all_latencies);
            EEG.event = EEG.event(indsort);
            
            EEG = eeg_checkset( EEG );
            EEG = pop_saveset('filename',fname,'filepath',fpath);
            
            
        end
        
        
    end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
