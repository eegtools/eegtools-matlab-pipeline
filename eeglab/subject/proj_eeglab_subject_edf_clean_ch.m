%% EEG = proj_eeglab_subject_preprocessing(project, varargin)
%
% function to preprocess already imported and filtered data
%
% SUBSAMPLING
% CHANNELS TRANSFORMATION
% INTERPOLATION
% EVENT FILTERING
% SPECIFIC FILTERING
%
%%
function project = proj_eeglab_subject_edf_clean_ch(project, varargin)


list_select_subjects    = project.subjects.list;
get_filename_step       = 'output_import_data';
custom_suffix           = '';
custom_input_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'get_filename_step',    ...
                'custom_input_folder',  ...
                'custom_suffix' ...
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



for subj=1:numsubj
    
    subj_name               = list_select_subjects{subj};
    input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    disp(input_file_name);
    if exist(input_file_name)
        try
            EEG                     = pop_loadset(input_file_name);
        catch
            [fpath,fname,fext] = fileparts(input_file_name);
            EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
        end
    else
        disp('no such file!');
    end
    
    
    eeglab_channels_file    = project.eegdata.eeglab_channels_file_path;
    
    chan_match = project.import.complete_montage;
    
    allch = {EEG.chanlocs.labels};
    tot_ch = length(allch);
    for nch = 1:tot_ch
        current_ch = allch(nch);
        
        is_eeg = sum(strfind_index(current_ch,chan_match));
        
        if is_eeg
            [out_strfind_index_embed] = strfind_index_embed(chan_match,current_ch);
            best_match = out_strfind_index_embed.best_match;
            EEG.chanlocs(nch).labels = best_match{:};
        end
        
        
        
%         if sum(ismember(current_ch','E' )) == 2 &&...
%                 sum(ismember(current_ch,'G' )) == 1%sum(ismember('EEG',current_ch ))
%             current_ch_clean = current_ch(5:end-3);
%             EEG.chanlocs(nch).labels = current_ch_clean;
%         end
%         
%         if sum(ismember(current_ch','-' )) == 1 &&...
%            sum(ismember(current_ch','R' )) == 1 &&...
%            sum(ismember(current_ch,'e' )) == 1 &&...
%            sum(ismember(current_ch,'f' )) == 1 %sum(ismember('EEG',current_ch ))
%             current_ch_clean = current_ch(1:end-4);
%             EEG.chanlocs(nch).labels = current_ch_clean;
%         end
%         
        
    end
    EEG=pop_chanedit(EEG, 'lookup',eeglab_channels_file);
    
    EEG = eeg_checkset( EEG );
    
    
    EEG = eeg_checkset(EEG);
    eeglab redraw;
    EEG  = pop_saveset( EEG, 'filename', EEG.filename, 'filepath', EEG.filepath);
    
    
    
    
end


end

