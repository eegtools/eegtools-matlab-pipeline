%% function EEG = proj_eeglab_subject_get_filename(project, subj_name, analysis_step,varargin)
%
%%

% project.paths.original_data: path of the original data in vhdr, bdf, ...
% format

% with a filename called : moving_scrambled_0001_ocica250.vhdr/bdf...

%  project.import.original_data_prefix       : moving_scrambled_
%  subj_name                                 : 0001
%  project.import.original_data_suffix       : _ocica250
%  project.import.original_data_extension    : vhdr/bdf
%  pre_epoching_input_file_name              : '_raw_er2';   ... a mandatory parameter file name suffix used for non-standard operations (second ica, patch triggers, etc...)
%  it's first _raw and then do ica. then open by hand _raw, clean segments, save as _raw_er, then do another ica, and save again as raw_er (overwrite). then reopen the ra_er and remove components and save as raw_mc.  
%  project.import.output_suffix              : _raw (outpt of the inport phase)
%  project.epoching.input_suffix             : _mc (input of the epoching)
%  

function file_name = proj_eeglab_subject_get_filename(project, subj_name,analysis_step,varargin)

pre_epoching_input_file_name = '';

options_num=size(varargin,2);
for opt=1:2:options_num    
    switch varargin{opt}
        case 'pre_epoching_input_file_name'
            pre_epoching_input_file_name = varargin{opt+1};
        case 'cond_name' 
            cond_name = varargin{opt+1};
    end
end



switch analysis_step
    
    case 'import_data'
        file_name = fullfile(project.paths.original_data, [project.import.original_data_prefix subj_name project.import.original_data_suffix '.' project.import.original_data_extension]);
    case 'preprocessing'
        file_name = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix '.set']);
    case 'testart'
        file_name =fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix pre_epoching_input_file_name '.set']);
    case 'ica'
        file_name = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix pre_epoching_input_file_name '.set']);
   
    % when artifact removal and other transient are done, the file assumes
    % a FIXED suffix project.import.output_suffix (e.g. _raw), therefore
    % the last version of the transiently modified file MUST be saved with
    % the structure project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix  '.set']
    
    case 'uniform_montage'
        file_name = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix  project.epoching.input_suffix '.set']);
    case 'epoching'
        file_name  = fullfile(eeg_input_path,  [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix input_file_suffix project.epoching.input_suffix '.set']);
    case 'add_factor'
        file_name = fullfile(eeg_input_path, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' cond_name '.set']);
    case 'extract_narrowband'
        file_name = fullfile(eeg_input_path, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' cond_name '.set']);   
        
end



