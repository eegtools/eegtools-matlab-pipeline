function output= proj_eeglab_subject_extract_narrowband(project, varargin)


%% VARARGIN DEFAULTS


roi_list                    = project.postprocess.ersp.roi_list;

frequency_bands_list        = project.postprocess.ersp.frequency_bands_list;


group_time_windows_list     = arrange_structure(project.postprocess.ersp.design, 'group_time_windows');

ersp_measure                = project.stats.ersp.measure;

group_dfmin                 = project.stats.ersp.narrowband.dfmin;
group_dfmax                 = project.stats.ersp.narrowband.dfmax;
which_realign_measure       = project.stats.ersp.narrowband.which_realign_measure;


list_select_subjects  = project.subjects.list;

%% initialize results
results =[];
results_path                       = project.paths.results;

str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
plot_dir                           = fullfile(results_path, ['narrow_band''-',str]);
mkdir(plot_dir);

% prevedo la possibilità di passare il parametro powbase per usare
% per ogni soggetto un certo vettore di potenze (lunghezza = numero di
% frequenze) come potenza di base per calcolare l'ersp.
powbase_cell                       =[];


for par=1:2:length(varargin)
    switch varargin{par}
        case {'list_select_subjects',...
                'which_realign_measure', ...
                'roi_list', ...                
                'group_time_windows_list', ...                
                'powbase_cell',...
                'ersp_measure',...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

numsubj = length(list_select_subjects);

for subj=1:numsubj
    subj_name = list_select_subjects{subj};    
    input_file_name = proj_eeglab_subject_get_filename(project, subj_name,'extract_narrowband','cond_name','_nb');
    
    if exist(input_file_name, 'file')        
        %% input of the low level extract narrow band
        input_narrowband.input_file_name              = input_file_name;
        input_narrowband.roi_list                     = roi_list;
        input_narrowband.frequency_bands_list         = frequency_bands_list;
        input_narrowband.group_time_windows_list      = group_time_windows_list;
       
        input_narrowband.cycles                       = project.study.ersp.cycles;
        input_narrowband.freqs                        = project.study.ersp.freqout_analysis_interval;
        input_narrowband.timesout                     = project.study.ersp.timeout_analysis_interval.s*1000;
        input_narrowband.padratio                     = project.study.ersp.padratio;
        input_narrowband.baseline                     = [project.epoching.bc_st.ms project.epoching.bc_end.ms];
        input_narrowband.epoch                        = [project.epoching.epo_st.ms  project.epoching.epo_end.ms];
        input_narrowband.ersp_measure                 = ersp_measure;
        
        if isempty(powbase_cell)
            input_narrowband.powbase                  = powbase_cell;
        else
            input_narrowband.powbase                  = powbase_cell{subj};
        end
        
        input_narrowband.which_realign_measure        = which_realign_measure;
        input_narrowband.group_dfmin                  = group_dfmin;
        input_narrowband.group_dfmax                  = group_dfmax;
        
        %% output of the low level extract narrow band
        output.results(subj).nb                       = eeglab_subject_extract_narrowband(input_narrowband);        
        output.results(subj).subjname                 = subj_name;
        output.project                                = project;
        
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



