%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_iclabel(project, varargin)



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
        
        EEG                     = pop_loadset(inputfile);
        [fpath,fname,fext] = fileparts(inputfile);


        if project.iclabel.enable
            disp('Label components using iclabel')
            EEG = pop_iclabel(EEG, 'default');
        end
                
        if project.icflag.enable
            disp('Mark ICs for deletion using icflag')
            mat_thrsold = [...
                project.icflag.threshold.Brain;...
                project.icflag.threshold.Muscle;...
                project.icflag.threshold.Eye;...
                project.icflag.threshold.Heart;...
                project.icflag.threshold.LineNoise;...
                project.icflag.threshold.ChannelNoise;...
                project.icflag.threshold.Other...
                ];
            
            EEG = pop_icflag(EEG, mat_thrsold);
        end
        
        if project.icflag.autoremove
            ic2remove = find(EEG.reject.gcompreject);
            if isempty(ic2remove)
                disp('No bad ICs based on icflag classification')
            else
                disp('Remove ICs based on icflag classification')
                disp(['removing ic ' ,num2str(ic2remove) ,' from',  inputfile])
                EEG = pop_subcomp( EEG, ic2remove, 0);
            end
        end        
       
    else
        disp(['Not existing ', inputfile,' !!!!'])    
    end
    
    EEG = pop_saveset( EEG, 'filename',[fname, fext],'filepath',fpath);

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
