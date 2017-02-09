%% EEG = proj_eeglab_subject_reref(project, varargin)
%
function EEG = proj_eeglab_subject_reref(project, varargin)

    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'input_epoching';
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
    % -------------------------------------------------------------------------------------------------------------------------------------

    for subj=1:numsubj

        subj_name   = list_select_subjects{subj};
        inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
        [folder, name_noext, ext] = fileparts(inputfile );

        EEG         = pop_loadset(inputfile);        
        
        EEG = pop_saveset( EEG, 'filename',[name_noext,'_mcbck',ext],'filepath',EEG.filepath);


        reference   = [];
        if not(strcmp(project.import.reference_channels{1}, 'CAR'))

            tchanref        = length(project.import.reference_channels);
            channels_list   = {EEG.chanlocs.labels};
            tch = length(channels_list);
            channels_ind = 1:tch;
            
            for nchref=1:tchanref;
                ll                  = length(project.import.reference_channels{nchref});
                match_ref(nchref,:) = strncmp(channels_list, project.import.reference_channels(nchref), ll);
            end
            refvec      = find(sum(match_ref,1)>0);
            reference   = refvec;
        end

        exclude = find(channels_ind > project.eegdata.nch_eeg);
        
        EEG = pop_reref(EEG, [reference], 'keepref', 'on','exclude',[exclude]);


        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename', [name_noext,ext],'filepath',EEG.filepath);
        
       
        
       

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
