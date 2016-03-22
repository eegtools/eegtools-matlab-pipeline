% %% function OUTEEG =  proj_eeglab_subject_replacebaseline_external(EEG, project, subj_name,varargin)
% %
% % adjust baseline by replacing before / after target events in each trial baseline segments taken outside the same trial and originally placed before / after the target events
% %
% % project is a structure with the fields:
% %
% %  project.epoching.epo_st.s;
% %  project.epoching.epo_end.s;
% %  project.epoching.mrkcode_cond;
% %  project.epoching.baseline_replace.baseline_begin_marker;
% %  project.epoching.baseline_replace.baseline_end_marker;
% %  project.epoching.bc_st.s;
% %  project.epoching.bc_end.s;
% %  project.epoching.baseline_replace.mode;
% %  project.epoching.baseline_replace.baseline_originalposition;
% %  project.epoching.baseline_replace.baseline_finalposition;
% %  project.epoching.baseline_duration.s
% %
% % NOTE: trials with boundary events are discharged from epoching
% %
function OUTEEG =  proj_eeglab_subject_replacebaseline_external(EEG, project, subj_name,varargin)

OUTEEG = EEG;

subj_list                      = {project.subjects.data.name};
subj_index                     = ismember(subj_list, subj_name);
baseline_file                  = project.subjects.data(subj_index).baseline_file;
replace                        = project.epoching.baseline_replace.replace;



data_path = EEG.filepath;


% if the baseline file name is empty, then take the file with the whole
% recording
if isempty(baseline_file)
    
    EEG_baseline = OUTEEG;
else
    % if indicated a baseline file, use the indicated file
    EEG_baseline = pop_loadset(EEG.filepath,baseline_file);
end


[sort_lat sort_order] = sort([OUTEEG.event.latency]);

OUTEEG.event = OUTEEG.event(sort_order);

OUTEEG = eeg_checkset(OUTEEG);

% begin_trial      = project.epoching.baseline_replace.trial_begin_marker;
% end_trial        = project.epoching.baseline_replace.trial_end_marker;


begin_trial         = project.preproc.marker_type.begin_trial;
end_trial           = project.preproc.marker_type.end_trial;
begin_baseline      = project.preproc.marker_type.begin_baseline;
end_baseline        = project.preproc.marker_type.end_baseline;
final_baseline        = project.epoching.baseline_replace.baseline_finalposition;

epoch_tw           = [project.epoching.epo_st.s project.epoching.epo_end.s];
baseline_tw        = [0         project.epoching.baseline_duration.s];



type_list   = project.epoching.valid_marker;


all_eve_types = {OUTEEG.event.type};
tot_eve       = length(OUTEEG.event);
all_eve_ind   = 1:tot_eve;

boudary_ind   = find(   ismember(all_eve_types, 'boundary')  );

begin_trial_ind = find(   ismember(all_eve_types, begin_trial)  ); % se ho aggiunto una baseline prima del primo evento, il trigger di inizio trial è il nuovo inizio baseline
end_trial_ind   = find(   ismember(all_eve_types, end_trial)    );


% trovare più vicini boudary successivi a ogni inizio trial
out = find_next_vec(begin_trial_ind, boudary_ind);
boundary_trial_ind = out.vec2_next;

trial_noboudary =  begin_trial_ind(  (boundary_trial_ind < begin_trial_ind ) | (boundary_trial_ind > end_trial_ind )  );

% for each type of target event
for ntype = 1:length(type_list)
    
    type          = type_list{ntype};
    type_ind      = find(   ismember(all_eve_types, type)  );
    
    out = find_next_vec(trial_noboudary, type_ind);
    type_noboudary = out.vec2_next;
    
    % epoch around experimental event (target file in which substitute
    % baseline)
    OUTEEG_target   = pop_epoch( OUTEEG, {type},           epoch_tw,    'eventindices', type_noboudary);
    
    % epoch baseline file obtaining epochs form 0 tolength of baseline
    OUTEEG_baseline = pop_epoch( EEG_baseline, {begin_baseline}, baseline_tw);
    
    
    switch final_baseline
        case 'before'
            sel_replace_baseline = OUTEEG_target.times < 0;
            
        case 'after'
            sel_replace_baseline = OUTEEG_target.times > 0;
    end
    
    nepo = OUTEEG_target.trials;
    ltt = sum(sel_replace_baseline);
    lbt= OUTEEG_baseline.pnts;
    
    
    
%     if ltt < lbt
%         data4replace =  OUTEEG_baseline.data(:,1:ltt,1:nepo);
%         
%     elseif ltt > lbt
%         dlt = ltt -lbt;
        
%         switch replace
            
%             case 'all'
%                 data4replace = cat(2, OUTEEG_baseline.data, OUTEEG_baseline.data(:,1:dlt,1:nepo));
                
