%% function OUTEEG =  proj_eeglab_subject_adjustbaseline_trial(EEG, project,varargin)
%
% adjust baseline by inserting before / after target events in each trial baseline segments taken within the same trial and originally placed before / after the target events
%
% project is a structure with the fields:
%
%  project.epoching.epo_st.s;
%  project.epoching.epo_end.s;
%  project.epoching.mrkcode_cond;
%  project.epoching.baseline_insert.baseline_begin_marker;
%  project.epoching.baseline_insert.baseline_end_marker;
%  project.epoching.bc_st.s;
%  project.epoching.bc_end.s;
%  project.epoching.baseline_insert.mode;
%  project.epoching.baseline_insert.baseline_originalposition;
%  project.epoching.baseline_insert.baseline_finalposition;
%  project.epoching.baseline_duration.s
%
% NOTE: trials with boundary events are discharged from epoching
%
% function OUTEEG =  proj_eeglab_subject_adjustbaseline_trial(EEG, project,varargin)

function OUTEEG =  proj_eeglab_subject_adjustbaseline_trial(EEG, project,varargin)


% total number of events in the dataset
tot_eve = length(EEG.event);

% for each event of each trial, insert a baseline taken from the trial itself

% find markers of begin trial followed by another begin trial (to
% delimit each trial)
[begin_trial_all_index ,urnbrs,urnbrtypes,begin_trial_all_duration,tflds,urnflds] = eeg_context(EEG,...
    project.epoching.baseline_insert.trial_begin_marker,...
    project.epoching.baseline_insert.trial_begin_marker,...
    1);


% find markers of begin trial followed a boundary event
[begin_trial_boundary_index,urnbrs,urnbrtypes,begin_trial_boundary_duration,tflds,urnflds] = eeg_context(EEG,...
    project.epoching.baseline_insert.trial_begin_marker,...
    'boundary',...
    1);

% the trials to be unselected have that the index difference
% (time) between the begin of the trial and the following boundary is lower than the index
% difference (latency) between the begin of the trial and the
% following begin of the trial

% array with the marker index of begin of trials with boundary, for which boundary is closer than the begin of the following trial
begin_trial_boundary_index_corr = [];

% corresponding trial end marker index
end_trial_boundary_index_corr   = [];

nn = 1;

% for each trial  with boundary
for ntb = 1:length(begin_trial_boundary_index)
    
    % index of the trial  with boundary
    tb_idx = begin_trial_boundary_index(ntb);
    
    % corresponding latency (duration)
    tb_lat = begin_trial_boundary_duration(ntb);
    
    % index of the corresponding trial in the array with all trials
    nta    = find(begin_trial_all_index == tb_idx);
    
    % corresponding latency (duration)
    ta_lat = begin_trial_all_duration(ntb);
    
    % if the boundary is closer than the followng trial begin
    if tb_lat < tb_lat
        
        % store the event index of the begin trial
        begin_trial_boundary_index_corr(nn) = tb_idx;
        
        % store the event index of the end trial
        end_trial_boundary_index_corr(nn)   = begin_trial_all_index(nta+1);
        
        nn = nn+1;
    end
end


% initialize the array to unselect events in trials with boundaries

event_in_trials_without_boundary = true(1,tot_eve);

% unselect events in trial with boundaries

% for neve = 1:tot_eve
%     
%     for nsel = 1:length(begin_trial_boundary_index_corr)
%         if (neve >= begin_trial_boundary_index_corr(nsel) &&  neve <= end_trial_boundary_index_corr(nsel))
%             
%             event_in_trial_without_boundary(neve) =  false;
%             
%         end
%         
%     end
% end

% for each type of target event
for nevetype = 1:length(project.epoching.valid_marker)
    
    % select the corresponding type (label)
    mark_cond_label = project.epoching.valid_marker{nevetype};
    
%     % for each of all events
%     for neve = 1:length(EEG.event)
%         event_in_trial_without_boundary =  false;
%     end
    
    % find the selected target events
    
    % if the baseline segments were originally before the target events
    if strcmp(project.epoching.baseline_insert.baseline_originalposition, 'before')
        
        % find target events precededed by baseline segments
        [target_index,baseline_begin_index,urnbrtypes,duration,tflds,urnflds] = eeg_context(EEG,...
            mark_cond_label,...
            project.epoching.baseline_insert.baseline_begin_marker,...
            -1);
        
