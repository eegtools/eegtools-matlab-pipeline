function OUTEEG = proj_eeglab_subject_markbaseline_external(EEG_target,EEG_baseline, project, subj_name, varargin)

OUTEEG = EEG_baseline;

subj_list                       =  {project.subjects.data.name};
subj_index                      =  ismember(subj_list, subj_name);

if isempty(project.subjects.baseline_file_interval_s)
    project.subjects.baseline_file_interval_s = OUTEEG.pnts/OUTEEG.srate;
end

baseline_file_interval_pts      =  floor(project.subjects.baseline_file_interval_s * OUTEEG.srate);
baseline_duration_pts           =  floor(project.epoching.baseline_duration.s * OUTEEG.srate);

list_eve_target = {EEG_target.event.type};
eve_target_baseline = EEG_target.event;

for neve = 1:length(list_eve_target)
    
    lat1 = baseline_file_interval_pts(1) + (neve-1) *baseline_file_interval_pts;
    lat2 = lat1 + baseline_duration_pts;
        
    n1 = length(OUTEEG.event)+1;
    n2 = length(OUTEEG.event)+2;
    
    OUTEEG.event(n1)         =   eve_target_baseline(neve);
    OUTEEG.event(n1).latency =   lat1;
    OUTEEG.event(n1).type    =   project.preproc.marker_type.begin_baseline;
        
    OUTEEG.event(n2)         =   eve_target_baseline(neve);
    OUTEEG.event(n2).latency =   lat2;
    OUTEEG.event(n2).type    =   project.preproc.marker_type.begin_baseline;
    
end

OUTEEG = eeg_checkset(OUTEEG);
end