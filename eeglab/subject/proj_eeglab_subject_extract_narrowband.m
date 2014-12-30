function EEG = proj_eeglab_subject_extract_narrowband(project, varargin)

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
        case 'ref_twin' ...[ [tmin tmax]; [tmin tmax]...] for each band or one for all bands if has dim 1 x 2 (then replicated)
               
            cond_name = varargin{opt+1};
    end
end


numsubj = length(list_select_subjects);

for subj=1:numsubj
    subj_name = list_select_subjects{subj};
    
    eeg_input_path  = project.paths.output_epochs;
    
    % ----------------------------------------------------------------------------------------------------------------------------
    
    input_file_name = proj_eeglab_subject_get_filename(project, subj_name,'extract_narrowband','pre_epoching_input_file_name',pre_epoching_input_file_name,'cond_name',cond_name);
    [input_path,input_name_noext,input_ext] = fileparts(input_file_name);
    
    if exist(input_file_name, 'file')
        
        EEG = pop_loadset(input_file_name);
        
        num_chan_vec=[13];
        
        for nch = 1:length(num_chan_vec)
            
            topovec=num_chan_vec(nch);
            ch_lab=EEG.chanlocs(topovec).labels;
            
            [ersp,itc,powbase,times,freqs,erspboot,itcboot] = ...
                pop_newtimef( EEG ... the EEG data structure
                , 1 ... select channels
                , 13 ...
                , [-2400  2996]...
                , [0] ... fourier
                , 'topovec', topovec ... number of the plotted channel
                , 'elocs', EEG.chanlocs ... topog. loactions of the channels
                ,'chaninfo', EEG.chaninfo... labels channels
                ,'caption', ch_lab...
                ,'baseline',[-2400 -1999]...
                ,'freqs', [6:1:40]...
                ,'timesout', [-2400:10:2996]... vector of times at which the function will provide ersp values
                ,'padratio', 64.... number of zeros which will be added at the borders of the signal, to cosmetically (fake!!!!) increase the spectral resolution/smoothness of the tf dscomposition
                ,'winsize',100 ...
                );
        end
        
        
    else
        disp(['error: condition file name (' input_name_noext ') not found!!!! exiting .....']);
        %                 return;
    end
    
    
end
end