%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_rectify_ch(project, varargin)



list_select_subjects    = project.subjects.list;
get_filename_step       = 'custom_pre_epochs';
custom_suffix           = '';
custom_input_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'get_filename_step',    ...
                'custom_input_folder',  ...
                'custom_suffix' ...
                };
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end

numsubj = length(list_select_subjects);
vsel_sub = find(ismember(project.subjects.list,list_select_subjects));

% -------------------------------------------------------------------------------------------------------------------------------------

%     names = {};
%     durations = {};
%     ranks = {};
%     ica_types ={};

for subj=1:numsubj
    sel_sub = vsel_sub(subj);
    subj_name   = list_select_subjects{subj};
    inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    
    EEG = [];
     if(exist(inputfile))
        disp(inputfile); 
        
        EEG                     = pop_loadset(input_file_name);
        [fpath,fname,fext] = fileparts(input_file_name);
        
        all_ch = {EEG.chanlocs.labels};
        tch = length(all_ch);
        for nch = 1:length(project.rectify.ch_list)
            nch_r = tch + nc;
            current_ch = (project.rectify.ch_list{nch};
            sel_ch = ismember(all_ch,current_ch);
            ch_data = EEG.data(sel_ch,:);
            ch_chanlocs = EEG.chanlcs(sel_ch);
            ch_data_rect = abs(ch_data - mean(ch_data));
            EEG.data(nch_r,:) = ch_data_rect;
            EEG.chanlocs(nch_r) = ch_chanlocs;
            EEG.chanlocs(nch_r).labels =  [ch_chanlocs,'_','rectified'];   
        end
        
        
        EEG = pop_saveset( EEG, 'filename',[fname, fext],'filepath',fpath);

        
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
