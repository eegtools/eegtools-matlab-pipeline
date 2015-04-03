function output = proj_eeglab_subject_extract_narrowband(project, analysis_name, varargin)

% funzione che cicla sui soggetti: dalla struttura project si prendono le
% informazioni sulla banda del tipo
% project.postprocess.ersp.frequency_bands(1)         = struct('name','teta','min',4,'max',8,'dfmin',1,'dfmax',1,'ref_roi_list',{'Cpz'}, 'ref_roi_name','Cpz','ref_cond', 'ao', 'ref_tw_list', [0 100], 'ref_tw_name', 'gigi', 'realign_method','auc');
% quindi fissata la banda si sanno la roi, la time window e la condizione
% di riferimento per il calolo della nb.
% per ogni soggetto viene calcolata la nb in ogni banda. le nb vengono
% riorganizzate in forma struttura e salvate come .mat e come testo per la
% statistica

%% VARARGIN DEFAULTS

frequency_bands_list        = project.postprocess.ersp.frequency_bands_list;
ersp_measure                = project.stats.ersp.measure;
list_select_subjects        = project.subjects.list;
custom_suffix               = [];

%% initialize results

results_path                       = project.paths.results;

str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
narrow_band_dir                    = fullfile(results_path, analysis_name,['narrow_band-',str]);
mkdir(narrow_band_dir);

for par=1:2:length(varargin)
    switch varargin{par}
        case {'list_select_subjects',...
                'frequency_bands_list',...
                'ersp_measure',...
                'custom_suffix'...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

tsub  = length(list_select_subjects);
tband = length(frequency_bands_list);


for nband = 1:tband
    input_nb               = project.postprocess.ersp.frequency_bands(nband);
    % input of the low level extract narrow band
    % spectral parameters are the same as for the precompue, given
    % by the project structure
    input_nb.cycles                       = project.study.ersp.cycles;
    input_nb.freqs                        = project.study.ersp.freqout_analysis_interval;
    input_nb.timesout                     = project.study.ersp.timeout_analysis_interval.s*1000;
    input_nb.padratio                     = project.study.ersp.padratio;
    input_nb.baseline                     = [project.epoching.bc_st.ms project.epoching.bc_end.ms];
    input_nb.epoch                        = [project.epoching.epo_st.ms  project.epoching.epo_end.ms];
    input_nb.ersp_measure                 = ersp_measure;
    input_nb.project                      = project;
    
    
    
    for nsub=1:tsub
        sub_name = list_select_subjects{nsub};
        input_nb.input_file_name = proj_eeglab_subject_get_filename(project, sub_name,'extract_narrowband','cond_name',input_nb.ref_cond,  'custom_suffix', custom_suffix);
        
        if exist(input_nb.input_file_name, 'file')
            %% output of the low level extract narrow band
            output.results.nb.band(nband).sub(nsub).fnb         = eeglab_subject_extract_narrowband(input_nb);
            output.results.nb.band(nband).sub(nsub).sub_name    = sub_name;
        else
            disp('Error: missing file!!!!')
            return
        end
    end
end

%% outuput
output.project                                                  = project;

%% output matlab file with the narrowband structure

save(fullfile(narrow_band_dir,'narrow_band.mat'),'output');

%% tabular text file output for inspection/statistics
[dataexpcols, dataexp] = text_export_nb_struct(fullfile(narrow_band_dir,'narrow_band.txt'),output);


end



