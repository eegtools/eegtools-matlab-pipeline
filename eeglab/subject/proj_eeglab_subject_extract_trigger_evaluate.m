%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_extract_trigger_evaluate(project, varargin)





list_select_subjects    = project.subjects.list;
get_filename_step       = 'extract_trigger';
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

str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
results_path                = project.paths.results;
extract_trigger_path = fullfile(results_path,['extract_trigger','_',str]);
if not(exist(subject_ersp_curve_path))
    mkdir(extract_trigger_path)
end


% -------------------------------------------------------------------------------------------------------------------------------------

tot_labels = length(project.extract_trigger.duration.trigger_lab);

for subj=1:numsubj
    
    subj_name   = list_select_subjects{subj};
    inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'export_data', custom_suffix, 'custom_input_folder', custom_input_folder);
    
    [filepath,name_noext,ext] = fileparts(inputfile);
    
    if exist(inputfile)
        try
            EEG                     = pop_loadset(inputfile);
        catch
            [fpath,fname,fext] = fileparts(inputfile);
            EEG = pop_loadset('filename',fname,'filepath',fpath);
        end
        EEG = pop_saveset('filename',[fname,'_trigger_bck'],'filepath',fpath);
        
        
        
        
        
        
        allch_lab = {EEG.chanlocs.labels};
        sel_ch = ismember(allch_lab, project.extract_trigger.channel_lab);
        data_ch = EEG.data(sel_ch,:);
        
        
        allevelab = [EEG.event.type];
        allevelat = [EEG.event.latency];
        
        sel_t1 = ismember(allevelab,project.extract_trigger.evaluate.trigger1);
        vt1 =  allevelat(sel_t1);
        
        sel_t2 = ismember(allevelab,project.extract_trigger.evaluate.trigger2);
        vt2 =  allevelat(sel_t2);
        
        bound_trigger = zeros(size(data_ch));
        
        for n12 = 1:length(vt1)
            sel_12 = vt1(n12):vt2(n12);
            bound_trigger(sel_12) = 1;
        end
        
        
        tch = EEG.nbchan;
        if strcmp(project.extract_trigger.do_rectification, 'on')
            data_ch = abs(data_ch - mean(data_ch)); % in uV
            EEG.data = [EEG.data;data_ch];
            EEG.chanlocs(tch+1) = EEG.chanlocs(sel_ch);
            EEG.chanlocs(tch+1).labels = [EEG.chanlocs(sel_ch).labels,'_rect'];
        end
        
        
        if strcmp(project.extract_trigger.mode, 'abs_th')
            data_ch_th = data_ch > project.extract_trigger.abs_th.th_amplitude; % in uV
        end
        
        if strcmp(project.extract_trigger.mode, 'stat_th')
            % project.extract_trigger.stat_th.baseline.nsd = 3; % number of sd from the mean of the baseline period, 3 corrsponds rawly to 99% CI, 2 to 95% CI
            % project.extract_trigger.stat_th.baseline.limits_s = [1,5]; % baseline begin/end in seconds
            baseline_pt =  round(project.extract_trigger.stat_th.baseline.limits_s*EEG.srate);
            b1 = baseline_pt(1);
            b2 = baseline_pt(2);
            sel_baseline = EEG.times >= b1 & EEG.times <= b2;
            data_baseline = data_ch(sel_baseline);
            mean_baseline = mean(data_baseline);
            sd_baseline = std(data_baseline);
            
            th_pos = mean_baseline + project.extract_trigger.stat_th.baseline.nsd * sd_baseline;
            sel_pos = data_ch > th_pos;
            
            th_neg = mean_baseline - project.extract_trigger.stat_th.baseline.nsd * sd_baseline;
            sel_neg = data_ch < th_neg;
            
            sel_both = sel_pos & sel_neg;
            
            if strcmp(project.extract_trigger.stat_th.side, 'neg')
                data_ch_th = sel_neg;
            end
            
            if strcmp(project.extract_trigger.stat_th.side, 'pos')
                data_ch_th = sel_pos;
            end
            
            if strcmp(project.extract_trigger.stat_th.side, 'both')
                data_ch_th = sel_both;
            end
            
            
            tch = EEG.nbchan;
            
            vonset  = [];
            voffset = [];
            
            data_bound =0;
            sel_th = find(data_ch_th);
            
            for nt12 = 1:length(vt1) % for each bound period
                sel_t12 = vt1(nt12):vt2(nt12);
                
                sel_step = intersect(sel_t12,sel_th);
                
                if not(isempty(project.extract_trigger.evaluate.lag.min))
                    sel_clean = ...
                        vt1(nt12) - sel_step < ...
                        (project.extract_trigger.evaluate.lag.min*EEG.srate/1000);
                    sel_step = sel_step(sel_clean);
                    
                end
                
                tonset = min(sel_step);
                toffset = max(sel_step);
                sel_tt = tonset:toffset;
                vonset = [vonset,tonset];
                voffset = [voffset,toffset];
                data_bound(sel_tt) = 1;
            end
            
            EEG.data = [EEG.data;data_bound];
            EEG.chanlocs(tch+1) = EEG.chanlocs(sel_ch);
            EEG.chanlocs(tch+1).labels = [EEG.chanlocs(sel_ch).labels,'_trigger'];
            
            
            vecdiff = (vt1 - von)/EEG.srate*1000;
            
            fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
            subplot(1,2,1);
            hist(vecdiff)
            subplot(1,2,2);
            plot(vecdiff,'p');
            grid minor;
            
            dif.vec = vecdiff;
            dif.mean = mean(vecdiff);
            dif.sd = std(vecdiff);
            dif.min =  min(vecdiff);
            dif.max = max(vecdiff);
            str = [subj_name,...
                ' mean: ',num2str(dif.mean),...
                ' sd: ',num2str(dif.sd),...
                ' range: [',num2str(dif.min),' ',num2str(dif.max) ']'];
            suptitle(str);
            disp(str);
            
            EEG.event = [];
            for nonset = 1:length(vonset)
                EEG.event(nonset).type = 'onset';
                EEG.event(nonset).latency = vonset(nonset);
                EEG.event(nonset).duration = voffset(nonset) - vonset(nonset);
            end
            
            all_latencies=[EEG.event.latency];
            [sort_lat, indsort] = sort(all_latencies);
            EEG.event = EEG.event(indsort);
            
            EEG = eeg_checkset( EEG );
            EEG = pop_saveset('filename',fname,'filepath',fpath);
        end
        
        inputsf.plot_dir    = extract_trigger_path;
        inputsf.fig         = fig;
        inputsf.name_embed  = 'extract_trigger';
        inputsf.suffix_plot = subj_name;
        save_figures(inputsf,'res','-r100','exclude_format','svg');
        close all
        
        save(fullfile(inputsf.plot_dir,[subj_name,'.mat']), 'dif');
        
    end
    
    
    
end


end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
