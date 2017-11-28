function OUTEEG = proj_eeglab_subject_markbaseline_trial(EEG, project, varargin)


% project.epoching.baseline_replace.baseline_begin_marker
% project.epoching.baseline_replace.baseline_end_marker
%
%
% project.epoching.baseline_mark.baseline_begin_target_marker                                    % a target event for placing the baseline markers: baseline begin marker will be placed at the target marker with a selected delay.
% project.epoching.baseline_mark.baseline_begin_target_marker_delay.s                            % the delay (in seconds) between the target marker and the begin baseline marker to be placed:
%                                                                                                 % >0 means that baseline begin FOLLOWS the target,
%                                                                                                 % =0 means that baseline begin IS AT THE SAME TIME the target,
%                                                                                                 % <0 means that baseline begin ANTICIPATES the target.
%                                                                                                 % IMPOTANT NOTE: The latency information is displayed in seconds for continuous data,
%                                                                                                 % or in milliseconds relative to the epoch's time-locking event for epoched data.
%                                                                                                 % As we will see in the event scripting section,
%                                                                                                 % the latency information is stored internally in data samples (points or EEGLAB 'pnts')
%                                                                                                 % relative to the beginning of the continuous data matrix (EEG.data).
%
% project.epoching.baseline_duration.s    = project.epoching.bc_end.s - project.epoching.bc_st.s ;


OUTEEG = EEG;

alleve_type = {OUTEEG.event.type};
alleve_lat = [OUTEEG.event.latency];

% stringa che denota t1/t2
t1 =project.preproc.marker_type.begin_trial;
t2 =project.preproc.marker_type.end_trial;

% seleziono gli indici dei t1/t2
sel_t1 = find(ismember(alleve_type, t1));
sel_t2 = find(ismember(alleve_type, t2));

% latenze di tutti i t1/t2
lat_t1 = alleve_lat(sel_t1);
lat_t2 = alleve_lat(sel_t2);

% perchè so che i t1 sono già stati appaiati ad i t2 dal mark trial
tot_trial = length(sel_t1);


% cell array con i tipi di target per b1/b2
b1 = project.preproc.insert_begin_baseline.target_event_types;
b2 = project.preproc.insert_end_baseline.target_event_types;

% seleziono gli indici dei b1/b2
sel_b1 = find(ismember(alleve_type, b1));
sel_b2 = find(ismember(alleve_type, b2));

% latenze di tutti i b1/b2
lat_b1 = alleve_lat(sel_b1);
lat_b2 = alleve_lat(sel_b2);

good_b1 = false(size(lat_b1));
good_b2 = false(size(lat_b2));




delay_begin  = project.preproc.insert_begin_baseline.delay.s;
delay_begin_pts                   =  floor(delay_begin * OUTEEG.srate); % convert delay from seconds to points

delay_end  = project.preproc.insert_end_baseline.delay.s;
delay_end_pts                   =  floor(delay_end * OUTEEG.srate); % convert delay from seconds to points


for ntrial = 1: tot_trial
    
    lat_current_t1 = lat_t1(ntrial);
    lat_current_t2 = lat_t2(ntrial);
    
    sel_lat_current_b1 = lat_b1 > lat_current_t1 & lat_b1 < lat_current_t2;
    exist_current_b1 = not(isempty(sel_lat_current_b1));
    
    sel_lat_current_b2 = lat_b2 > lat_current_t1 & lat_b2 < lat_current_t2;
    exist_current_b2 = not(isempty(sel_lat_current_b2));
    
    
    exist_current_b1_b2 = exist_current_b1 && exist_current_b2;
    
    if exist_current_b1_b2
        good_b1(sel_lat_current_b1) = true;
        good_b2(sel_lat_current_b2) = true;
    end
    
    sel_good_b1 = find(good_b1 == true);
    sel_good_b2 = find(good_b2 == true);
    
    % quanti sono i segmenti buoni di base da aggiungere al tracciato
    tot_good_baseline = length(sel_good_b1);
end

eve_template = OUTEEG.event(1);

% per ciascun segmento buono di baseline
for nb = 1:tot_good_baseline
    
    n1 = length(OUTEEG.event)+1;
    n2 = length(OUTEEG.event)+2;
    % aggiungo il b1
    OUTEEG.event(n1)         =   eve_template;
    OUTEEG.event(n1).latency =   lat_b1(sel_good_b1(nb)) + delay_begin_pts;
    OUTEEG.event(n1).type    =   project.preproc.marker_type.begin_baseline;
    
    % aggiungo il b2
    OUTEEG.event(n2)         =   eve_template;
    OUTEEG.event(n2).latency =   lat_b2(sel_good_b2(nb)) + delay_end_pts;
    OUTEEG.event(n2).type    =   project.preproc.marker_type.end_baseline;
    
end


sorted_event      = OUTEEG.event;
[xx sort_vec]     = sort([OUTEEG.event.latency]);
sorted_event      = sorted_event(sort_vec);
OUTEEG.event      = sorted_event;


OUTEEG = eeg_checkset(OUTEEG);
end