%         %find baseline segments followed by target events
%         [baseline_begin_index,baseline_begin_index,urnbrtypes,duration,tflds,urnflds] = eeg_context(EEG,...
%             project.epoching.baseline_insert.baseline_begin_marker,...
%             mark_cond_label,...
%             1);
        
        % calculate baseline duration for each baseline segment (in
        % principle it could vary)
        [all_baseline_begin_index,urnbrs,urnbrtypes,all_baseline_duration,tflds,urnflds] = eeg_context(EEG,...
            project.epoching.baseline_insert.baseline_begin_marker,...
            project.epoching.baseline_insert.baseline_end_marker,...
            1);
        
    end
    
    % if the baseline segments were originally after the target events
    if strcmp(project.epoching.baseline_insert.baseline_originalposition, 'after')
        
        % find target events follwed by baseline segments
        [target_index,urnbrs,urnbrtypes,trial_duration,tflds,urnflds] = eeg_context(EEG,...
            mark_cond_label,...
            project.epoching.baseline_insert.baseline_begin_marker,...
            1);
        
        %find baseline segments preceded by target events
        [all_baseline_begin_index,urnbrs,urnbrtypes,trial_duration,tflds,urnflds] = eeg_context(EEG,...
            project.epoching.baseline_insert.baseline_begin_marker,...
            mark_cond_label,...
            -1);
    end
    
    
    
%     event_in_trial_without_boundary = find(event_in_trial_without_boundary);
%     % select and epoch the events 1) within trials without boundaries AND 2) of the selected target type
%     sel_target2epoch = intersect (event_in_trial_without_boundary,target_index);

 sel_target2epoch = target_index(:,1);
    
    % during epoching there is the possibility to selecto events BOTH by
    % type AND by index
    [EEG_target, indices] = pop_epoch( EEG, {mark_cond_label}, ...
        [project.epoching.epo_st.s project.epoching.epo_end.s],...
        'eventindices',sel_target2epoch);
    
    % select and epoch the events 1) within trials without boundaries AND 2) of the selected baseline start type
%     sel_baseline_begin2epoch = intersect (event_in_trial_without_boundary,baseline_begin_index);
sel_baseline_begin2epoch = baseline_begin_index;
    
    % select only tha baseline durations of the selected segments (paired
    % with the selected target events)
    baseline_duration = all_baseline_duration(ismember(all_baseline_begin_index,sel_baseline_begin2epoch));
    
    
    [EEG_baseline, indices] = pop_epoch( EEG, {project.epoching.baseline_insert.baseline_begin_marker}, ...
        [0         project.epoching.baseline_duration.s],...
        'eventindices',sel_baseline_begin2epoch);
    
    % important: baseline segments could have a different duration for each trial (e.g. if thwy are manually defined)
    % moreover, some baseline segments could be shorter than the required
    % duration
    
    % therefore:
    %   1) baseline segments longer than the requested duration are cutted (no problem, already done and ok)
    %   2) baseline segments shorter than the requested duration must be
    %      interpolated to reach the requred duraion
    % actually in EEG_base epochs have the requested baseline duration, but in the case of 2), part of the epochs must be overwritten with baseline points
    
    for ntrial = 1:EEG_baseline.trial
        
        baseline_duration_trial = baseline_duration(ntrial);
        
        if baseline_duration_trial < project.epoching.baseline_duration.s
            times2rep_trial = EEG_baseline.times <= baseline_duration_trial;
            
            % replicate the real baseline
            nrep         = ceil(project.epoching.baseline_duration.s / baseline_duration_trial);
            segment2rep  = EEG_baseline.data(times2rep_trial,:,ntrial);
            rep_baseline = rep(segment2rep,1,nrep);
            
            % remove exceding points
            cut_vec                = length(rep_baseline) <= EEG_baseline.times;
            cut_baseline           = rep_baseline(cut_vec);
            
            % replace the baseline of the trial with the interpolated version
            EEG_baseline(:,:,ntrial)   = cut_baseline;
        end
    end
    
    % if the new baseline must be added before the target events
    if strcmp (project.epoching.baseline_insert.baseline_position, 'before')
        sel_replace_baseline = EEG_target.times < 0;
    end
    
    % if the new baseline must be added after the target events
    if strcmp (project.epoching.baseline_insert.baseline_position, 'after')
        sel_replace_baseline = EEG_target.times > 0;
    end
    
    for ntrial = 1: EEG.trials
        EEG_target(sel_replace_baseline,:,ntrial) = EEG_baseline(:,:,ntrial);
    end
    
    EEG_evetype = EEG_target;
    
    ALLEEG2(nevetype) = EEG_evetype;
end

OUTEEG = pop_mergeset( ALLEEG2, 1:length(ALLEEG2), 0 );
OUTEEG = eeg_checkset(OUTEEG);




end


