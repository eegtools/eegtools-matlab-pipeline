%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_export_data(project, varargin)

		export_dir = fullfile(project.paths.projects_data_root,...
            project.research_group,...
            project.research_subgroup,...
            project.name,'export_data');
        
        if not(exist(export_dir))
            mkdir(export_dir);
        end

    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'export_data';
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
    
    % -------------------------------------------------------------------------------------------------------------------------------------

%     names = {};
%     durations = {};
%     ranks = {};
%     ica_types ={};
    
switch project.export_data.format
    case 'EDF'
        export_ext = 'edf';
end

    for subj=1:numsubj
        
        subj_name   = list_select_subjects{subj}; 
        outputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'export_data', custom_suffix, 'custom_input_folder', custom_input_folder);
        
        [filepath,name_noext,ext] = fileparts(outputfile);
        
        export_file = fullfile(export_dir,[subj_name,'.',export_ext]);
        
        
                     
        try
            EEG                     = pop_loadset(outputfile);
        catch
            [fpath,fname,fext] = fileparts(outputfile);
            EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
        end
        
    EEG.event = [];
    EEG = eeg_checkset( EEG );
    disp(['exporting: ' outputfile])
    disp(['to: ' export_file])
        disp(' ')


    pop_writeeeg(EEG, export_file, 'TYPE',project.export_data.format);
   
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
% utilization of proj_eeglab_subject_get_name_noext function to define IO file name
