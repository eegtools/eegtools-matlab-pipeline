%% function [OUTEEG, rt_cell] =  eeglab_subject_calculate_rt(EEG, params)
%
% calculate reaction times as the duration of the period between 2 given
% types of events eve1 and eve2
%
% params is a structure with the field
%
% params.eve1_type               = string or cell array of strings with the first event(s) type(s) from which start
%                                  count the duration
% params.eve2_type               = string with the second event type
%
% params.allowed_tw_ms.min  = the minimum latency allowed for the duration beteween eve1 and eve2. if empty no inferior limit
% params.allowed_tw_ms.max  = the maximum latency allowed for the duration beteween eve1 and eve2  if empty no superior limit
%
% params.output_folder      = the folder where the rt files will be placed, if empty the same folder of the eeg data file
%
function [OUTEEG, rt_cell] =  eeglab_subject_calculate_rt(EEG, params)

OUTEEG = EEG;

data_filename    = OUTEEG.filename;
% data_filename    = regexprep(EEG.filename,' ','');
subj_name        = OUTEEG.subject;
group_name       = OUTEEG.group;
condition_name   = OUTEEG.condition;

if isempty(subj_name)
    subj_name            = 'undefined_subject';
end

if isempty(group_name)
    group_name           = 'undefined_group';
end

if isempty(condition_name)
    condition_name       = 'undefined_cond';
end

if isempty(params.output_folder)
    params.output_folder = OUTEEG.filepath;
    
end

if ~iscell(params.eve1_type)
    params.eve1 = {params.eve1_type};
end


rt_cell_data = [];

for neve1 = 1:length(params.eve1_type)
    
    
    
    % calculate duration between the each occurence of the first event type(s) (listed in eve1) and the following firt occurrence of the eve2 type
    [mat_ind_eve1,urnbrs,urnbrtypes,rt_eve1_eve2,tfields,urnfields] = eeg_context(OUTEEG,params.eve1_type(neve1),params.eve2_type,1);
    
    % calculate the inverse, to track the indices of eve2
    [mat_ind_eve2,urnbrs,urnbrtypes,rt_eve2_eve1,tfields,urnfields] = eeg_context(OUTEEG,params.eve2_type,params.eve1_type(neve1),-1);
    
    % calculate duration between the each occurence of the first event type(s) and the following firt occurrence of the first event type(s)
    [mat_ind_eve1,urnbrs,urnbrtypes,rt_eve1_eve1,tfields,urnfields] = eeg_context(OUTEEG,params.eve1_type(neve1),params.eve1_type(neve1),1);
    
    % avoid the selection of events which CONTAIN the string of the event
    % types, take only exact match
    
    
    ind_eve1      = mat_ind_eve1(:,1);
    ind_eve2      = mat_ind_eve2(:,1);
    
    eve1_type   = {OUTEEG.event(ind_eve1).type}';
    eve2_type   = {OUTEEG.event(ind_eve2).type}';
    
    sel_exact_match_eve1 = ismember(eve1_type, params.eve1_type);
    sel_exact_match_eve2 = ismember(eve2_type, params.eve2_type);
    
    
    ind_eve1      = ind_eve1(sel_exact_match_eve1,1);
    ind_eve2      = ind_eve2(sel_exact_match_eve2,1);
    
    rt_eve1_eve2  = rt_eve1_eve2(sel_exact_match_eve1);
    rt_eve2_eve1  = -rt_eve1_eve2(sel_exact_match_eve2);
    rt_eve1_eve1  = rt_eve1_eve1(sel_exact_match_eve1);
    
    eve1_type     =  eve1_type(sel_exact_match_eve1);
    eve2_type     =  eve2_type(sel_exact_match_eve2);
    
    eve1_latency  = [OUTEEG.event(ind_eve1).latency]';
    eve2_latency  = [OUTEEG.event(ind_eve2).latency]';
    
    
    file        = repmat({data_filename},length(eve1_type),1);
    subj        = repmat({subj_name},length(eve1_type),1);
    group       = repmat({group_name},length(eve1_type),1);
    cond        = repmat({condition_name},length(eve1_type),1);
    
    % create a vector with rt respecting the conditions: rt in the wanted
    % time limits and without intervening eve1 events
    selected_rt_eve1_eve2 = rt_eve1_eve2;
    selected_rt_eve2_eve1 = rt_eve2_eve1;
    
    % vor each rt, verify if conditions are ok
    for neve=1:length(rt_eve1_eve2) % For each rt between eve1 and eve2,
        
        condition1 = 1;
        condition2 = 1;
        
        % set the conditions
        if ~isempty(params.allowed_tw_ms.min)
            condition1 = rt_eve1_eve2(neve)  > params.allowed_tw_ms.min;                      %  'rt' latency in higher than the allowed minimum
        end
        
        if ~isempty(params.allowed_tw_ms.max)
            condition2 = rt_eve1_eve2(neve)  < params.allowed_tw_ms.max;                      %  'rt' latency in lower than the allowed maximum
        end
        
        condition3 = (rt_eve1_eve2(neve) < rt_eve1_eve1(neve) | isnan(rt_eve1_eve1(neve)));   % no intervening eve1 event
        
        % if any of the condition is violated
        if not(condition1 && condition2 && condition3)
            % replace the rt with nan
            selected_rt_eve1_eve2(neve) = nan;
            selected_rt_eve2_eve1(neve) = nan;
        else
            % add the rt field to the event structure
            OUTEEG.event(ind_eve1(neve)).rt = rt_eve1_eve2(neve);
            OUTEEG.event(ind_eve2(neve)).rt = rt_eve1_eve2(neve);
        end
    end
    rt_12          = num2cell(rt_eve1_eve2);
    rt_21          = num2cell(rt_eve2_eve1);
    ind_eve1       = num2cell(ind_eve1);
    ind_eve2       = num2cell(ind_eve2);
    eve1_latency   = num2cell(eve1_latency);
    eve2_latency   = num2cell(eve2_latency);
    
    
    selected_rt = num2cell(selected_rt_eve1_eve2);
    
    
    
    rt_cell_data_eve1 =  [ file,  group,  cond,  subj,   eve1_type,   eve2_type, ind_eve1, ind_eve2, eve1_latency,eve2_latency,  rt_12 ,  selected_rt ];
    
    rt_cell_data      =  [rt_cell_data; rt_cell_data_eve1];
end

rt_cell_data = sortrows(rt_cell_data, 7);


name_fields  =  {'file','group','cond','subj', 'eve1_type', 'eve2_type', 'ind_eve1', 'ind_eve2', 'eve1_latency_ms','eve2_latency_ms', 'rt_12_ms', 'selected_rt_ms'};

rt_cell      =        [name_fields;rt_cell_data ];




[path, fname, ext]=fileparts(OUTEEG.filename);

rt_cell_file_name = [params.output_folder,fname,'_rt.txt'];
fid = fopen(rt_cell_file_name,'a+');

fprintf(fid,     '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\r\n ',name_fields{:} );
for nn =1:size(rt_cell_data,1)
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %d\t %d\t %d\t %d\t %d\t  %d\r\n',rt_cell_data{nn,:});
end
fclose(fid);

end