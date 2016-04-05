%% function EEG = eeglab_subject_import_data(project, subj_name)
%
% function to import data into eeglab from different file format
% - remove blanks from brainvision triggers code
% - transform all triggers type to string
% - import channel locations
% - apply specific filtering for eeg,eog and emg channels
%
% INPUTS:
% project structure containing all the project info
% subjects name
%%
function EEG = proj_eeglab_subject_import_data(project, varargin)


    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'input_import_data';
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

        subj_name               = list_select_subjects{subj};
        input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
        [path,name_noext,ext]   = fileparts(input_file_name);

        eeglab_channels_file    = project.eegdata.eeglab_channels_file_path;
        % --------------------------------------------------------------------------------------------------------------------------------------------

        switch project.import.acquisition_system

            case 'BRAINAMP'
                % load vhdr data
                EEG = pop_loadbv(path, [name_noext,ext]); ..., [], 1:nch_eeg);
                    % EVENT SELECTING
                % convert events type to string & remove blanks from events' labels
                for ev=1:size(EEG.event,2)
                    EEG.event(ev).type = regexprep(EEG.event(ev).type,' ','');
                end

            case 'BIOSEMI'
                EEG = pop_biosig(input_file_name, 'importannot','off');
                % EVENT SELECTING
                % convert events type to string & remove blanks from events' labels
                for ev=1:size(EEG.event,2)
                    EEG.event(ev).type = num2str(EEG.event(ev).type);
                end
            case 'GEODESIC'
                EEG = pop_readegi(input_file_name, [],[],'auto');
                EEG = eeg_checkset( EEG );


            otherwise
                error(['unrecognized device (' project.import.acquisition_system ')']);
        end

         %if(not(strcmp(project.import.acquisition_system,'GEODESIC')))
%             EEG = pop_chanedit( EEG, 'lookup',eeglab_channels_file);    ...  considering using a same file, suitable for whichever electrodes configuration
%                 EEG = eeg_checkset( EEG );
         %end

         EEG = pop_readegi(input_file_name, [],[],'auto');
                EEG = eeg_checkset( EEG );


                % split file path in folder, name, extension
                [folder_loc,name_loc,ext_loc] = fileparts(eeglab_channels_file);
                
                % if the folder of the loc file is not that expected by eeglab
                if not(strcmp(folder_loc,project.paths.eeglab))
                    % copy the file into the expected folder
                    %copyfile(project.paths.eeglab,fullfile(project.paths.eeglab,'sample_locs'));
                    copyfile(eeglab_channels_file,fullfile(project.paths.eeglab,'sample_locs'));
                end
                
                % read the file using the copied file for the locations
                EEG = pop_readegi(input_file_name, [],[],[name_loc,ext_loc]);
                
                % if there is no Cz (Cz considered as non-EEG ref channel
                % therefore in the non data channels (but we want to
                % consider it using interpolation)
                if not(sum(ismember({EEG.chanlocs.labels},'Cz')));
%                   
                   nch_cz = EEG.nbchan + 1;
%                     
%                     % create a fake Cz
                   EEG.data (nch_cz,:) = EEG.data (EEG.nbchan,:);
%                     
%                     % replicate the last channel label
                    EEG.chanlocs(nch_cz) = EEG.chanlocs(EEG.nbchan);
%                     
%                     % update channel number
                EEG.nbchan = nch_cz;
%                     
                    EEG.chanlocs(nch_cz).labels = 'Cz';
% 
                     sel_cz = find(ismember({EEG.chanlocs.labels}, 'Cz'));
% 
%                     % remove the nodatchans (not eeg with the ref-Cz that we
%                     % want to replace with a EEG Cz (obtained by interpolation) that we can evaluate 
                     EEG.chaninfo = rmfield(EEG.chaninfo,'nodatchans');
%                     
%                     % update channel locations (now should work because
%                     % there is no more duplicity between ref-Cz and EEG-Cz
                     EEG=pop_chanedit(EEG, 'load',{eeglab_channels_file 'filetype' 'autodetect'});
%                     
%                     % now that the locations are correct we can interpolate
                     EEG = pop_interp(EEG, sel_cz,'spherical');
%                     
%                     % check global consistency
                    EEG = eeg_checkset( EEG );
               end
%          
         
         
         
         
         
         
        % global filtering

        EEG = proj_eeglab_subject_filter(EEG, project, 'global', 'bandstop');
        EEG = eeg_checkset( EEG );

        EEG = proj_eeglab_subject_filter(EEG, project, 'global', 'bandpass');
        EEG = eeg_checkset( EEG );
        %===============================================================================================
        % CHECK & SAVE
        %===============================================================================================
        EEG                     = eeg_checkset( EEG );
        output_file_name        = proj_eeglab_subject_get_filename(project, subj_name, 'output_import_data');
        [path,name_noext,ext]   = fileparts(output_file_name);
        EEG                     = pop_saveset( EEG, 'filename', name_noext, 'filepath', path);
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

% 11/12/2014
% added 'otherwise' case in switch statement, variable cleaning

% 1/10/2014
% modified filtering section
% blank removed from events' labels

% 30/1/2014
% first version of the new project structure