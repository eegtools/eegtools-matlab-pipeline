%% function output = proj_eeglab_subject_extract_narrowband(project, analysis_name, varargin)
% funzione che cicla sui soggetti: dalla struttura project si prendono le
% informazioni sulla banda del tipo
% project.postprocess.ersp.frequency_bands(1)         = struct('name','teta','min',4,'max',8,'dfmin',1,'dfmax',1,'ref_roi_list',{'Cpz'}, 'ref_roi_name','Cpz','ref_cond', 'ao', 'ref_tw_list', [0 100], 'ref_tw_name', 'gigi', 'realign_method','auc');
% quindi fissata la banda si sanno la roi, la time window e la condizione
% di riferimento per il calolo della nb.
% per ogni soggetto viene calcolata la nb in ogni banda. le nb vengono
% riorganizzate in forma struttura e salvate come .mat e come testo per la
% statistica

function output = proj_eeglab_group_extract_narrowband(project, analysis_name, design_num,varargin)

output = [];

% defaults
frequency_bands_list        = project.postprocess.ersp.frequency_bands_list;
ersp_measure                = project.stats.ersp.measure;
list_select_subjects        = project.subjects.curr_list;
get_filename_step           = 'extract_narrowband';
custom_suffix               = '';
custom_input_folder         = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects'  , ...
                'get_filename_step'     , ...
                'custom_input_folder'   , ...
                'custom_suffix'         , ...
                'frequency_bands_list'  , ...
                'ersp_measure'            ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
numsubj = length(list_select_subjects);
% -------------------------------------------------------------------------------------------------------------------------------------

results_path                       = project.paths.results;
str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
narrow_band_dir                    = fullfile(results_path, analysis_name,['narrow_band-',str]);
mkdir(narrow_band_dir);

study_path                  = fullfile(project.paths.output_epochs, project.study.filename);
[study_path,study_name_noext,study_ext] = fileparts(study_path);

[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);

fname_out = fullfile(STUDY.filepath,[STUDY.design(design_num).name,'.mat']);
load(fname_out,'erspdata_post_bc','times_post', 'freqs_post');
allch = [STUDY.changrp.channels];
ersp_allch = erspdata_post_bc;
times   = times_post;
freqs   = freqs_post;
clear erspdata_post_bc  times_post freqs_post;



tband = length(frequency_bands_list);


try
    for nband = 1:tband
        
        
        
        
        
        % input of the low level extract narrow band spectral parameters are the same as for the precomputed, given by the project structure
        %             input_nb.cycles                         = project.study.ersp.cycles;
        %             input_nb.freqs                          = project.study.ersp.freqout_analysis_interval;
        %             input_nb.timesout                       = project.study.ersp.timeout_analysis_interval.s*1000;
        %             input_nb.padratio                       = project.study.ersp.padratio;
        %             input_nb.baseline                       = [project.epoching.bc_st.ms project.epoching.bc_end.ms];
        %             input_nb.epoch                          = [project.epoching.epo_st.ms  project.epoching.epo_end.ms];
        %             input_nb.ersp_measure                   = project.stats.ersp.measure;
        
        for nsub=1:numsubj
            sub_name                            = list_select_subjects{nsub};
            %                 input_nb.input_file_name            = proj_eeglab_subject_get_filename(project, sub_name, get_filename_step, 'cond_name', input_nb.ref_cond, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
            input_nb                    = project.postprocess.ersp.frequency_bands(nband);
            input_nb.project            = project;
            input_nb.allch               = allch;
            input_nb.times               = times;
            input_nb.freqs               = freqs;
            [trr, tcc] = size(ersp_allch);

            ersp_allch_sub = zeros(length(freqs),length(times));              
            for nrr = 1:trr
                for ncc = 1:tcc                    
                    ersp_allch_sub = ersp_allch_sub + squeeze(ersp_allch{nrr,ncc}(:,:,:,nsub));                    
                end
            end
            
            input_nb.ersp_allch_sub = ersp_allch_sub/(trr*tcc);
            
            
            
%             if exist(input_nb.input_file_name, 'file')
                %% output of the low level extract narrow band
                nb_results = eeglab_group_extract_narrowband(input_nb);
                
                output.results.nb.band(nband).sub(nsub).fnb                 = nb_results.fnb;
                output.results.nb.band(nband).sub(nsub).centroid_mean       = nb_results.centroid_mean;
                output.results.nb.band(nband).sub(nsub).fcog_all            = nb_results.fcog.all;
                output.results.nb.band(nband).sub(nsub).fcog_pos            = nb_results.fcog.pos;
                output.results.nb.band(nband).sub(nsub).fcog_neg            = nb_results.fcog.neg;
                output.results.nb.band(nband).sub(nsub).fcog_polarity_index = nb_results.fcog.polarity_index;
                
                output.results.nb.band(nband).sub(nsub).sub_name    = sub_name;
%             else
%                 disp('Error: missing file!!!!')
%                 return
%             end
        end
    end
    
    %% outuput
    output.project                                                  = project;
    
    %% output matlab file with the narrowband structure
    
    save(fullfile(narrow_band_dir,'narrow_band.mat'),'output');
    
    %% tabular text file output for inspection/statistics
    [dataexpcols, dataexp] = text_export_nb_struct(fullfile(narrow_band_dir,'narrow_band.txt'),output);
    
catch err
    err;
end
end
% CHANGE LOG
% 19/6/15
% added export of fcog


