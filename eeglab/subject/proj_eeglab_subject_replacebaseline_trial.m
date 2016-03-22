%% function OUTEEG =  proj_eeglab_subject_replacebaseline_trial(OUTEEG, project,varargin)
%
% adjust baseline by replacing before / after target events in each trial baseline segments taken within the same trial and originally placed before / after the target events
%
% project is a structure with the fields:
%
%  project.epoching.epo_st.s;
%  project.epoching.epo_end.s;
%  project.epoching.mrkcode_cond;
%  project.epoching.baseline_replace.baseline_begin_marker;
%  project.epoching.baseline_replace.baseline_end_marker;
%  project.epoching.bc_st.s;
%  project.epoching.bc_end.s;
%  project.epoching.baseline_replace.mode;
%  project.epoching.baseline_replace.baseline_originalposition;
%  project.epoching.baseline_replace.baseline_finalposition;
%  project.epoching.baseline_duration.s
%
% NOTE: trials with boundary events are discharged from epoching
%
% function OUTEEG =  proj_eeglab_subject_replacebaseline_trial(EEG, project,varargin)

function OUTEEG =  proj_eeglab_subject_replacebaseline_trial(EEG, project,varargin)


    OUTEEG = EEG;

    [sort_lat sort_order] = sort([OUTEEG.event.latency]);

    OUTEEG.event        = OUTEEG.event (sort_order);

    OUTEEG              = eeg_checkset(OUTEEG);

    begin_trial         = project.preproc.marker_type.begin_trial;
    end_trial           = project.preproc.marker_type.end_trial;
    begin_baseline      = project.preproc.marker_type.begin_baseline;
    end_baseline        = project.preproc.marker_type.end_baseline;

    original_baseline   = project.epoching.baseline_replace.baseline_originalposition;
    final_baseline      = project.epoching.baseline_replace.baseline_finalposition;

    epoch_tw            = [project.epoching.epo_st.s project.epoching.epo_end.s];
    baseline_tw         = [0 project.epoching.baseline_duration.s];

    replace             = project.epoching.baseline_replace.replace;


    type_list           = project.epoching.valid_marker;


    all_eve_types       = {OUTEEG.event.type};
    tot_eve             = length(OUTEEG.event);
    all_eve_ind         = 1:tot_eve;

    % marker indexes
    boudary_ind         = find(ismember(all_eve_types, 'boundary'));
    begin_trial_ind     = find(ismember(all_eve_types, begin_trial)); % se ho aggiunto una baseline prima del primo evento, il trigger di inizio trial è il nuovo inizio baseline
    end_trial_ind       = find(ismember(all_eve_types, end_trial));
    begin_baseline_ind  = find(ismember(all_eve_types, begin_baseline));
    end_baseline_ind    = find(ismember(all_eve_types, end_baseline));


    if isempty(begin_trial_ind) || isempty(end_trial_ind) || isempty(begin_baseline_ind) || isempty(end_baseline_ind)
        error(['error in proj_eeglab_subject_replacebaseline_trial. length begin_trial_ind=' num2str(length(begin_trial_ind)) ',length end_trial_ind=' num2str(length(end_trial_ind)) ',length begin_baseline_ind=' num2str(length(begin_baseline_ind)) ',length end_baseline_ind=' num2str(length(end_baseline_ind))]);
    end

    % % trovare più vicini boudary successivi a ogni inizio trial
    % out = find_next_vec(begin_trial_ind, boudary_ind);
    % boundary_trial_ind = out.vec2_next;



    % trial_noboudary =  begin_trial_ind(  (boundary_trial_ind < begin_trial_ind ) | (boundary_trial_ind > end_trial_ind )  );

    sel_noboudary       = true(size(begin_trial_ind));
    sel_noboudary_eve   = true(size(all_eve_types));

