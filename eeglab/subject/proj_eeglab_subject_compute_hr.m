%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_compute_hr(project, varargin)



list_select_subjects    = project.subjects.list;
get_filename_step       = 'custom_pre_epochs';
custom_suffix           = '';
custom_input_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'get_filename_step',    ...
                'custom_input_folder',  ...
                'custom_suffix' ...
                };
            
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

%     names = {};
%     durations = {};
%     ranks = {};
%     ica_types ={};

for subj=1:numsubj
    sel_sub = vsel_sub(subj);
    subj_name   = list_select_subjects{subj};
    inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    
    EEG = [];
    if(exist(inputfile))
        disp(inputfile);
        
        EEG                     = pop_loadset(input_file_name);
        [fpath,fname,fext] = fileparts(input_file_name);
        
        all_ch = {EEG.chanlocs.labels};
        tch = length(all_ch);
        
        sel_ch = find(ismember(all_ch, project.hr.ecg_channel),'first');
        current_ch = all_ch{sel_ch};
        
        %% compute heart rate
        EEG_hr = pop_select( EEG, 'channel',{current_ch});
        
        EEG_hr  = pop_basicfilter(EEG_hr, 1 , ...
            'Boundary', 'boundary', ...
            'Cutoff',  1, ...
            'Design', 'butter',...
            'Filter', 'highpass',...
            'Order',  2, ...
            'RemoveDC','on');
        detsq =  EEG_hr.data .^2;
        
        
        % detect qrs
        pulse = zeros(length(detsq,1));

        if project.hr.method == 1
            % by hand https://www.youtube.com/watch?v=flSL0SXNjbI
            last = 0;
            upflag = 0;
            th_qrs= mean(detsq) + 2*std(detsq);%0.1;
            
            for i = 1:length(detsq)
                if (upflag == 0)
                    if (destsq(i) > th_qrs)
                        if (last < 0)
                            t = i - last;
                            p = EEG_hr.srate/t * 60;
                        end
                        last = i;
                    end
                    upflag = round(100 * EEG.srate/1000);
                else
                    if (upflag > 0)
                        upflag = upflag - 1;
                    end
                    pulse(i) = p;
                end
            end
            if project.hr.method == 2
                % using findpeaks
                vec_pt = 1:length(detsq);
                [d_peaks, locs_peaks] = findpeaks(detsq, 'MinPeakDistance',round(100 * EEG.srate/1000));
                dt_pt = diff(locs_peaks);
                hr_vec =  EEG_hr.srate/dt_pt * 60;
                hr_vec = [hr_vec(1),hr_vec];
                loc_hr = [1,locs_peaks,length(detsq)];
                for nloc = 1:(length(loc_hr)-1)
                    selt = vec_pt >= loc_hr(nloc) & vec_pt <=  loc_hr(nloc+1);
                    pulse(selt) = hr_vec(nloc);
                end
            end
            
            %% possible smoothing or checking for bad detections/interpolating
            
            EEG.data(tch+1) = pulse;
            EEG.chanlocs(tch+1) = EEG.chanlocs(sel_ch);
            EEG.chanlocs(tch+1).labels =  'HR';

            EEG = pop_saveset( EEG, 'filename',[fname, fext],'filepath',fpath);
            
            
        end
        
    end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name
