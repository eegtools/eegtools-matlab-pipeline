%% EEG = proj_eeglab_subject_epoching(project, varargin)
% read input .set file, do a global baseline correction and then do epoching
% varargin
%           ifs : suffix to append to subjname and project.import.original_data_suffix to obtain input file name
%           idn : input directory
%           odn : output directory name.
%           mrk_code :
%           mrk_name :
%           epo_st :
%           epo_end :
%           bc_st :
%           bc_end :

function EEG = proj_eeglab_subject_epoching(project, varargin)

... default values
    epoch_start             = project.epoching.epo_st.s;
epoch_end               = project.epoching.epo_end.s;
baseline_corr_start     = project.epoching.bc_st.ms;
baseline_corr_end       = project.epoching.bc_end.ms;
mark_cond_code          = project.epoching.mrkcode_cond;
mark_cond_names         = project.epoching.condition_names;
bc_type                 = project.epoching.bc_type;

list_select_subjects    = project.subjects.list;
get_filename_step       = 'input_epoching';
custom_suffix           = '';
custom_input_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects'  , ...
                'get_filename_step'     , ...
                'custom_input_folder'   , ...
                'custom_suffix'         , ...
                'mrk_code'              , ...
                'mrk_name'              , ...
                'epo_st'                , ...
                'epo_end'               , ...
                'bc_st'                 , ...
                'bc_end'                , ...
                'bc_type'               , ...
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
    
    subj_name                   = list_select_subjects{subj};
    
    input_file_name             = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    EEG                         = pop_loadset(input_file_name);
    
    
%      aal_eve = ({EEG.event.type});
%      ssel_eve = ismember(aal_eve, [mark_cond_code{1:length(mark_cond_code)}]);
%      eve_old = EEG.event;
%      EEG.event=EEG.event(ssel_eve);
    
    EEG.icaact_unfiltered=[];
    EEG.icaact_filtered_resampled=[];
    EEG.dipfit=[];
    EEG.icaact=[];
    EEG.etc =[];
    EEG.reject=[];
    EEG.stats=[];
    EEG.virtual_topography=[];
    EEG.virtual_chanlocs=[];
    EEG.virtual_nbchan=[];
    EEG.urevent = [];
    
    
    if strcmp(project.epoching.baseline_replace.mode,'trial') || strcmp(project.epoching.baseline_replace.mode,'external')
        EEG = proj_eeglab_subject_replacebaseline(project, EEG, subj_name);
        if isempty(EEG)
            return
        end
        if strcmp(project.epoching.baseline_replace.mode,'external')
            bc_type = 'global';
            disp('replacing baseline using external file makes global baseline correction the only alternative!')
        end
        
        
        
    end
    
    if isempty(EEG)
        disp('ERROR.....exiting')
        return;
    end
    
    bck.dir     = fullfile(EEG.filepath, 'hist_pre_epoching');
    bck.prefix  = [];
    EEG         = eeglab_subject_bck_eeghist(EEG,bck);
    
    
    switch bc_type
        case 'global'
            EEG = pop_epoch(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
            EEG = eeg_checkset(EEG);
            EEG = pop_rmbase(EEG, [baseline_corr_start baseline_corr_end]);
            EEG = eeg_checkset(EEG);
            
            % C1 repeated cicle: first run does not save
            for cond=1
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
                    EEG2                = eeg_checkset(EEG2);
                    clear EEG2
                end
            end
            
            for cond=1:length(mark_cond_code)
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
                    
                    sel_eve             = ismember({EEG2.event.type},[mark_cond_code{cond}]);
                    EEG2.event          = EEG2.event(sel_eve);
                    EEG2                = eeg_checkset(EEG2);
                    
                    output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
                    [path, out]         = fileparts(output_file_name);
                    EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
                    clear EEG2
                end
            end
            
        case 'condition'
            for cond=1:length(mark_cond_code)
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
                    EEG2                = pop_rmbase(EEG2, [baseline_corr_start baseline_corr_end]);
                    
                    sel_eve             = ismember({EEG2.event.type},[mark_cond_code{cond}]);
                    EEG2.event          = EEG2.event(sel_eve);
                    
                    EEG2                = eeg_checkset(EEG2);
                    
                    output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
                    [path, out]         = fileparts(output_file_name);
                    EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
                    clear EEG2
                end
            end
            
%         case 'trial'
%             EEG                 = pop_epoch(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
%             
%             srate               = EEG.srate;
%             pnt                 = EEG.pnts;
%             xmin                = EEG.xmin;  ... in seconds
%                 xmax                = EEG.xmax;
%             
%             baseline_point      = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
%             baseline_point(1)   = max(baseline_point(1), 1);
%             
%             
%             mbs                 = mean(EEG.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
%             baseline            = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
%             EEG.data            = EEG.data-baseline;
%             
%             for cond=1:length(mark_cond_code)
%                 if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
%                     EEG2                = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
%                     
%                     sel_eve             = ismember({EEG2.event.type},[mark_cond_code{cond}]);
%                     EEG2.event          = EEG2.event(sel_eve);
%                     
%                     EEG2                = eeg_checkset(EEG2);
%                     
%                     output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
%                     [path, out]         = fileparts(output_file_name);
%                     EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
%                     clear EEG2
%                 end
%             end

case 'trial'
%             EEG                 = pop_epoch(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
            
           

for cond=1:length(mark_cond_code)
    if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
        EEG2                = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
        
        sel_eve             = ismember({EEG2.event.type},[mark_cond_code{cond}]);
        EEG2.event          = EEG2.event(sel_eve);
        
        
        srate               = EEG2.srate;
        pnt                 = EEG2.pnts;
        xmin                = epoch_start;  ... in seconds
        xmax                = epoch_end;
        
        baseline_point      = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
        baseline_point(1)   = max(baseline_point(1), 1);
            
            
        mbs                 = mean(EEG.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
        baseline            = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
        EEG.data            = EEG.data-baseline;
                
        
        EEG2                = eeg_checkset(EEG2);
        
        output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
        [path, out]         = fileparts(output_file_name);
        EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
        clear EEG2
    end
end









        case 'none'
            EEG = pop_epoch(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
            EEG = eeg_checkset(EEG);
            
            
            % C1 repeated cicle: first run does not save
            for cond=1
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
                    EEG2                = eeg_checkset(EEG2);
                    clear EEG2
                end
            end
            
            for cond=1:length(mark_cond_code)
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
                    EEG2                = eeg_checkset(EEG2);
                    
                    output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
                    [path, out]         = fileparts(output_file_name);
                    EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
                    clear EEG2
                end
            end
            
    end
end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name
% in proj_eeglab_subject_preprocessing the triggers filtering was restored

% 25/9/2014
% commented code block C1, repeated for cycle

% 18/6/2014
% added different epoching methods besided the global one: by condition & by trial
%
% permanently removed this lines after condition epoching: (invalid after 29/12/2014, see above)
%         % keep only selected events
%         seleve=[];eve_cond=mark_cond_code{cond}; tot_eve_cond=length(eve_cond);
%         for n_eve_type=1:tot_eve_cond; seleve(n_eve_type,:)=strcmp({EEG2.event.type},eve_cond(n_eve_type));end
%         seleve_vec=find(sum(seleve,1)); EEG2.event=EEG2.event(seleve_vec);