%     try
        for nn = 1:length(sel_noboudary)
            begin_t = begin_trial_ind(nn);
            end_t   = end_trial_ind(nn);

            % if one of the boundaries occurs between the begin and the end of the trial
            with_boundary = sum(boudary_ind >= begin_t & boudary_ind <= end_t);
            if with_boundary
                sel_noboudary(nn) = false;
                sel_noboudary_eve(all_eve_ind > begin_t & all_eve_ind < end_t ) = false;
            end
        end


        trial_noboudary =  begin_trial_ind(sel_noboudary);


        % for each type of target event
        for ntype = 1:length(type_list)

            type            = type_list{ntype};
            type_noboudary  = find(   ismember(all_eve_types, type)  & sel_noboudary_eve);

            ...out             = find_next_vec(trial_noboudary, type_ind);...type_noboudary  = unique(out.vec2_next(not(isnan(out.vec2_next))));

        
            % select those baseline intervals within those trials containing the specified type
            sel_trial       = false(size(begin_trial_ind));
            sel_trial_eve   = false(size(all_eve_types));

            for nn = 1:length(begin_trial_ind)
                begin_t = begin_trial_ind(nn);
                end_t   = end_trial_ind(nn);

                with_eve = sum( type_noboudary >= begin_t &  type_noboudary <= end_t);
                if with_eve
                    sel_trial(nn) = true;
                    sel_trial_eve(all_eve_ind >= begin_t & all_eve_ind <= end_t ) = true;
                end
            end
            sel_begin_baseline_ind = find(ismember(all_eve_ind,begin_baseline_ind) & sel_trial_eve);


            switch original_baseline
                case 'before'
                    out = find_previous_vec(type_noboudary, sel_begin_baseline_ind);
                    baseline_noboudary = out.vec2_previous;

                case 'after'
                    out = find_next_vec(type_noboudary, sel_begin_baseline_ind);
                    baseline_noboudary = out.vec2_next;
            end


            if not(isempty(type_noboudary))
                [OUTEEG_target, target_indices]     = pop_epoch( OUTEEG, {type},           epoch_tw,    'eventindices', type_noboudary);
            end

            if not(isempty(baseline_noboudary))
                [OUTEEG_baseline, baseline_indices] = pop_epoch( OUTEEG, {begin_baseline}, baseline_tw, 'eventindices', baseline_noboudary);
            end

            target_trials   = OUTEEG_target.trials;
            baseline_trials = OUTEEG_baseline.trials;

            if target_trials ~= baseline_trials
                warning(['ntype: ' type ' number of target trials differs from baseline trials: ' num2str(target_trials) '::' num2str(baseline_trials)]);
                OUTEEG = [];
                return;
            end

            switch final_baseline
                case 'before'
                    sel_replace_baseline = OUTEEG_target.times < 0;

                case 'after'
                    sel_replace_baseline = OUTEEG_target.times > 0;
            end

            ltt = sum(sel_replace_baseline);
            lbt= OUTEEG_baseline.pnts;



            if ltt < lbt
                data4replace =  OUTEEG_baseline.data(:,1:ltt,:);

            elseif ltt > lbt

                dlt = ltt -lbt;

                switch replace
                    case 'all'
                        data4replace = cat(2, OUTEEG_baseline.data, OUTEEG_baseline.data(:,1:dlt,:));

                    case 'part'
                        data4replace = OUTEEG_target.data(:,sel_replace_baseline,:);

                        if strcmp(final_baseline,'before')
                            data4replace(:,1:lbt,:) = OUTEEG_baseline.data(:,:,:);


                        elseif strcmp(final_baseline,'after')
                            data4replace(:,	dlt+1:ltt,:) = OUTEEG_baseline.data(:,:,:);

                        else
                            disp('select a valid project.epoching.baseline_replace.replace');
                            return
                        end



                end
            else
                data4replace =  OUTEEG_baseline.data;
            end


            OUTEEG_target.data(:,sel_replace_baseline,:) = data4replace*0;

            ALLEEG2(ntype) = OUTEEG_target;
        end

        if length(ALLEEG2) > 1
            OUTEEG = pop_mergeset( ALLEEG2, 1:length(ALLEEG2), 1 );
        else
            OUT_EEG = ALLEEG2(1);
        end
        OUTEEG = eeg_checkset(OUTEEG);

%     catch err
%         err;
%     end

end



