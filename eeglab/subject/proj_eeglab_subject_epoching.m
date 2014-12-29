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
eeg_output_path         = project.paths.output_epochs;
eeg_input_path          = project.paths.input_epochs;
input_file_suffix       = project.epoching.input_suffix;
output_file_suffix      = project.epoching.input_suffix;
bc_type                 = project.epoching.bc_type;
list_select_subjects    = project.subjects.list;
numsubj                 = length(list_select_subjects);


options_num=size(varargin,2);
opt=1;

while options_num>0
    switch varargin{opt}
        case 'input_file_suffix'
            opt=opt+1;
            input_file_suffix=varargin{opt};
        case 'output_file_suffix'
            opt=opt+1;
            output_file_suffix=varargin{opt};
        case 'eeg_input_path'
            opt=opt+1;
            eeg_input_path=varargin{opt};
        case 'eeg_output_path'
            opt=opt+1;
            eeg_output_path=varargin{opt};
        case 'mrk_code'
            opt=opt+1;
            mark_cond_code=varargin{opt};
        case 'mrk_name'
            opt=opt+1;
            mark_cond_names=varargin{opt};
        case 'epo_st'
            opt=opt+1;
            epoch_start=varargin{opt};
        case 'epo_end'
            opt=opt+1;
            epoch_end=varargin{opt};
        case 'bc_st'
            opt=opt+1;
            baseline_corr_start=varargin{opt};
        case 'bc_end'
            opt=opt+1;
            baseline_corr_end=varargin{opt};
        case 'bc_type'
            opt=opt+1;
            bc_type=varargin{opt};
        case 'list_select_subjects'
            list_select_subjects = varargin{opt+1};
    end
    opt=opt+1;
    options_num=options_num-2;
end

numsubj = length(list_select_subjects);

for subj=1:numsubj
    subj_name = list_select_subjects{subj};
    % ----------------------------------------------------------------------------------------------------------------------------
    % create input filename
    input_file_name  = fullfile(eeg_input_path,  [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix input_file_suffix '.set']);
    output_file_name = fullfile(eeg_output_path, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix output_file_suffix '.set']);
    
    [path,in_name_noext,ext]  = fileparts(input_file_name);
    [path,out_name_noext,ext] = fileparts(output_file_name);
    
    EEG = pop_loadset(input_file_name);
    
    if strcmp(project.epoching.baseline_replace.mode,'trial') || strcmp(project.epoching.baseline_replace.mode,'external')
        EEG = proj_eeglab_subject_replacebaseline(project, subj_name);
    end
    
    
    
    bck.dir    = fullfile(EEG.filepath, 'hist_pre_epoching');
    bck.prefix = [];
    EEG = eeglab_subject_bck_eeghist(EEG,bck);
    
    %     EEG = proj_eeglab_subject_markbaseline(project, subj_name, varargin);
    %
    %     EEG = proj_eeglab_subject_adjustbaseline(project, subj_name, varargin);
    
    
    %     if strcmp(adjustbaseline_mode,'external')
    %         bc_type='global';
    %     end
    
    switch bc_type
        case 'global'
            EEG = pop_epoch(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
            EEG = eeg_checkset(EEG);
            EEG = pop_rmbase(EEG, [baseline_corr_start baseline_corr_end]);
            EEG = eeg_checkset(EEG);
            
            % C1 repeated cicle: first run does not save
            for cond=1
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2 = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
                    EEG2 = eeg_checkset(EEG2);
                    %                     EEG2 = pop_saveset(EEG2, 'filename',[out_name_noext '_' mark_cond_names{cond}], 'filepath', eeg_output_path);
                    clear EEG2
                end
            end
            
            for cond=1:length(mark_cond_code)
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2 = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
                    EEG2 = eeg_checkset(EEG2);
                    EEG2 = pop_saveset(EEG2, 'filename',[out_name_noext '_' mark_cond_names{cond}], 'filepath', eeg_output_path);
                    clear EEG2
                end
            end
            
        case 'condition'
            for cond=1:length(mark_cond_code)
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2 = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
                    EEG2 = pop_rmbase(EEG2, [baseline_corr_start baseline_corr_end]);
                    
                    EEG2 = eeg_checkset(EEG2);
                    EEG2 = pop_saveset(EEG2, 'filename',[out_name_noext '_' mark_cond_names{cond}], 'filepath', eeg_output_path);
                    clear EEG2
                end
            end
            
        case 'trial'
            EEG     = pop_epoch(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
            
            srate   = EEG.srate;
            pnt     = EEG.pnts;
            xmin    = EEG.xmin;  ... in seconds
                xmax    = EEG.xmax;
            
            baseline_point  = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
            baseline_point(1) = max(baseline_point(1), 1);
            
            
            mbs             = mean(EEG.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
            baseline        = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
            EEG.data        = EEG.data-baseline;
            
            for cond=1:length(mark_cond_code)
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2 = pop_epoch(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
                    ...EEG2 = pop_rmbase(EEG2, [baseline_corr_start baseline_corr_end]);
                        
                EEG2 = eeg_checkset(EEG2);
                EEG2 = pop_saveset(EEG2, 'filename',[out_name_noext '_' mark_cond_names{cond}], 'filepath', eeg_output_path);
                clear EEG2
                end
            end
            
    end
end
end

% CHANGE LOG
% 25/9/2014
% commented code block C1, repeated for cycle

% 18/6/2014
% added different epoching methodd besided the global one: by condition & by trial
% permanently removed this lines after condition epoching:
%         % keep only selected events
%         seleve=[];eve_cond=mark_cond_code{cond}; tot_eve_cond=length(eve_cond);
%         for n_eve_type=1:tot_eve_cond; seleve(n_eve_type,:)=strcmp({EEG2.event.type},eve_cond(n_eve_type));end
%         seleve_vec=find(sum(seleve,1)); EEG2.event=EEG2.event(seleve_vec);



