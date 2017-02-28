%% [STUDY, EEG] = proj_eeglab_study_create(project)
%
% create an EEGLAB STUDY from a list of datasets.
%
% ====================================================================================================
% REQUIRED INPUT:
%
% ----------------------------------------------------------------------------------------------------
% project; a structure with the following MANDATORY fields:
%
% * project.study.filename; the filename of the study
% * project.paths.output_epochs; the path where the study file will be
%   placed (default: the same foleder of the epoched datasets)
% * project.epoching.condition_names; the names (cell array of strings) of the experimental conditions
% * project.subjects.groups; the names (cell array of strings) of the subjetcs' groups
% * project.epoching.input_suffix; the suffix denoting the datasets after the dataset-level preprocessing pipeline
% * project.subjects.group_names; the names of the subjects in each group (2d {grp}{subj} cell array)
% ====================================================================================================



%% NOTA: salvare con suffisso _catsub INVECE di quelli con le condizioni

function [STUDY, EEG] = proj_eeglab_study_create_catsub(project)
if nargin < 1
    help proj_eeglab_study_create;
    return;
end;

study_name          = project.study.filename;
epochs_path         = project.paths.output_epochs;
condition_names     = project.epoching.condition_names;
group_list          = project.subjects.groups;
import_out_suffix   = project.import.output_suffix;
group_names         = project.subjects.group_names;

nset=1;
commands={};

study_path  = fullfile(epochs_path, study_name);
[study_folder, study_name_noext, study_ext] = fileparts(study_path);

% start EEGLab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

%% create the study with the epoched data of all subjects
% load each epochs set file (subject and condition) into the study structure
% of EEGLab
for grp=1:length(group_list)
    for subj=1:length(group_list{grp})
        
        clear ALLEEG2
        nn = 1;
        clear EEG
        
        for cond=1:length(condition_names)
            
            setname=[project.import.original_data_prefix group_list{grp}{subj} project.import.original_data_suffix import_out_suffix project.epoching.input_suffix '_'  condition_names{cond} '.set'];
            fullsetname=fullfile(epochs_path,setname,'');
            
            
            if exist(fullsetname,'file')
                
                EEG = pop_loadset(fullsetname);
                
                
                if EEG.trials>1 && not(isempty(EEG.epoch)) 
                    
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
                    EEG.urevent=[];
                    
                    ALLEEG2(nn) = EEG;
                    nn=nn+1;
                end
            end
        end
        
        if exist('ALLEEG2')
            setname2=[project.import.original_data_prefix group_list{grp}{subj} project.import.original_data_suffix import_out_suffix project.epoching.input_suffix '_catsub.set'];
            fullsetname2=fullfile(epochs_path,setname2,'');
            
            OUTEEG = pop_mergeset( ALLEEG2, 1:length(ALLEEG2), 1 );
            OUTEEG.icaact=[];
            
            OUTEEG = eeg_checkset(OUTEEG);
            OUTEEG = pop_saveset(OUTEEG, 'filename', setname2, 'filepath', epochs_path);
        else
            OUTEEG = [];
        end
    end
end

% start EEGLab

clear ALLEEG2
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

%% create the study with the epoched data of all subjects
% load each epochs set file (subject and condition) into the study structure
% of EEGLab
for grp=1:length(group_list)
    for subj=1:length(group_list{grp})
        %         for cond=1:length(condition_names)
        
        setname2=[project.import.original_data_prefix group_list{grp}{subj} project.import.original_data_suffix import_out_suffix project.epoching.input_suffix '_catsub.set'];
        fullsetname2=fullfile(epochs_path,setname2,'');
        
        if exist(fullsetname2,'file')
            
            cmd={'index' nset 'load' fullsetname2 'subject' group_list{grp}{subj} 'session' 1 'condition' 'all' 'group' group_names{grp}};
            commands=[commands, cmd];
            nset=nset+1;
        end
        %             end
    end
end

[STUDY, ALLEEG] = std_editset( STUDY, ALLEEG, 'name' ,study_name, 'commands',commands,'updatedat','on','savedat','on' );
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];

%% save study on file
[STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
[STUDY, EEG] = pop_savestudy( STUDY, EEG, 'filename',[study_name_noext '_catsub.study'],'filepath',study_folder);
end

