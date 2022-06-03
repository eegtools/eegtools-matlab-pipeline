%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_characterize_events(project, varargin)

EEG = [];

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
vsel_sub = find(ismember(project.subjects.list,list_select_subjects));

% -------------------------------------------------------------------------------------------------------------------------------------

teve_lab = length(project.characterize_events.event_label);

if isfield(project, 'characterize_events')
    
    subject_col_label = project.characterize_events.subject_col_label;
    
    if not(isempty(project.characterize_events.xls_folder)) &&....
            not(isempty(project.characterize_events.xls_file)) && ...
            not(isempty(project.characterize_events.xls_sheet))
        xls_path = fullfile(project.characterize_events.xls_folder,project.characterize_events.xls_file);
        if exist(xls_path,'file')
            [~,~,RAW] = xlsread(xls_path, project.characterize_events.xls_sheet);
            aa = cellfun(@isnan,RAW(:,1),'UniformOutput',false);
            bb = cellfun(@sum,aa,'UniformOutput',false);
            cc = [bb{:}]==0;
            if sum(cc)
             RAW =   RAW(cc,:);
            end
            col_names = RAW(1,:);
            sel_sub_col = ismember(col_names, subject_col_label);
            sub_col = RAW(2:end,sel_sub_col);
            sel_nf = find(not(sel_sub_col));
            new_fields = col_names(sel_nf);
            
            sub_intersect = intersect(sub_col,list_select_subjects);
            
            %             project = project;
            % project.subjects.data = setfield(project.subjects.data,new_fields{2},cell( 1, length(project.subjects.data )));
            tf = length(new_fields);
            numsubj = length(sub_intersect);
            
            %             for ns = 1:ts
            %                 current_subject = sub_intersect{ns};
            %                 sel_sub = ismember({project.subjects.data.name},current_subject);
            %                 inds = sel_sub(ns)+1;
            %                 for nf = 1:tf
            %                     current_field = new_fields{nf};
            %                     current_val = RAW{inds,sel_nf(nf)};
            %                     project.subjects.data(ns).(current_field) = current_val;
            %                 end
            %             end
            
            
            
            
            
            
            
            for subj=1:numsubj
                subj_name   = sub_intersect{subj};
                
                sel_sub = ismember(sub_col,subj_name);
                RAW_sub = RAW(sel_sub,:);
                
                [nr_sub, nc_sub] = size(RAW_sub);
                
                
                input_file_name   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
                [fpath,fname,fext] = fileparts(input_file_name);

                try
                    EEG                     = pop_loadset(input_file_name);
                catch
                    EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
                end
                
                all_eve_lab = {EEG.event.type};
                
                for nf = 1:tf
                    current_field = new_fields{nf};
                    
                    for neve_lab = 1:teve_lab
                        current_eve_lab = project.characterize_events.event_label{neve_lab};
                        ind_sel_eve = find(ismember(all_eve_lab,current_eve_lab));
                        
                        
                        for neve = 1:length(ind_sel_eve)
                            neve_eeg = ind_sel_eve(neve);
                            neve_RAW = neve + 1;
                            current_val = RAW{neve_RAW,sel_nf(nf)};
                            EEG.event(neve_eeg).(current_field) = current_val;
                            EEG.event(neve_eeg).neve  = neve;
                        end
                        
                    end
                    
                end
                EEG = eeg_checkset( EEG );
                EEG                     = pop_saveset( EEG, 'filename', fname, 'filepath', fpath);
                
            end
        end
    end
end
%     summary = [names; ranks; ica_types; durations]';
%     disp(summary);
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name
