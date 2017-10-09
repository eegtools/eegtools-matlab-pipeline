function OUTEEG = proj_eeglab_subject_markbaseline_external(EEG_target,EEG_baseline, project, subj_name, varargin)

% aeve = {EEG_baseline.event.type};
% sel_nb = not(ismember(aeve,{'boundary',project.preproc.marker_type.begin_baseline,project.preproc.marker_type.end_baseline}));
% EEG_baseline.event = EEG_baseline.event(sel_nb);

OUTEEG = EEG_baseline;

subj_list                       =  {project.subjects.data.name};
subj_index                      =  ismember(subj_list, subj_name);

if isempty(project.subjects.baseline_file_interval_s)
    project.subjects.baseline_file_interval_s = 1/OUTEEG.srate;
end

baseline_file_interval_pts      =  floor(project.subjects.baseline_file_interval_s * OUTEEG.srate);
baseline_duration_pts           =  floor(project.epoching.baseline_duration.s * OUTEEG.srate);

list_eve_target = {EEG_target.event.type};
eve_target_baseline = EEG_target.event;

sel_nb = not(ismember(list_eve_target,{'boundary', ...
    project.preproc.marker_type.begin_trial,project.preproc.marker_type.end_trial, ...
    project.preproc.marker_type.begin_baseline,project.preproc.marker_type.end_baseline}));


evenum = [];
list_eve_num = unique(list_eve_target(sel_nb));
for ne = 1:length(list_eve_num)
    evenum(ne) = sum(ismember(list_eve_target, list_eve_num(ne)));
end

maxnum = max(evenum);

sel_1eve = find(ismember(list_eve_target,list_eve_num),1,'first');

OUTEEG.event = EEG_target.event(sel_1eve);

for neve = 1:maxnum+100
%      lat1 = baseline_file_interval_pts(1) + (neve-1) *floor(baseline_duration_pts) +1;
        lat1 = baseline_file_interval_pts(1) + (neve-1) *floor(baseline_duration_pts/3)+1;
%     lat1 = baseline_file_interval_pts(1) + 1; schifo, vengono troppo
%     vicine, troppo autocorrelate, non c'è cancellazione da averaging
    
    lat2 = lat1 + baseline_duration_pts;
    
    n1 = length(OUTEEG.event)+1;
    n2 = length(OUTEEG.event)+2;
    
    for ne = 1:length(eve_target_baseline)
        eve_target_baseline(ne).duration = 0;
    end
    
    
    for ne = 1:length(OUTEEG.event)
        OUTEEG.event(ne).duration = 0;
        OUTEEG.event(ne).urevent  = 0;
        
    end
    
    OUTEEG.event(n1)         =   eve_target_baseline(neve);
    OUTEEG.event(n1).latency =   lat1;
    OUTEEG.event(n1).type    =   project.preproc.marker_type.begin_baseline;
    
    OUTEEG.event(n2)         =   eve_target_baseline(neve);
    OUTEEG.event(n2).latency =   lat2;
    OUTEEG.event(n2).type    =   project.preproc.marker_type.end_baseline;
    
end
OUTEEG.event = OUTEEG.event(2:end);

OUTEEG = eeg_checkset(OUTEEG);
end