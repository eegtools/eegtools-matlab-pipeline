%% [STUDY, EEG] = proj_eeglab_study_compute_channels_measures(project, varargin)
%  calculate channel measures for a given set of experimental designs of an EEGLAB STUDY.
%
% ====================================================================================================
% REQUIRED INPUT:
%
% ----------------------------------------------------------------------------------------------------
% project; a structure with the following MANDATORY fields:
%
% * project.study.filename; the filename of the study
% * project.study.precompute.erp;
% * project.study.precompute.ersp;
% * project.study.precompute.spec;
% * project.study.precompute.erpim;
% * project.design; the experimental design:
%   project.design(design_number)=struct(
%                                        'name', design_name,
%                                        'factor1_name',  factor1_name,
%                                        'factor1_levels', factor1_levels ,
%                                        'factor1_pairing', 'on',
%                                        'factor2_name',  factor2_name,
%                                        'factor2_levels', factor2_levels ,
%                                        'factor2_pairing', 'on'
%                                         )
% ====================================================================================================


function [STUDY, EEG] = proj_eeglab_study_compute_channels_measures(project, varargin)

if nargin < 1
    help proj_eeglab_study_compute_channels_measures;
    return;
end;

% possibile passare da un recompute globale ad uno specifico di una misura
erp                     = project.study.precompute.erp;
ersp                    = project.study.precompute.ersp;
spec                    = project.study.precompute.spec;
erpim                   = project.study.precompute.erpim;

design_num_vec          = [1:length(project.design)];
list_select_subjects    = [];
do_erp                  = project.study.precompute.do_erp; 
do_erpim                = project.study.precompute.do_erpim; 
do_spec                 = project.study.precompute.do_spec; 
do_ersp                 = project.study.precompute.do_ersp;

for par=1:2:length(varargin)
    switch varargin{par}
        case {'design_num_vec', 'list_select_subjects'}
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
        case 'erpparams'
            override_param(varargin{par}, varargin{par+1}, erp);
        case 'erspparams'
            override_param(varargin{par}, varargin{par+1}, ersp);
        case 'erpimparams'
            override_param(varargin{par}, varargin{par+1}, erpim);
        case 'specparams'
            override_param(varargin{par}, varargin{par+1}, spec);
        case {'do_erp', 'do_ersp', 'do_erpim', 'do_spec'}
            assign(varargin{par}, varargin{par+1});
        case {'recompute', 'allcomps', 'interp', 'scalp', 'itc', 'savetrials', 'rmicacomps', 'cell', 'design', 'rmclust', 'rmbase' }
            erp      = override_param(varargin{par}, varargin{par+1}, erp);
            ersp     = override_param(varargin{par}, varargin{par+1}, ersp);
            spec     = override_param(varargin{par}, varargin{par+1}, spec);
            erpim    = override_param(varargin{par}, varargin{par+1}, erpim);
    end
end

if isempty(design_num_vec)
    design_num_vec  = [1:length(project.design)];
end
study_path  = fullfile(project.paths.output_epochs, project.study.filename);
[study_folder, study_name_noext, study_ext] = fileparts(study_path);

%% start EEGLab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

%% load the study and working with the study structure
[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_folder);

for ndes=1:length(design_num_vec)
    design_num=design_num_vec(ndes);
    
    %% select the study design for the analyses
    STUDY = std_selectdesign(STUDY, ALLEEG, design_num);
    list_cell_design={STUDY.design(design_num).cell.filebase};
    
    if exist('parpool')
        parpool(4);
    end
    
    vec_sel_cell = [];
    if not(isempty(list_select_subjects))
        for s=1:length(list_select_subjects)
            vv = strfind_index(list_cell_design, list_select_subjects{s});
            vec_sel_cell = [vec_sel_cell, vv];
        end
        vec_sel_cell = sort(vec_sel_cell);
    else
        vec_sel_cell=1:length(list_cell_design);
    end
    
    if strcmp(do_erp, 'on')
        for ncell=vec_sel_cell
            erp_param=[erp 'cell' ncell];
            [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, erp_param{:});
        end
    end
    if strcmp(do_erpim, 'on')
        for ncell=vec_sel_cell
            erpim_param=[erpim 'cell' ncell];
            [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, erpim_param{:});
        end
    end
    if strcmp(do_spec, 'on')
        for ncell=vec_sel_cell
            spec_param=[spec 'cell' ncell];
            [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, spec_param{:});
        end
    end
    if strcmp(do_ersp, 'on')
        for ncell=vec_sel_cell
            ersp_param=[ersp 'cell' ncell];
            [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, ersp_param{:});
        end
    end
    ...delete(gcp);
    [STUDY EEG] = pop_savestudy( STUDY, ALLEEG, 'savemode','resave');
    
end

    function array = override_param(param, value, array)
        for p=1:2:length(array)
            if strcmp(param, array{p})
                array{p+1} = value;
            end
        end
    end

end

