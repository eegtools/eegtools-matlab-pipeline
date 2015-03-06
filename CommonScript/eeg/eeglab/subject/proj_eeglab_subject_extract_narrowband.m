function results= proj_eeglab_subject_extract_narrowband(project, varargin)


%% VARARGIN DEFAULTS


roi_list                    = project.postprocess.ersp.roi_list;
roi_names                   = project.postprocess.ersp.roi_names;

frequency_bands_list        = project.postprocess.ersp.frequency_bands_list;
frequency_bands_names       = project.postprocess.ersp.frequency_bands_names;


group_time_windows_list     = arrange_structure(project.postprocess.ersp.design, 'group_time_windows');
subject_time_windows_list   = arrange_structure(project.postprocess.ersp.design, 'subject_time_windows');
group_time_windows_names    = arrange_structure(project.postprocess.ersp.design, 'group_time_windows_names');

ersp_measure                = project.stats.ersp.measure;

do_plots                    = project.results_display.ersp.do_plots;

num_tails                   = project.stats.ersp.num_tails;

do_narrowband               = project.stats.ersp.do_narrowband;

group_tmin                  = project.stats.ersp.narrowband.group_tmin;
group_tmax                  = project.stats.ersp.narrowband.group_tmax;
group_dfmin                 = project.stats.ersp.narrowband.dfmin;
group_dfmax                 = project.stats.ersp.narrowband.dfmax;
which_realign_measure_cell  = project.stats.ersp.narrowband.which_realign_measure;


list_select_subjects  = project.subjects.list;

%% initialize results
results =[];
results_path                       = project.paths.results;

str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
plot_dir                           = fullfile(results_path, ['narrow_band''-',str]);
mkdir(plot_dir);

%% get varargins
options_num=size(varargin,2);
for opt=1:2:options_num
    switch varargin{opt}
        case 'list_select_subjects'
            list_select_subjects=varargin{opt+1};
            %         case 'pre_epoching_input_file_name'
            %             pre_epoching_input_file_name = varargin{opt+1};
            %         case 'cond_name'
            %             cond_name = varargin{opt+1};  
        case 'which_realign_measure' ...[ [tmin tmax]; [tmin tmax]...] for each band or one for all bands if has dim 1 x 2 (then replicated)
                which_realign_measure = varargin{opt+1};
            
    end
end



numsubj = length(list_select_subjects);

for subj=1:numsubj
    subj_name = list_select_subjects{subj};
    % ----------------------------------------------------------------------------------------------------------------------------
    
    input_file_name = proj_eeglab_subject_get_filename(project, subj_name,'extract_narrowband','cond_name','_nb');
    
    %     input_file_name = proj_eeglab_subject_get_filename(project, subj_name,'extract_narrowband','cond_name',cond_name);
    
    if exist(input_file_name, 'file')
        
        %         nsub_proj = ismember(subj_name,project.subjects.list);
        
        input_narrowband.input_file_name              = input_file_name;
        input_narrowband.roi_list                      = roi_list;
        input_narrowband.cycles                       = project.study.ersp.cycles;
        input_narrowband.freqs                        = project.study.ersp.freqout_analysis_interval;
        input_narrowband.timesout                     = project.study.ersp.timeout_analysis_interval.s*1000;
        input_narrowband.padratio                     = project.study.ersp.padratio;
        input_narrowband.baseline                     = [project.epoching.bc_st.ms project.epoching.bc_end.ms];
        input_narrowband.epoch                        = [project.epoching.epo_st.ms  project.epoching.epo_end.ms];
        input_narrowband.which_realign_measure        = which_realign_measure;
        
        results(subj).nb                              = eeglab_subject_extract_narrowband(input_narrowband);
        results(subj).subjname                        = subj_name;
        
    end
    
    
end
end




% Ciao Claudio
% 
%  
% 
% Volevo definire un po meglio la questione della narrow band
% 
%  
% 
% Credo servirebbe cio:
% 
%  
% 
% una funzione
% 
%  
% 
% = eeglab_subject_get_narrowband (project, input_file, wide_bands, clusters, tws, criteria)
% 
%  
% 
% input_file:          File .set da cui estrarre la nb
% 
% wide_bands      cell array of arrays, bande in cui cercare la nb,  come la struttura   project.postprocess.ersp.frequency_bands_list = {[3 5]; [8 12]; [14 20]; [20 32]}  se wide_bands viene passato vuoto, usa infatti quella struttura
% 
% roi:         cell array of cell array…e.g   {{‘C3’, ‘C4’}; {‘FC3’, ‘FC4’}}… stessa forma di project.postprocess.ersp.roi_list...se clusters viene passato vuoto, usa infatti quella struttura.
% 
% Tws:                      cell array of arrays...eg {[-500 -12]; [100 1000]}
% 
% Criteria:               come avevi gia fatto, non ricordo com’era: pos_peak, neg_peak, max_area
% 
%  
% 
% Questa funzione ritorna un cell array multidimensionale.. ... io lo ordinerei cosi: bande, roi, tw
% 
% res = {
% 
% {... band1
% 
%                 {tw1; tw2;tw3};  ... roi 1
% 
%                 {tw1; tw2;tw3};  ... roi 2
% 
%                 {tw1; tw2;tw3};  ... roi 3
% 
% };
% 
% {... band2
% 
%                 {tw1; tw2;tw3};  ... roi 1
% 
%                 {tw1; tw2;tw3};  ... roi 2
% 
%                 {tw1; tw2;tw3};  ... roi 3
% 
% };
% 
% }
% 
 

 