%% function OUTEEG =  proj_eeglab_subject_adjustbaseline_trial(EEG, project,varargin)
%
% adjust baseline by inserting before / after target events in each trial baseline segments taken within the same trial and originally placed before / after the target events
%
% project is a structure with the fields:
%
%  project.epoching.epo_st.s;
%  project.epoching.epo_end.s;
%  project.epoching.mrkcode_cond;
%  project.epoching.baseline_insert.baseline_begin_marker;
%  project.epoching.baseline_insert.baseline_end_marker;
%  project.epoching.bc_st.s;
%  project.epoching.bc_end.s;
%  project.epoching.baseline_insert.mode;
%  project.epoching.baseline_insert.baseline_originalposition;
%  project.epoching.baseline_insert.baseline_finalposition;
%  project.epoching.baseline_duration.s
%
% NOTE: trials with boundary events are discharged from epoching
%
% function OUTEEG =  proj_eeglab_subject_adjustbaseline_trial(EEG, project,varargin)
% 
% ll=length({EEG.event.urevent});
% for nn =1:ll
%     EEG.event(nn).urevent=nn;
% end
% 
% EEG.urevent = EEG.event;
% EEG=eeg_checkset(EEG);
% 
% 
% 
% % total number of events in the dataset
% tot_eve = length(EEG.event);
% 
% % for each event of each trial, insert a baseline taken from the trial itself
% 
% % find markers of begin trial followed by another begin trial (to
% % delimit each trial)
% [begin_trial_all_index ,urnbrs,urnbrtypes,begin_trial_all_duration,tflds,urnflds] = eeg_context(EEG,...
%     project.epoching.baseline_insert.trial_begin_marker,...
%     project.epoching.baseline_insert.trial_begin_marker,...
%     1);
% 
% 
% % find markers of begin trial followed a boundary event
% [begin_trial_boundary_index,urnbrs,urnbrtypes,begin_trial_boundary_duration,tflds,urnflds] = eeg_context(EEG,...
%     project.epoching.baseline_insert.trial_begin_marker,...
%     'boundary',...
%     1);
% 
% % the trials to be unselected have that the index difference
% % (time) between the begin of the trial and the following boundary is lower than the index
% % difference (latency) between the begin of the trial and the
% % following begin of the trial
% 
% % array with the marker index of begin of trials with boundary, for which boundary is closer than the begin of the following trial
% begin_trial_boundary_index_corr = [];
% 
% % corresponding trial end marker index
% end_trial_boundary_index_corr   = [];
% 
% nn = 1;
% 
% % for each trial  with boundary
% for ntb = 1:length(begin_trial_boundary_index)
%     
%     % index of the trial  with boundary
%     tb_idx = begin_trial_boundary_index(ntb);
%     
%     % corresponding latency (duration)
%     tb_lat = begin_trial_boundary_duration(ntb);
%     
%     % index of the corresponding trial in the array with all trials
%     nta    = find(begin_trial_all_index == tb_idx);
%     
%     % corresponding latency (duration)
%     ta_lat = begin_trial_all_duration(ntb);
%     
%     % if the boundary is closer than the followng trial begin
%     if tb_lat < tb_lat
%         
%         % store the event index of the begin trial
%         begin_trial_boundary_index_corr(nn) = tb_idx;
%         
%         % store the event index of the end trial
%         end_trial_boundary_index_corr(nn)   = begin_trial_all_index(nta+1);
%         
%         nn = nn+1;
%     end
% end
% 
% 
% % initialize the array to unselect events in trials with boundaries
% 
% event_in_trials_without_boundary = true(1,tot_eve);
% 
% % unselect events in trial with boundaries
% 
% % for neve = 1:tot_eve
% %     
% %     for nsel = 1:length(begin_trial_boundary_index_corr)
% %         if (neve >= begin_trial_boundary_index_corr(nsel) &&  neve <= end_trial_boundary_index_corr(nsel))
% %             
% %             event_in_trial_without_boundary(neve) =  false;
% %             
% %         end
% %         
% %     end
% % end
% 
% % for each type of target event
% for nevetype = 1:length(project.epoching.valid_marker)
%     
%     % select the corresponding type (label)
%     mark_cond_label = project.epoching.valid_marker{nevetype};
%     
% %     % for each of all events
% %     for neve = 1:length(EEG.event)
% %         event_in_trial_without_boundary =  false;
% %     end
%     
%     % find the selected target events
%     
%     % if the baseline segments were originally before the target events
%     if strcmp(project.epoching.baseline_insert.baseline_originalposition, 'before')
%         
%         % find target events precededed by baseline segments
%         [target_index,baseline_begin_index,urnbrtypes,duration,tflds,urnflds] = eeg_context(EEG,...
%             mark_cond_label,...
%             project.epoching.baseline_insert.baseline_begin_marker,...
%             -1);
%         
% %         %find baseline segments followed by target events
% %         [baseline_begin_index,baseline_begin_index,urnbrtypes,duration,tflds,urnflds] = eeg_context(EEG,...
% %             project.epoching.baseline_insert.baseline_begin_marker,...
% %             mark_cond_label,...
% %             1);
%         
%         % calculate baseline duration for each baseline segment (in
%         % principle it could vary)
%         [all_baseline_begin_index,urnbrs,urnbrtypes,all_baseline_duration,tflds,urnflds] = eeg_context(EEG,...
%             project.epoching.baseline_insert.baseline_begin_marker,...
%             project.epoching.baseline_insert.baseline_end_marker,...
%             1);
%         
%     end
%     
%     % if the baseline segments were originally after the target events
%     if strcmp(project.epoching.baseline_insert.baseline_originalposition, 'after')
%         
%         % find target events follwed by baseline segments
%         [target_index,urnbrs,urnbrtypes,trial_duration,tflds,urnflds] = eeg_context(EEG,...
%             mark_cond_label,...
%             project.epoching.baseline_insert.baseline_begin_marker,...
%             1);
%         
%         %find baseline segments preceded by target events
%         [all_baseline_begin_index,urnbrs,urnbrtypes,trial_duration,tflds,urnflds] = eeg_context(EEG,...
%             project.epoching.baseline_insert.baseline_begin_marker,...
%             mark_cond_label,...
%             -1);
%     end
%     
%     
%     
% %     event_in_trial_without_boundary = find(event_in_trial_without_boundary);
% %     % select and epoch the events 1) within trials without boundaries AND 2) of the selected target type
% %     sel_target2epoch = intersect (event_in_trial_without_boundary,target_index);
% 
%  sel_target2epoch = target_index(:,1);
%     
%     % during epoching there is the possibility to selecto events BOTH by
%     % type AND by index
%     [EEG_target, indices] = pop_epoch( EEG, {mark_cond_label}, ...
%         [project.epoching.epo_st.s project.epoching.epo_end.s],...
%         'eventindices',sel_target2epoch);
%     
%     % select and epoch the events 1) within trials without boundaries AND 2) of the selected baseline start type
% %     sel_baseline_begin2epoch = intersect (event_in_trial_without_boundary,baseline_begin_index);
% sel_baseline_begin2epoch = baseline_begin_index;
%     
%     % select only tha baseline durations of the selected segments (paired
%     % with the selected target events)
%     baseline_duration = all_baseline_duration(ismember(all_baseline_begin_index,sel_baseline_begin2epoch));
%     
%     
%     [EEG_baseline, indices] = pop_epoch( EEG, {project.epoching.baseline_insert.baseline_begin_marker}, ...
%         [0         project.epoching.baseline_duration.s],...
%         'eventindices',sel_baseline_begin2epoch);
%     
%     % important: baseline segments could have a different duration for each trial (e.g. if thwy are manually defined)
%     % moreover, some baseline segments could be shorter than the required
%     % duration
%     
%     % therefore:
%     %   1) baseline segments longer than the requested duration are cutted (no problem, already done and ok)
%     %   2) baseline segments shorter than the requested duration must be
%     %      interpolated to reach the requred duraion
%     % actually in EEG_base epochs have the requested baseline duration, but in the case of 2), part of the epochs must be overwritten with baseline points
%     
%     for ntrial = 1:EEG_baseline.trial
%         
%         baseline_duration_trial = baseline_duration(ntrial);
%         
%         if baseline_duration_trial < project.epoching.baseline_duration.s
%             times2rep_trial = EEG_baseline.times <= baseline_duration_trial;
%             
%             % replicate the real baseline
%             nrep         = ceil(project.epoching.baseline_duration.s / baseline_duration_trial);
%             segment2rep  = EEG_baseline.data(times2rep_trial,:,ntrial);
%             rep_baseline = rep(segment2rep,1,nrep);
%             
%             % remove exceding points
%             cut_vec                = length(rep_baseline) <= EEG_baseline.times;
%             cut_baseline           = rep_baseline(cut_vec);
%             
%             % replace the baseline of the trial with the interpolated version
%             EEG_baseline(:,:,ntrial)   = cut_baseline;
%         end
%     end
%     
%     % if the new baseline must be added before the target events
%     if strcmp (project.epoching.baseline_insert.baseline_position, 'before')
%         sel_replace_baseline = EEG_target.times < 0;
%     end
%     
%     % if the new baseline must be added after the target events
%     if strcmp (project.epoching.baseline_insert.baseline_position, 'after')
%         sel_replace_baseline = EEG_target.times > 0;
%     end
%     
%     for ntrial = 1: EEG.trials
%         EEG_target(sel_replace_baseline,:,ntrial) = EEG_baseline(:,:,ntrial);
%     end
%     
%     EEG_evetype = EEG_target;
%     
%     ALLEEG2(nevetype) = EEG_evetype;
% end
% 
% OUTEEG = pop_mergeset( ALLEEG2, 1:length(ALLEEG2), 0 );
% OUTEEG = eeg_checkset(OUTEEG);
% 
% end