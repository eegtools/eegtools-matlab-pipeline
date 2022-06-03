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

function EEG = proj_eeglab_subject_align_montages(project, varargin)



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
% numsubj = length(project.subjects.list );
% -------------------------------------------------------------------------------------------------------------------------------------

subj_name                   = list_select_subjects{1};

input_file_name             = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix);
try
    EEG                     = pop_loadset(input_file_name);
catch
    [fpath,fname,fext] = fileparts(input_file_name);
    EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
end
target_montage = {EEG.chanlocs.labels};

indtarget = find(ismember(project.subjects.list,subj_name));
ind_select_subjects2align = setdiff(1:project.subjects.numsubj,indtarget);

for subj=ind_select_subjects2align
    
    subj_name                   = project.subjects.list{subj};
    
    input_file_name             = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    try
        EEG                     = pop_loadset(input_file_name);
    catch
        [fpath,fname,fext] = fileparts(input_file_name);
        EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
    end
    
    %     target_montage = new;
    %     montage2change = old;
    montage2change = {EEG.chanlocs.labels};
    
    
    chan_intersection = target_montage(ismember(target_montage,montage2change));
    
    [LIA,LOCB] = ismember(chan_intersection,montage2change);
    
    
    changed_montage = montage2change(LOCB);
    
    EEG.chanlocs = EEG.chanlocs(LOCB);
    EEG.data = EEG.data(LOCB,:);
    
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
end






end
