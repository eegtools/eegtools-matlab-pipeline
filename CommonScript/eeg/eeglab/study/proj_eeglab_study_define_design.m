%% [STUDY, EEG] = proj_eeglab_study_define_design(project, varargin)
%
% create a set of EEGLAB STUDY designs.
%
% ====================================================================================================
% REQUIRED INPUT:
%
% ----------------------------------------------------------------------------------------------------
% project; a structure with the following MANDATORY fields:
% 
% * project.study.filename; the filename of the study
% * project.paths.output_epochs; the path where the study file will be
%   placed (default: the same folder of the epoched datasets)
% * project.design; the experimental design:
%   project.design(design_number) = struct(
%                                         'name', design_name, 
%                                         'factor1_name',  factor1_name,  
%                                         'factor1_levels', factor1_levels , 
%                                         'factor1_pairing', 'on', 
%                                         'factor2_name',  factor2_name,  
%                                         'factor2_levels', factor2_levels , 
%                                         'factor2_pairing', 'on'
%                                         )
% ====================================================================================================
% OPTIONAL INPUT:
%
% ----------------------------------------------------------------------------------------------------
% design_list
%
%
% ====================================================================================================
function [STUDY, EEG] = proj_eeglab_study_define_design(project, varargin)

    if nargin < 1
        help proj_eeglab_study_define_design;
        return;
    end;
    
    design_list = project.design;
    
    for par=1:2:length(varargin)
       switch varargin{par}
           case {'design_list'}
               assign(varargin{par}, varargin{par+1});
       end
    end    

    study_path  = fullfile(project.paths.output_epochs, project.study.filename);
    [study_folder,study_name_noext,study_ext] = fileparts(study_path);    
    
    %% start EEGLab
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    %% load the study and working with the study structure 
    [STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_folder);
    
    tot_des=length(design_list);
    for ndes=1:(tot_des)    
        if ~( isempty(design_list(ndes).factor1_name) && isempty(design_list(ndes).factor2_name) )
            STUDY = std_makedesign(STUDY, ALLEEG, ndes, 'variable1',design_list(ndes).factor1_name,...
                                                        'values1',design_list(ndes).factor1_levels,... 
                                                        'pairing1',design_list(ndes).factor1_pairing,...
                                                        'variable2',design_list(ndes).factor2_name,...
                                                        'values2',design_list(ndes).factor2_levels,... 
                                                        'pairing2',design_list(ndes).factor2_pairing,...
                                                        'name',design_list(ndes).name,...
                                                        'delfiles','off','defaultdesign','off');   
        end
    end
    %% save study
    [STUDY EEG] = pop_savestudy( STUDY, ALLEEG, 'savemode','resave');
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    