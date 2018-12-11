
function [output] = proj_eeglab_study_butterfly_plot_erp(project, analysis_name,varargin)

output =[];

study_path                      = fullfile(project.paths.output_epochs, project.study.filename);
results_path                    = project.paths.results;


%% VARARGIN DEFAULTS
list_select_subjects                = {};
design_num_vec                      = [1:length(project.design)];


roi_list                            = project.postprocess.erp.roi_list;
roi_names                           = project.postprocess.erp.roi_names;
ylim                                = project.results_display.ylim_plot;
display_single_subjects             = project.results_display.erp.single_subjects;


for par=1:2:length(varargin)
    switch varargin{par}
        case {'design_num_vec', ...
               'display_single_subjects',... 
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if nargin < 1
    help proj_eeglab_study_butterfly_plot_erp;
    return;
end;



erp_curve_roi_avg=[];
compcond=[];
compgroup=[];

[study_path,study_name_noext,study_ext] = fileparts(study_path);

% start EEGLab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

% load the study and working with the study structure
[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);


% channels locations
chanlocs = eeg_mergelocs(ALLEEG.chanlocs);

r1         = unique([roi_list{:}]);
r2         = {chanlocs.labels};

roi_list = [{r1};{r2}];
roi_names  = {'all_rois','all_chan'};


for design_num=design_num_vec
    
    for roi_num=1:length(roi_list)
        roi_ch = roi_list{roi_num};
        if length(roi_ch) >1
            roi_name=roi_names{roi_num};
            roi_mask=ismember({chanlocs.labels},roi_ch);
            str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
            plot_dir=fullfile(results_path,analysis_name,[STUDY.design(design_num).name,'-',roi_names{roi_num},'-erp_butterfly_plot','-',str]);
            mkdir(plot_dir);
            
            % select the study design for the analyses
            STUDY                           = std_selectdesign(STUDY, ALLEEG, design_num);
            
            erp_curve_stat.study_des      = STUDY.design(design_num);
            erp_curve_stat.study_des.num  = design_num;
            erp_curve_stat.chanlocs       = chanlocs;
            
            name_f1                         = STUDY.design(design_num).variable(1).label;
            name_f2                         = STUDY.design(design_num).variable(2).label;
            
            levels_f1                       = STUDY.design(design_num).variable(1).value;
            levels_f2                       = STUDY.design(design_num).variable(2).value;
            
            tlf1                            = length(levels_f1);
            tlf2                            = length(levels_f2);
            
            
            % lista dei soggetti che partecipano di quel design
            list_design_subjects            = eeglab_generate_subjects_list_by_factor_levels(project,STUDY, design_num);
            
            
            
            % calculate erp in the channels corresponding to the selected roi
            [STUDY erp_curve times]=std_erpplot_corr(STUDY,ALLEEG,'channels',roi_ch,'noplot','on');
            
            for nf1=1:length(levels_f1)
                for nf2=1:length(levels_f2)
                    if ~isempty(list_select_subjects)
                        vec_select_subjects=ismember(list_design_subjects{nf1,nf2},list_select_subjects);
                        if ~sum(vec_select_subjects)
                            dis('Error: the selected subjects are not represented in the selected design')
                            return;
                        end
                        erp_curve{nf1,nf2}=erp_curve{nf1,nf2}(:,:,vec_select_subjects);
                        list_design_subjects{nf1,nf2}=list_design_subjects{nf1,nf2}(vec_select_subjects);
                        
                    end
                end
            end
            
            for nf1=1:length(levels_f1)
                for nf2=1:length(levels_f2)
                    label = [levels_f1{nf1}, '_',levels_f2{nf2}];
                    fig_path = fullfile(plot_dir,label);
                    fig=figure( 'color', 'w', 'Visible', 'off');
                    hold on
                    erp_butterfly = mean(erp_curve{nf1,nf2},3);
                    timtopo(erp_butterfly',chanlocs(ismember(r2,r1)),'limits',[min(times) max(times)],'title',label);
                    % save matlab fig file
                    saveas(fig, fig_path);
                    close(fig)
                end
            end
            
            if strcmp(display_single_subjects,'on')
                for nf1=1:length(levels_f1)
                    for nf2=1:length(levels_f2)
                        label = [levels_f1{nf1}, '_',levels_f2{nf2}];
                        plot_dir_sub=fullfile(plot_dir,label);
                        mkdir(plot_dir_sub);
                        ls = list_design_subjects{nf1,nf2};
                        for ns=1:length(ls)
                            
                            fig_path_sub = fullfile(plot_dir_sub,list_design_subjects{nf1,nf2}{ns});
                            fig=figure( 'color', 'w', 'Visible', 'off');
                            hold on
                            erp_butterfly_sub = erp_curve{nf1,nf2}(:,:,ns);
                            timtopo(erp_butterfly_sub',chanlocs(ismember(r2,r1)),'limits',[min(times) max(times)],'title',[label,'_',ls{ns}]);
                            % save matlab fig file
                            saveas(fig, fig_path_sub);
                            close(fig)
                        end
                    end
                end
            end
            
        end
    end
end
end
