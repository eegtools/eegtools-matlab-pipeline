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

if not(isfield(project.study.precompute,'do_ersp_onlypost'))
    project.study.precompute.do_ersp_onlypost = 'off';
end


do_ersp_onlypost = project.study.precompute.do_ersp_onlypost;

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

list_ch = {STUDY.changrp.name};
tch = length(list_ch);

for ndes=1:length(design_num_vec)
    design_num=design_num_vec(ndes);
    
    
    
    %% select the study design for the analyses
    STUDY = std_selectdesign(STUDY, ALLEEG, design_num);
    
    design_name                           = char(STUDY.design(design_num).name);
    design_name2                          = ['design',num2str(design_num)];
    list_design_subjects               = eeglab_generate_subjects_list_by_factor_levels(project,STUDY, design_num);
    name_f1                            = STUDY.design(design_num).variable(1).label;
    name_f2                            = STUDY.design(design_num).variable(2).label;
    
    levels_f1                          = STUDY.design(design_num).variable(1).value;
    levels_f2                          = STUDY.design(design_num).variable(2).value;

    
%     if exist('parpool')
%         parpool(4);
%     end
    eeglab_version = eeg_getversion;
                
    if not(strcmp(eeglab_version,'development head'))
        list_cell_design={STUDY.design(design_num).cell.filebase};

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
            %         for ncell=vec_sel_cell
            %             erp_param=[erp 'cell' ncell];
            %             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, erp_param{:});
            %         end
            [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, erp{:});
        end
        if strcmp(do_erpim, 'on')
            %         for ncell=vec_sel_cell
            %             erpim_param=[erpim 'cell' ncell];
            %             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, erpim_param{:});
            %         end
            [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, erpim{:});
        end
        if strcmp(do_spec, 'on')
            %         for ncell=vec_sel_cell
            %             spec_param=[spec 'cell' ncell];
            %             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, spec_param{:});
            %         end
            [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, spec{:});
        end
        if strcmp(do_ersp, 'on')
            %         for ncell=vec_sel_cell
            %             ersp_param=[ersp 'cell' ncell];
            %             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, ersp_param{:});
            %         end
            [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, ersp{:});
        end
        
         if strcmp(do_ersp_onlypost, 'on')
            %         for ncell=vec_sel_cell
            %             ersp_param=[ersp 'cell' ncell];
            %             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, ersp_param{:});
            %         end
            
%             % analisi frequenza baseline
%             spec{8} = [spec{8},'timerange',[project.epoching.bc_st.ms, project.epoching.bc_end.ms]];             
%             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, spec{:});
%             [STUDY, specdataAS, allfreqsAS] = std_readspec(STUDY, ALLEEG,'design',1,'channels',{STUDY.changrp.name});
%             
            ersp_base  = ersp;
            ersp_post  = ersp;
            
            % analisi tempo frequenza baseline
            % setto i limiti temporali alla baseline
            ersp_base{8} = [ersp_base{8},'timelimits',[project.epoching.bc_st.ms, project.epoching.bc_end.ms],'baseline',NaN]; 
            % setto i timesout alla baseline
            ersp_base{8}{6} = ersp_base{8}{6}(ersp_base{8}{6}<= project.epoching.bc_end.ms);            
            [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, ersp_base{:});
            [STUDY, erspdata_base, times_base, freqs_base, erspbase_base] = std_readersp(STUDY, ALLEEG,'design',ndes,'channels',{STUDY.changrp.name});
            
            
             % analisi tempo frequenza post stimolo
            % setto i limiti temporali alpost stimolo
            ersp_post{8} = [ersp_post{8},'timelimits',[project.epoching.bc_end.ms, project.epoching.epo_end.ms],'baseline',NaN]; 
            % setto i timesout alpost stimolo
            ersp_post{8}{6} = ersp_post{8}{6}(ersp_post{8}{6}>= project.epoching.bc_end.ms);            
            [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, ersp_post{:});
            [STUDY, erspdata_post, times_post, freqs_post, erspbase_post] = std_readersp(STUDY, ALLEEG,'design',ndes,'channels',{STUDY.changrp.name});
            
            [tr,tc] = size(erspdata_post); % livelli f1 x livelli f2
            % ciascuna cella: frequenze x tempi x canali x soggetti
            
            for nr = 1:tr
                lf1 = levels_f1{nr};
                for nc = 1:tc
                    lf2 = levels_f2{nc};
                    erspdata_post_bc{nr,nc} = erspdata_post{nr,nc} - ...
                        repmat((mean(erspdata_base{nr,nc},2)),1,length(times_post),1,1);
                    [frequenze,tempi,canali,soggetti] = size(erspdata_post_bc);
                    
                    list_sub_cell = list_design_subjects{nr,nc};
                    tsc = length(list_sub_cell);
                    for nsc = 1:tsc
                        cs = list_sub_cell{nsc};
                        fname_cs = [design_name2,'_',cs, '_',lf1,'_',lf2,'.datersp'];
                        fpath_cs = fullfile(study_folder,[fname_cs]);
                        matObj = matfile(fpath_cs);
                        %                         whos(matObj)
                        matObj.Properties.Writable=true;
                        for nch = 1:tch
                            pippo = erspdata_post_bc{nr,nc}(:,:,nch,nsc);
                            nchstr = num2str(nch);
                            str = ['matObj.chan',nchstr,'_ersp = pippo;'];
                            eval(str);
                        end
                        matObj.times = times_post;
                        
                    end
                end
            end
            
            fname_out = fullfile(study_folder,[STUDY.design(ndes).name,'.mat']);
            disp(fname_out);
            save(fname_out, 'erspdata_post_bc',...
                'erspdata_base', 'times_base', 'freqs_base', 'erspbase_base',...
                'erspdata_post', 'times_post', 'freqs_post', 'erspbase_post'...
                );
            
%             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, ersp{:});
            
         end
        
        eeglab redraw
        ...delete(gcp);
            %         [STUDY EEG] = pop_savestudy( STUDY, ALLEEG, 'savemode','resave');
    else
        
        if strcmp(do_erp, 'on')
            %         for ncell=vec_sel_cell
            %             erp_param=[erp 'cell' ncell];
            %             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, erp_param{:});
            %         end
            [STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, {}, erp{:});
        end
        if strcmp(do_erpim, 'on')
            %         for ncell=vec_sel_cell
            %             erpim_param=[erpim 'cell' ncell];
            %             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, erpim_param{:});
            %         end
            [STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, {}, erpim{:});
        end
        if strcmp(do_spec, 'on')
            %         for ncell=vec_sel_cell
            %             spec_param=[spec 'cell' ncell];
            %             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, spec_param{:});
            %         end
            [STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, {}, spec{:});
        end
        if strcmp(do_ersp, 'on')
            %         for ncell=vec_sel_cell
            %             ersp_param=[ersp 'cell' ncell];
            %             [STUDY ALLEEG] = std_precomp2(STUDY, ALLEEG, {}, ersp_param{:});
            %         end
            [STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, {}, ersp{:});
        end
        eeglab redraw
        
    end
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

