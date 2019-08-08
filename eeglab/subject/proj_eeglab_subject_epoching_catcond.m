%% EEG = proj_eeglab_subject_epoching_catcond(project, varargin)
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

function EEG = proj_eeglab_subject_epoching_catcond(project, varargin)

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
    
    [~, name_noext, ext] = fileparts(input_file_name);

    
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
    
    
    
    EEG2 = pop_epoch_bc(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
    EEG2 = eeg_checkset(EEG);
    
    disp(EEG2.filename)
    EEG2 = pop_saveset( EEG2, 'filename',[name_noext,ext],'filepath',EEG2.filepath);
    EEG = pop_saveset( EEG, 'filename',[name_noext,'_catcondbck',ext],'filepath',EEG.filepath);
    
    
    output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
    [path, out]         = fileparts(output_file_name);
    EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
    clear EEG2
end
end



% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