%             case 'part'
%                 data4replace = OUTEEG_target.data(:,sel_replace_baseline,:);
%                 if strcmp(final_baseline,'before')
%                     data4replace(:,1:lbt,1:nepo) = OUTEEG_baseline.data(:,:,1:nepo);
%                     
%                 elseif strcmp(final_baseline,'after')
%                     data4replace(:,	dlt+1:ltt,1:nepo) = OUTEEG_baseline.data(:,:,1:nepo);
%                     
%                 else
%                     disp('select a valid project.epoching.baseline_replace.replace');
%                     return
%                 end
%         end
        
%     else
        data4replace =  OUTEEG_baseline.data;
%     end
    
    
    OUTEEG_target.data(:,sel_replace_baseline,:) = data4replace(:,:,1:nepo);
    
    ALLEEG2(ntype) = OUTEEG_target;
end

OUTEEG = pop_mergeset( ALLEEG2, 1:length(ALLEEG2), 0 );
OUTEEG = eeg_checkset(OUTEEG);













% %% function OUTEEG =  proj_eeglab_subject_replacebaseline_external(EEG, project, subj_name,varargin)
% %
% % adjust baseline by replaceing before / after target events in each trial baseline segments taken outside the same trial and originally placed before / after the target events
% %
% % project is a structure with the fields:
% %
% %  project.epoching.epo_st.s;
% %  project.epoching.epo_end.s;
% %  project.epoching.mrkcode_cond;
% %  project.epoching.baseline_replace.baseline_begin_marker;
% %  project.epoching.baseline_replace.baseline_end_marker;
% %  project.epoching.bc_st.s;
% %  project.epoching.bc_end.s;
% %  project.epoching.baseline_replace.mode;
% %  project.epoching.baseline_replace.baseline_originalposition;
% %  project.epoching.baseline_replace.baseline_finalposition;
% %  project.epoching.baseline_duration.s
% %
% % NOTE: trials with boundary events are discharged from epoching
% %
% function OUTEEG =  proj_eeglab_subject_replacebaseline_external(EEG, project, subj_name,varargin)
%
%
%
% OUTEEG = EEG;
%
% subj_list                      = {project.subjects.data.name};
% subj_index                     = ismember(subj_list, subj_name);
% baseline_file                  = project.subjects(subj_index).data.baseline_file;
%
%
%
% data_path = EEG.filepath;
%
% if isempty(baseline_file)
%
%     EEG_baseline =OUTEEG;
% else
%
%     EEG_baseline = pop_loadset(EEG.filepath,baseline_file);
% end
%
% % total number of events in the dataset
% tot_eve = length(EEG.event);
%
% % for each event of each trial, replace a baseline taken from a pool in the
% % same/in another file
%
% % find markers of begin trial followed by another begin trial (to
% % delimit each trial)
% [begin_trial_all_index ,urnbrs,urnbrtypes,begin_trial_all_duration,tflds,urnflds] = eeg_context(EEG,...
%     project.epoching.baseline_replace.trial_begin_marker,...
%     project.epoching.baseline_replace.trial_begin_marker,...
%     1);
%
%
% % find markers of begin trial followed a boundary event
% [begin_trial_boundary_index,urnbrs,urnbrtypes,begin_trial_boundary_duration,tflds,urnflds] = eeg_context(EEG,...
%     project.epoching.baseline_replace.trial_begin_marker,...
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
% event_in_trials_without_boundary_index = true(1,tot_eve);
%
% % unselect events in trial with boundaries
%
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
%
%
% % select and epoch the events 1) within trials without boundaries AND 2) of the selected target type
% sel_target2epoch = find(event_in_trial_without_boundary);
%
% % during epoching there is the possibility to selecto events BOTH by
% % type AND by index
% [EEG_target, indices] = pop_epoch( EEG, {mark_cond_label}, ...
%     [project.epoching.epo_st.s project.epoching.epo_end.s],...
%     'eventindices',sel_target2epoch);
%
%
% [EEG_baseline, indices] = pop_epoch( EEG_baseline, {project.epoching.baseline_replace.baseline_begin_marker}, ...
%     [0         project.epoching.baseline_duration.s]);...
%
%
% % if the new baseline must be added before the target events
% if strcmp (project.epoching.baseline_replace.baseline_position, 'before')
%     sel_replace_baseline = EEG_target.times < 0;
% end
%
% % if the new baseline must be added after the target events
% if strcmp (project.epoching.baseline_replace.baseline_position, 'after')
%     sel_replace_baseline = EEG_target.times > 0;
% end
%
% for ntrial = 1: EEG_target.trials
%     EEG_target(sel_replace_baseline,:,ntrial) = EEG_baseline(:,:,ntrial);
% end
%
% OUTEEG = EEG_target;
%
%
%
%
% end