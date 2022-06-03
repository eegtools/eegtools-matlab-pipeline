%% [STUDY, EEG] = proj_eeglab_study_export_allch_ersp_single_trial(project, analysis_name, mode, varargin)
%
% export ersp single trial

function [ersp_single_trial_dir] = proj_eeglab_study_export_allch_ersp_single_trial(project, varargin)

if nargin < 1
    help proj_eeglab_study_export_allch_ersp_single_trial;
    return;
end;


list_select_subjects    = project.subjects.list;
get_filename_step       = 'input_import_data';
custom_suffix           = '';
custom_input_folder     = '';
import_out_suffix   = project.import.output_suffix;


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



epochs_path         = project.paths.output_epochs;


ersp_single_trial_dir = fullfile(epochs_path,'ersp_single_trial');
if not(exist(ersp_single_trial_dir))
    mkdir(ersp_single_trial_dir);
end


for subj=1:numsubj
    
            data_out = [];

    subj_name               = list_select_subjects{subj};
    
    input_file_name = [...
        project.import.original_data_prefix,...
        subj_name,...
        project.import.original_data_suffix,...
        import_out_suffix project.epoching.input_suffix '.dattimef'];
    
    input_file_path=fullfile(epochs_path,input_file_name,'');
    
    disp(input_file_path);
    
    baseline_lim_ms = [project.epoching.bc_st.ms, project.epoching.bc_end.ms];
    
    
    
    ersp_struct = load(input_file_path, '-mat');
    event_fields = fieldnames(ersp_struct.trialinfo);
    
    
    tch = length(ersp_struct.labels);
    ttimes= length(ersp_struct.times);
    tfreqs = length(ersp_struct.freqs);
    ttrials = length(ersp_struct.trialinfo);
    
    data_out.freqsout = repmat(ersp_struct.freqs',ttimes*ttrials,1);
    
    timesout_mat = repmat(ersp_struct.times,tfreqs,1);
    timesout_vec = reshape(timesout_mat,ttimes*tfreqs,1);
    data_out.timesout = repmat(timesout_vec,ttrials,1);
    
    trialinfo_names = fieldnames(ersp_struct.trialinfo);
    ttin = length(trialinfo_names);
    
    for ntin = 1:ttin
        current_field = trialinfo_names{ntin};
        current_info = {ersp_struct.trialinfo.(current_field)};
        current_info_mat = repmat(current_info,tfreqs*ttimes,1);
        current_info_vec = reshape(current_info_mat,tfreqs*ttimes*ttrials,1);
        
        str_current_info = ['data_out.',current_field, '=','current_info_vec;'];
        eval(str_current_info);
        
    end
    
    for nch = 1:tch
        current_lab = ersp_struct.labels{nch};
        current_chan = ['chan',num2str(nch)];
%         disp(current_chan);
        str_command = ['current_data = ','ersp_struct.' current_chan,';'];
        eval(str_command);
        current_data_pow = current_data.*conj(current_data);
        sel_baseline = ersp_struct.times >= baseline_lim_ms(1) & ersp_struct.times <= baseline_lim_ms(2);
        current_data_pow_baseline = current_data_pow(:,sel_baseline,:);
        
        
        mean_current_data_pow_baseline = mean(current_data_pow_baseline,2);
        rep_current_data_pow_baseline = repmat(mean_current_data_pow_baseline,[1,ttimes,1]);
        
        
        mean_current_data_pow_epoch = mean(current_data_pow,2);
        rep_current_data_pow_epoch = repmat(mean_current_data_pow_epoch,[1,ttimes,1]);
        
        
        pow_corr_addictive = current_data_pow - rep_current_data_pow_baseline;
        
        pow_corr_divisive = current_data_pow ./ rep_current_data_pow_baseline;
        
        pow_corr_divisive_epoch = current_data_pow ./ rep_current_data_pow_epoch;
        
        
        
        pow_corr_divisive_epoch_baseline = pow_corr_divisive_epoch(:,sel_baseline,:);
        mean_pow_corr_divisive_epoch_baseline = mean(pow_corr_divisive_epoch_baseline,2);
        rep_pow_corr_divisive_epoch_baseline = repmat(mean_pow_corr_divisive_epoch_baseline,[1,ttimes,1]);        
        pow_corr_full = pow_corr_divisive_epoch ./ rep_pow_corr_divisive_epoch_baseline;
        
        data_out.pow_ncorr = reshape(current_data_pow,[tfreqs*ttimes*ttrials,1]);
        data_out.pow_corr_addictive = reshape(pow_corr_addictive,[tfreqs*ttimes*ttrials,1]);        
        data_out.pow_corr_divisive = reshape(pow_corr_divisive,[tfreqs*ttimes*ttrials,1]);        
        data_out.pow_corr_full = reshape(pow_corr_full,[tfreqs*ttimes*ttrials,1]);
        
        data_out_cell = struct2table(data_out);
        outpath_ersp = fullfile(ersp_single_trial_dir,[subj_name,'_',current_lab,'.txt']);
        writetable(data_out_cell,outpath_ersp,"Delimiter" ,"\t");
        disp(outpath_ersp);
        
    end
    
end
end