%% function OUTEEG =  proj_eeglab_subject_replacebaseline_trial(OUTEEG, project,varargin)
%
% replace baseline by replaceing before / after target events in each trial baseline segments taken within the same trial and originally placed before / after the target events
%
% project is a structure with the fields:
%
%  project.epoching.epo_st.s;
%  project.epoching.epo_end.s;
%  project.epoching.mrkcode_cond;
%  project.epoching.baseline_replace.baseline_begin_marker;
%  project.epoching.baseline_replace.baseline_end_marker;
%  project.epoching.bc_st.s;
%  project.epoching.bc_end.s;
%  project.epoching.baseline_replace.mode;
%  project.epoching.baseline_replace.baseline_originalposition;
%  project.epoching.baseline_replace.baseline_finalposition;
%  project.epoching.baseline_duration.s
%
% NOTE: trials with boundary events are discharged from epoching
%
% function OUTEEG =  proj_eeglab_subject_replacebaseline_trial(OUTEEG, project,varargin)
%
% ll=length({OUTEEG.event.urevent});
% for nn =1:ll
%     OUTEEG.event(nn).urevent=nn;
% end
%
% OUTEEG.urevent = OUTEEG.event;
% OUTEEG=eeg_checkset(OUTEEG);
%
%
%
% % total number of events in the dataset
% tot_eve = length(OUTEEG.event);
%
% % for each event of each trial, replace a baseline taken from the trial itself
%
% % find markers of begin trial followed by another begin trial (to
% % delimit each trial)
% [begin_trial_all_index ,urnbrs,urnbrtypes,begin_trial_all_duration,tflds,urnflds] = eeg_context(OUTEEG,...
%     project.epoching.baseline_replace.trial_begin_marker,...
%     project.epoching.baseline_replace.trial_begin_marker,...
%     1);
%
%
% % find markers of begin trial followed a boundary event
% [begin_trial_boundary_index,urnbrs,urnbrtypes,begin_trial_boundary_duration,tflds,urnflds] = eeg_context(OUTEEG,...
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
% for nevetype = 1:length(type_list)
%
%     % select the corresponding type (label)
%     mark_cond_label = type_list{nevetype};
%
% %     % for each of all events
% %     for neve = 1:length(OUTEEG.event)
% %         event_in_trial_without_boundary =  false;
% %     end
%
%     % find the selected target events
%
%     % if the baseline segments were originally before the target events
%     if strcmp(project.epoching.baseline_replace.baseline_originalposition, 'before')
%
%         % find target events precededed by baseline segments
%         [target_index,baseline_begin_index,urnbrtypes,duration,tflds,urnflds] = eeg_context(OUTEEG,...
%             mark_cond_label,...
%             project.epoching.baseline_replace.baseline_begin_marker,...
%             -1);
%
% %         %find baseline segments followed by target events
% %         [baseline_begin_index,baseline_begin_index,urnbrtypes,duration,tflds,urnflds] = eeg_context(OUTEEG,...
% %             project.epoching.baseline_replace.baseline_begin_marker,...
% %             mark_cond_label,...
% %             1);
%
%         % calculate baseline duration for each baseline segment (in
%         % principle it could vary)
%         [all_baseline_begin_index,urnbrs,urnbrtypes,all_baseline_duration,tflds,urnflds] = eeg_context(OUTEEG,...
%             project.epoching.baseline_replace.baseline_begin_marker,...
%             project.epoching.baseline_replace.baseline_end_marker,...
%             1);
%
%     end
%
%     % if the baseline segments were originally after the target events
%     if strcmp(project.epoching.baseline_replace.baseline_originalposition, 'after')
%
%         % find target events follwed by baseline segments
%         [target_index,urnbrs,urnbrtypes,trial_duration,tflds,urnflds] = eeg_context(OUTEEG,...
%             mark_cond_label,...
%             project.epoching.baseline_replace.baseline_begin_marker,...
%             1);
%
%         %find baseline segments preceded by target events
%         [all_baseline_begin_index,urnbrs,urnbrtypes,trial_duration,tflds,urnflds] = eeg_context(OUTEEG,...
%             project.epoching.baseline_replace.baseline_begin_marker,...
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
%     [OUTEEG_target, indices] = pop_epoch( OUTEEG, {mark_cond_label}, ...
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
%     [OUTEEG_baseline, indices] = pop_epoch( OUTEEG, {project.epoching.baseline_replace.baseline_begin_marker}, ...
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
%     % actually in OUTEEG_base epochs have the requested baseline duration, but in the case of 2), part of the epochs must be overwritten with baseline points
%
%     for ntrial = 1:OUTEEG_baseline.trial
%
%         baseline_duration_trial = baseline_duration(ntrial);
%
%         if baseline_duration_trial < project.epoching.baseline_duration.s
%             times2rep_trial = OUTEEG_baseline.times <= baseline_duration_trial;
%
%             % replicate the real baseline
%             nrep         = ceil(project.epoching.baseline_duration.s / baseline_duration_trial);
%             segment2rep  = OUTEEG_baseline.data(times2rep_trial,:,ntrial);
%             rep_baseline = rep(segment2rep,1,nrep);
%
%             % remove exceding points
%             cut_vec                = length(rep_baseline) <= OUTEEG_baseline.times;
%             cut_baseline           = rep_baseline(cut_vec);
%
%             % replace the baseline of the trial with the interpolated version
%             OUTEEG_baseline(:,:,ntrial)   = cut_baseline;
%         end
%     end
%
%     % if the new baseline must be added before the target events
%     if strcmp (project.epoching.baseline_replace.baseline_position, 'before')
%         sel_replace_baseline = OUTEEG_target.times < 0;
%     end
%
%     % if the new baseline must be added after the target events
%     if strcmp (project.epoching.baseline_replace.baseline_position, 'after')
%         sel_replace_baseline = OUTEEG_target.times > 0;
%     end
%
%     for ntrial = 1: OUTEEG.trials
%         OUTEEG_target(sel_replace_baseline,:,ntrial) = OUTEEG_baseline(:,:,ntrial);
%     end
%
%     OUTEEG_evetype = OUTEEG_target;
%
%     ALLOUTEEG2(nevetype) = OUTEEG_evetype;
% end
%
% OUTEEG = pop_mergeset( ALLOUTEEG2, 1:length(ALLOUTEEG2), 0 );
% OUTEEG = eeg_checkset(OUTEEG);
%
% end