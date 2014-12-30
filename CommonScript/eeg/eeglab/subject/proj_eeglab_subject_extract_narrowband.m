function project = proj_eeglab_subject_extract_narrowband(project, varargin)

list_select_subjects  = project.subjects.list;


options_num=size(varargin,2);
for opt=1:2:options_num
    switch varargin{opt}
        case 'list_select_subjects'
            list_select_subjects=varargin{opt+1};
        case 'pre_epoching_input_file_name'
            pre_epoching_input_file_name = varargin{opt+1};
        case 'cond_name'
            cond_name = varargin{opt+1};
        case 'ref_roi' ...[ {tmin tmax}] for each band or one for all bands if has dim 1 x 2 (then replicated)
                ref_roi = varargin{opt+1};
        case 'ref_twin' ...[ [tmin tmax]; [tmin tmax]...] for each band or one for all bands if has dim 1 x 2 (then replicated)
                ref_twin = varargin{opt+1};
        case 'which_realign_measure' ...[ [tmin tmax]; [tmin tmax]...] for each band or one for all bands if has dim 1 x 2 (then replicated)
                which_realign_measure = varargin{opt+1};
            
    end
end


numsubj = length(list_select_subjects);

for subj=1:numsubj
    subj_name = list_select_subjects{subj};
    % ----------------------------------------------------------------------------------------------------------------------------
    
    input_file_name = proj_eeglab_subject_get_filename(project, subj_name,'extract_narrowband','cond_name',cond_name);
    
    if exist(input_file_name, 'file')        
        
        nsub_proj = ismember(subj_name,project.subjects.list);
        
        input_narrowband.input_file_name              = input_file_name;
        input_narrowband.ref_roi                      = ref_roi;        
        input_narrowband.cycles                       = project.study.ersp.cycles;        
        input_narrowband.freqs                        = project.study.ersp.freqout_analysis_interval;
        input_narrowband.timesout                     = project.study.ersp.timeout_analysis_interval.s*1000;        
        input_narrowband.padratio                     = project.study.ersp.padratio;        
        input_narrowband.baseline                     = [project.epoching.bc_st.ms project.epoching.bc_end.ms];
        input_narrowband.epoch                        = [project.epoching.epo_st.ms  project.epoching.epo_end.ms];
 

        
        
        
        project.subjects.data(nsub_proj).frequency_bands_list  = eeglab_subject_extract_narrowband(input_narrowband);
    end
    
    
end
end