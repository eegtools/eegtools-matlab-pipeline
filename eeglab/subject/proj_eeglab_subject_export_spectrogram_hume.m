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
function project = proj_eeglab_subject_export_spectrogram_hume(project, varargin)


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
    
    stagedatadir = fullfile(project.paths.project, 'hume');
    stagedatapath = fullfile(stagedatadir,[EEG.filename(1:end-4),'.mat']);
    disp(stagedatapath);
    if exist(stagedatapath)
        load(stagedatapath);
    else
        disp('no such file!');
    end
    
    
    
%     [nr_eeg,nc_eeg] = size(EEG.data);
    
%     EEG.pts_win = EEG.srate * stageData.win;
%     
%     tot_epo = length(stageData.stageTime);
%     id_epo = 1:tot_epo;
%     
%     stadtimes= 1:(tot_epo*EEG.pts_win-1);
    %     stadtimes= stageData.onsets(1):(stageData.onsets(end)+EEG.pts_win-1);
    
%     allch = {EEG.chanlocs.labels};
%     
%     stadmat = repmat(stageData.stages',EEG.pts_win,1);
%     [nr_stad,nc_stad] = size(stadmat);
%     already_staged = sum(ismember(allch, 'SS'));
%     
%     if already_staged
%         nchstad = nr_eeg;
%     else
%         nchstad = nr_eeg + 1;
%         
%         
%         eeglab_channels_file    = project.eegdata.eeglab_channels_file_path;
%         EEG=pop_chanedit(EEG, 'lookup',eeglab_channels_file);
%         
%     end
%     stadvec = reshape(stadmat,1,nr_stad*nc_stad);
%     stadvec(stadvec == 7) = nan; % converto MT in nan
%     
%     if length(stadtimes)> nc_eeg
%         sel_times = stadtimes <= nc_eeg;
%         stadtimes = stadtimes (sel_times);
%         stadvec = stadvec (sel_times);
%     end
%     
%     
%     
%     init_stad_ch = nan(1,nc_eeg);
%     EEG.data(nchstad,:) = init_stad_ch;
%     l1 = length(stadtimes);
%     l2 = length(stadvec);
%     l12 = min([l1,l2]);
%     stadtimes = stadtimes(1:l12);
%     stadvec = stadvec(1:l12);
%     EEG.data(nchstad,stadtimes) = stadvec;
%     EEG.chanlocs(nchstad) = EEG.chanlocs(1);
%     EEG.chanlocs(nchstad).labels = 'SS';% sleep staging stagingHume
%     
%     
%     EEG.sleep_stages = project.sleep.hume.stageData.stageNames;
%     
%     
%     
%     if(isfield(stageData,'rectEvents'))
%         if not(isempty(stageData.rectEvents))
% %         if project.sleep.hume.SWSpiCoupling.enable
%             
%             list_spiEvent = [];
%             list_swEvent = [];
%             list_spiEvent_eeglab = [];
%             list_swEvent_eeglab = [];
%                         
%             tot_nch = length(project.sleep.hume.detectSpindles.channelLabels);
% 
%             for nchc = 1:tot_nch
%                 current_ch = project.sleep.hume.detectSpindles.channelLabels{nchc};
%                 spiEvent = ['Sleep Spindle (Ferrarelli/Warby ', current_ch,')'];
% %                 swEvent = ['Slow Wave (Riedner/Massimini)', current_ch,')'];
%                 
%                 spiEvent_eeglab = ['ss', current_ch,'_h'];
% %                 swEvent_eeglab = ['sw', current_ch,'_h'];
%                 
%                 list_spiEvent{nchc} = spiEvent;
% %                 list_swEvent{nchc} = swEvent;
%                 
%                 list_spiEvent_eeglab{nchc} = spiEvent_eeglab;
% %                 list_swEvent_eeglab{nchc} = swEvent_eeglab;               
%                 
%             end
%             
%             
%             
%             tot_nch = length(project.sleep.hume.detectSW.channelLabels);
% 
%               for nchc = 1:tot_nch
%                 current_ch = project.sleep.hume.detectSW.channelLabels{nchc};
% %                 spiEvent = ['Sleep Spindle (Ferrarelli/Warby ', current_ch,')'];
%                 swEvent = ['Slow Wave (Riedner/Massimini)', current_ch,')'];
%                 
% %                 spiEvent_eeglab = ['ss', current_ch,'_h'];
%                 swEvent_eeglab = ['sw', current_ch,'_h'];
%                 
% %                 list_spiEvent{nchc} = spiEvent;
%                 list_swEvent{nchc} = swEvent;
%                 
% %                 list_spiEvent_eeglab{nchc} = spiEvent_eeglab;
%                 list_swEvent_eeglab{nchc} = swEvent_eeglab;               
%                 
%             end
%             
%             
%             list_clean_eve = [list_spiEvent,list_swEvent,list_spiEvent_eeglab,list_swEvent_eeglab];
%             
%             if isempty(EEG.event)
%                EEG.event(1).type = 'fake_event';
%                EEG.event(1).duration = 0;
%                EEG.event(1).timestamp = 1;
%                EEG.event(1).latency = 1;
%                EEG.event(1).urevent = 1;               
%             end
%             
%             clean_eve = not(ismember({EEG.event.type},list_clean_eve));
%             EEG.event = EEG.event(clean_eve);
%             
%             list_insert_eve = [list_spiEvent,list_swEvent];
%             list_insert_eve_eeglab = [list_spiEvent_eeglab,list_swEvent_eeglab];
%             
%             
%             srate_hume = 100;
%             tot_old_event = length(EEG.event);
%             for ninsert_eve = 1:length(list_insert_eve)
%                 current_inserteve = list_insert_eve{ninsert_eve};
%                 current_inserteve_eeglab = list_insert_eve_eeglab{ninsert_eve};
%                 
%                 file_export = fullfile(stagedatadir,[EEG.filename(1:end-4),'_',current_inserteve_eeglab,'.zot']);
%                 fid = fopen(file_export,'w+');
%                 if sum(strfind_index({current_inserteve_eeglab},'ss'))
%                     fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
%                         'sumamp','maxamp','spifrq','duration','spimaxi','fs','stage');
%                 elseif sum(strfind_index({current_inserteve_eeglab},'sw'))
%                     fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
%                         'epoch','stage','WaveStart','WaveEnd','p2pAmp','negPeakAmp','negPeakX',...
%                         'posPeakAmp','posPeakX','period','downSlope','upSlope','fs');
%                 end
%                 list_all_eve_type_hume = [stageData.rectEvents(:,5)];
%                 
%                 sel_current_inserteve = find(ismember(list_all_eve_type_hume, current_inserteve));
%                 
%                 list_eve_type_hume = list_all_eve_type_hume(sel_current_inserteve);
%                 list_eve_begin_hume = round([stageData.rectEvents{sel_current_inserteve,2}]*EEG.srate);
%                 list_eve_end_hume = round([stageData.rectEvents{sel_current_inserteve,3}]*EEG.srate);
%                 %
%                 list_eve_str_hume = [stageData.rectEvents{sel_current_inserteve,7}];
%                 list_eve_dur_hume = list_eve_end_hume - list_eve_begin_hume;
%                 
%                 unique_begin = sort(unique(list_eve_begin_hume));
%                 unique_end = sort(unique(list_eve_end_hume));
%                 
%                 
%                 ind_b = [];
%                 for nb = 1:length(unique_begin)
%                     ind_b(nb) = find(list_eve_begin_hume == unique_begin(nb),1,'first');
%                 end
%                 
%                 ind_e = [];
%                 for ne= 1:length(unique_end)
%                     ind_e(ne) = find(list_eve_end_hume == unique_end(ne),1,'first');
%                 end
%                 ind_be = sort(unique([ind_b,ind_e]));
%                 tot_old_event = length(EEG.event);
%                 
%                 
%                 tot_eve2add = length(ind_be);
%                 for neve2add = 1:tot_eve2add
%                     curr_eve = tot_old_event + neve2add;
%                     ind_hume = ind_be(neve2add);
%                     EEG.event(curr_eve) = EEG.event(1);
%                     EEG.event(curr_eve).type = current_inserteve_eeglab;
%                     EEG.event(curr_eve).latency = list_eve_begin_hume(ind_hume);
%                     EEG.event(curr_eve).duration = list_eve_end_hume(ind_hume) - list_eve_begin_hume(ind_hume);
%                     eve_struct = list_eve_str_hume(ind_hume);
%                     disp(list_eve_type_hume(ind_hume))
%                     disp(current_inserteve_eeglab)
%                     
%                     %             disp(neve2add)
%                     %             disp(ind_hume)
%                     %             disp(eve_struct)
%                     if sum(strfind_index({current_inserteve_eeglab},'ss'))
%                         fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\n',...
%                             eve_struct.sumamp,eve_struct.maxamp,eve_struct.spifrq',eve_struct.duration,...
%                             eve_struct.spimaxi,eve_struct.fs,eve_struct.stage);
%                     elseif sum(strfind_index({current_inserteve_eeglab},'sw'))
%                         fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n',...
%                             eve_struct.epoch,eve_struct.stage,eve_struct.WaveStart,eve_struct.WaveEnd,...
%                             eve_struct.p2pAmp,eve_struct.negPeakAmp,eve_struct.negPeakX,...
%                             eve_struct.posPeakAmp,eve_struct.posPeakX,eve_struct.period,...
%                             eve_struct.downSlope,eve_struct.upSlope,eve_struct.fs);
%                     end
%                     
%                 end
%                 fclose(fid)
%             end
%             
%             
%         end
%         
%         
%     end
%     
%     clean_fake_eve = not(ismember({EEG.event.type},'fake_event'));
%     EEG.event = EEG.event(clean_fake_eve);
%     
%     
%     [sorted, ind_sort] = sort([EEG.event.latency]);
%     EEG.event = EEG.event(ind_sort);
%     
%     EEG = eeg_checkset(EEG);
%     eeglab redraw;
%     EEG  = pop_saveset( EEG, 'filename', EEG.filename, 'filepath', EEG.filepath);
    
    
    
end

