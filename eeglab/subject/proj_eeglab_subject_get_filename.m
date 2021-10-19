%% function EEG = proj_eeglab_subject_get_filename(project, subj_name, analysis_step,varargin)
%
% project.paths.original_data: path of the original data in vhdr, bdf, ...
% format
%
% with a filename called : moving_scrambled_0001_ocica250.vhdr/bdf...
%
%  project.import.original_data_prefix       : moving_scrambled_
%  subj_name                                 : 0001
%  project.import.original_data_suffix       : _ocica250
%  project.import.original_data_extension    : vhdr/bdf
%  pre_epoching_input_file_name              : '_raw_er2';   ... a mandatory parameter file name suffix used for non-standard operations (second ica, patch triggers, etc...)
%  it's first _raw and then do ica. then open by hand _raw, clean segments, save as _raw_er, then do another ica, and save again as raw_er (overwrite). then reopen the ra_er and remove components and save as raw_mc.
%  project.import.output_suffix              : _raw (outpt of the inport phase)
%  project.epoching.input_suffix             : _mc (input of the epoching)
%%
function file_name = proj_eeglab_subject_get_filename(project, subj_name, analysis_step, varargin)

custom_suffix           = '';
custom_input_folder     = '';
cond_name               = '';

options_num=size(varargin,2);
for opt=1:2:options_num
    switch varargin{opt}
        case 'custom_suffix'
            custom_suffix   = varargin{opt+1};
        case 'cond_name'
            cond_name       = varargin{opt+1};
            %                 if not(strcmp(analysis_step, 'output_epoching')) && not(strcmp(analysis_step, 'add_factor'))
            %                     error(['error in proj_eeglab_subject_get_filename with cond_name parameter specified, the analysis_step is not ''output_epoching'' or ''add_factor'', please correct the function call']);
            %                 end
        case 'custom_input_folder'
            custom_input_folder   = varargin{opt+1};
    end
end

switch analysis_step
    case 'input_import_data'
        file_name = fullfile(project.paths.original_data, ...
            [project.import.original_data_prefix subj_name project.import.original_data_suffix '.' project.import.original_data_extension]);
    case 'output_import_data'
        file_name = fullfile(project.paths.output_import, ...
            [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix custom_suffix '.set']);
    case 'output_preprocessing'
        file_name = fullfile(project.paths.output_preprocessing, ...
            [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix custom_suffix '.set']);
    case 'custom_pre_epochs'
        file_name = fullfile(project.paths.output_preprocessing, ...
            [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix custom_suffix '.set']);
    case {'uniform_montage', 'input_epoching','microstates_spontaneous'}
        file_name = fullfile(project.paths.input_epochs, ...
            [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix custom_suffix '.set']);
    case {'output_epoching', 'add_factor', 'extract_narrowband','microstates_ERPavg','darbeliai_export2ragu','ragu','subject_erp_curve','subject_erp_topo','subject_ersp_tf'}
        file_name = fullfile(project.paths.output_epochs, ...
            [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix custom_suffix '_' cond_name '.set']);
    case {'output_segmenting'}
        file_name = fullfile(project.paths.output_segments, ...
            [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix custom_suffix '_' cond_name '.set']);
     case {'export_data'}
         file_name = fullfile(project.paths.input_epochs, ...
            [project.import.original_data_prefix subj_name  project.export_data.suffix  '.set']);
    case {'custom_step'}
        if strcmp(custom_input_folder, '')
            error('proj_eeglab_subject_get_filename.... you selected a custom_step without specifying a custom input folder');
        end
        file_name = fullfile(custom_input_folder, ...
            [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix custom_suffix '.set']);
end
end



