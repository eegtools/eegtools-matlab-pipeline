%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_segmenting(project, varargin)



list_select_subjects    = project.subjects.list;
get_filename_step       = 'output_preprocessing';
custom_suffix           = '';
custom_input_folder     = '';




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
vsel_sub = find(ismember(project.subjects.list,list_select_subjects));

% -------------------------------------------------------------------------------------------------------------------------------------
input_segmenting.baseline_begin = project.segmenting.baseline_begin;
input_segmenting.baseline_end = project.segmenting.baseline_end;
input_segmenting.list_begin = project.segmenting.list_begin;
input_segmenting.list_end = project.segmenting.list_end;
input_segmenting.list_label = project.segmenting.list_label;
input_segmenting.output_folder = project.paths.output_segments;
input_segmenting.baseline_lab = project.segmenting.baseline_lab;

for subj=1:numsubj
    sel_sub = vsel_sub(subj);
    subj_name   = list_select_subjects{subj};
    inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    
    EEG         = eeglab_subject_segmenting(inputfile, input_segmenting);
    
    
end

%     summary = [names; ranks; ica_types; durations]';
%     disp(summary);
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name
