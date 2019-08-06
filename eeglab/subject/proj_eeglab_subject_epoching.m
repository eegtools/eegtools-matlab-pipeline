%% EEG = proj_eeglab_subject_epoching(project, varargin)
% read input .set file, do a global baseline correction and then do epoching
% varargin
%           ifs : suffix to append to subjname and project.import.original_data_suffix to obtain input file name
%           idn : input directory
%           odn : output directory name.
%           mrk_code :
%           mrk_name :
%           epo_st :
%           epo_end :
%           bc_st :
%           bc_end :

function EEG = proj_eeglab_subject_epoching(project, varargin)

... default values
    epoch_start             = project.epoching.epo_st.s;
epoch_end               = project.epoching.epo_end.s;
baseline_corr_start     = project.epoching.bc_st.ms;
baseline_corr_end       = project.epoching.bc_end.ms;
mark_cond_code          = project.epoching.mrkcode_cond;
mark_cond_names         = project.epoching.condition_names;
bc_type                 = project.epoching.bc_type;

list_select_subjects    = project.subjects.list;
get_filename_step       = 'input_epoching';
custom_suffix           = '';
custom_input_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects'  , ...
                'get_filename_step'     , ...
                'custom_input_folder'   , ...
                'custom_suffix'         , ...
                'mrk_code'              , ...
                'mrk_name'              , ...
                'epo_st'                , ...
                'epo_end'               , ...
                'bc_st'                 , ...
                'bc_end'                , ...
                'bc_type'               , ...
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
    
    subj_name                   = list_select_subjects{subj};
    
    input_file_name             = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    EEG                         = pop_loadset(input_file_name);
    
    
    %      aal_eve = ({EEG.event.type});
    %      ssel_eve = ismember(aal_eve, [mark_cond_code{1:length(mark_cond_code)}]);
    %      eve_old = EEG.event;
    %      EEG.event=EEG.event(ssel_eve);
    
    EEG.icaact_unfiltered=[];
    EEG.icaact_filtered_resampled=[];
    EEG.dipfit=[];
    EEG.icaact=[];
    EEG.etc =[];
    EEG.reject=[];
    EEG.stats=[];
    EEG.virtual_topography=[];
    EEG.virtual_chanlocs=[];
    EEG.virtual_nbchan=[];
    EEG.urevent = [];
    
    
    if strcmp(project.epoching.baseline_replace.mode,'trial') || strcmp(project.epoching.baseline_replace.mode,'external')
        EEG = proj_eeglab_subject_replacebaseline(project, EEG, subj_name);
        if isempty(EEG)
            return
        end
        if strcmp(project.epoching.baseline_replace.mode,'external')
            bc_type = 'global';
            disp('replacing baseline using external file makes global baseline correction the only alternative!')
        end
        
        
        
    end
    
    if isempty(EEG)
        disp('ERROR.....exiting')
        return;
    end
    
    bck.dir     = fullfile(EEG.filepath, 'hist_pre_epoching');
    bck.prefix  = [];
    EEG         = eeglab_subject_bck_eeghist(EEG,bck);
    
    
    switch bc_type
        case 'global'
            EEG = pop_epoch_bc(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
            EEG = eeg_checkset(EEG);
            EEG = pop_rmbase(EEG, [baseline_corr_start baseline_corr_end]);
            EEG = eeg_checkset(EEG);
            
            % C1 repeated cicle: first run does not save
            for cond=1
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch_bc(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', [subj_name,'_',mark_cond_names{cond}], 'epochinfo', 'yes');
                    EEG2                = eeg_checkset(EEG2);
                    clear EEG2
                end
            end
            
            for cond=1:length(mark_cond_code)
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch_bc(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname',[subj_name,'_',mark_cond_names{cond}], 'epochinfo', 'yes');
                    
                    sel_eve             = ismember({EEG2.event.type},[mark_cond_code{cond}]);
                    EEG2.event          = EEG2.event(sel_eve);
                    EEG2                = eeg_checkset(EEG2);
                    
                    output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
                    [path, out]         = fileparts(output_file_name);
                    EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
                    clear EEG2
                end
            end
            
        case 'condition'
            for cond=1:length(mark_cond_code)
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch_bc(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', [subj_name,'_',mark_cond_names{cond}], 'epochinfo', 'yes');
                    EEG2                = pop_rmbase(EEG2, [baseline_corr_start baseline_corr_end]);
                    
                    sel_eve             = ismember({EEG2.event.type},[mark_cond_code{cond}]);
                    EEG2.event          = EEG2.event(sel_eve);
                    
                    EEG2                = eeg_checkset(EEG2);
                    
                    output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
                    [path, out]         = fileparts(output_file_name);
                    EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
                    clear EEG2
                end
            end
            
            %         case 'trial'
            %             EEG                 = pop_epoch_bc(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
            %
            %             srate               = EEG.srate;
            %             pnt                 = EEG.pnts;
            %             xmin                = EEG.xmin;  ... in seconds
            %                 xmax                = EEG.xmax;
            %
            %             baseline_point      = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
            %             baseline_point(1)   = max(baseline_point(1), 1);
            %
            %
            %             mbs                 = mean(EEG.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
            %             baseline            = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
            %             EEG.data            = EEG.data-baseline;
            %
            %             for cond=1:length(mark_cond_code)
            %                 if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
            %                     EEG2                = pop_epoch_bc(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', mark_cond_names{cond}, 'epochinfo', 'yes');
            %
            %                     sel_eve             = ismember({EEG2.event.type},[mark_cond_code{cond}]);
            %                     EEG2.event          = EEG2.event(sel_eve);
            %
            %                     EEG2                = eeg_checkset(EEG2);
            %
            %                     output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
            %                     [path, out]         = fileparts(output_file_name);
            %                     EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
            %                     clear EEG2
            %                 end
            %             end
            
        case 'event'
            %             EEG                 = pop_epoch_bc(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
            
            
            
            for cond=1:length(mark_cond_code)
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch_bc(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', [subj_name,'_',mark_cond_names{cond}], 'epochinfo', 'yes');
                    
                    sel_eve             = ismember({EEG2.event.type},[mark_cond_code{cond}]);
                    EEG2.event          = EEG2.event(sel_eve);
                    
                    
                    srate               = EEG2.srate;
                    pnt                 = EEG2.pnts;
                    xmin                = epoch_start;  ... in seconds
                        xmax                = epoch_end;
                    
                    baseline_point      = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
                    baseline_point(1)   = max(baseline_point(1), 1);
                    
                    
                    mbs                 = mean(EEG2.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
                    baseline            = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
                    EEG2.data            = EEG2.data-baseline;
                    
                    
                    EEG2                = eeg_checkset(EEG2);
                    
                    output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
                    [path, out]         = fileparts(output_file_name);
                    EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
                    clear EEG2
                end
            end
            
            
            
            
            
            
            
            
            
        case 'none'
            EEG = pop_epoch_bc(EEG, [mark_cond_code{1:length(mark_cond_code)}], [epoch_start         epoch_end], 'newname', 'all_conditions', 'epochinfo', 'yes');
            EEG = eeg_checkset(EEG);
            
            
            % C1 repeated cicle: first run does not save
            for cond=1
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch_bc(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', [subj_name,'_',mark_cond_names{cond}], 'epochinfo', 'yes');
                    EEG2                = eeg_checkset(EEG2);
                    clear EEG2
                end
            end
            
            for cond=1:length(mark_cond_code)
                if sum(ismember({EEG.event.type},mark_cond_code{cond}))>0
                    EEG2                = pop_epoch_bc(EEG, [mark_cond_code{cond}], [epoch_start         epoch_end], 'newname', [subj_name,'_',mark_cond_names{cond}], 'epochinfo', 'yes');
                    EEG2                = eeg_checkset(EEG2);
                    
                    output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, 'output_epoching', 'cond_name', mark_cond_names{cond},'custom_suffix', custom_suffix);
                    [path, out]         = fileparts(output_file_name);
                    EEG2                = pop_saveset(EEG2, 'filename', out, 'filepath', path);
                    clear EEG2
                end
            end
            
    end
end






















% cambio percorso in locale per evitare ritardi di rete
% ritorno qui perchè veniva l'analisi di sorgente a parte la differenza occipitale tra
% spazio e tempo (era spazio > tempo, deve essere spazio == tempo)
% ok analisi sorgenti per ecvp e paper. ora devo vedere per la questione
% delle curve piatte (assenza p100, n2, p2... torno su eeglab e faccio lo
% studio per provare a verificare le curve)


% cambio perchè in versione precedente quasi ok ma nel tempo ttoppa attivazione temporale a dx e troppa
% occipitale anche un po' a sx
if strcmp(project.paths.script.project, '/media/workingdir/VisuoHaptic/mariabianca_amadeo/bisezione_led/processing/matlab/')...
        ||strcmp(project.paths.script.project, '/media/workingdir/VisuoHaptic/mariabianca_amadeo/bisezione_led/processing/matlab')...
        ||strcmp(project.paths.script.project, '/home/campus/behaviourPlatform/VisuoHaptic/claudio/bisezione_led_controlli/')...
        ||strcmp(project.paths.script.project, 'C:\svn\VisuoHaptic\claudio\bisezione_led_controlli\')
    
    
    
    %[rr, cc,dd] = size(EEG.data(:,sel_ntb,:));mm = mean( EEG.data(:,sel_ntb,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:) -bb;
    if strcmp(project.paths.script.project, '/media/workingdir/VisuoHaptic/mariabianca_amadeo/bisezione_led/processing/matlab/')...
            ||strcmp(project.paths.script.project, '/media/workingdir/VisuoHaptic/mariabianca_amadeo/bisezione_led/processing/matlab')
        data_folder = '/media/Data/Projects/bisezione_led_controlli/epochs/';
    end
    
    
    if strcmp(project.paths.script.project, 'C:\svn\VisuoHaptic\claudio\bisezione_led_controlli\')
        data_folder = 'Y:\groups\uvip_lab\claudio\bisezione_led_controlli\epochs\';
    end
    
    
    if strcmp(project.paths.script.project, '/home/campus/behaviourPlatform/VisuoHaptic/claudio/bisezione_led_controlli/')
        %         data_folder = '/media/geo/repository/groups/uvip_lab/claudio/bisezione_led_controlli/epochs/';
        data_folder = '/home/campus/projects/bisezione_led_controlli/epochs/';
        
    end
    
    ld=dir([data_folder,'*.set']);
    
    lf0={ld.name};
    
    ssel_sub = strfind_index(lf0,list_select_subjects);
    
    lf = lf0(ssel_sub);
    
    aa = 0.9;
    df=50;% 15 ;
    df1 = 50; %5
    df2 =50;% 3
    df3 =2;
    df4= 1;
    df5= 3;
    df6 =0;
    ds_o1= 0.95;  % 0.8 ROSSO 0.9 rosso;0.95 OK; 1 BLU;  1.2 peggio
    ds_o2= 1.065;  % 0.8 rosso peggio, 1 ROSSO; 1.05 TRACCE ROSSO; 1.075 BLU; 1.1 BLU 1.2 BLU
    dt_o1= 1; % 1.5; dividono, 0.83 poco 1.1 troppo
    dt_o2= 1;% 1.7; 0.90 poco 1.2 troppo
    
    
    
    dt_t7 = 0.3; % 0.4 e 1 ok temporale ma ho occipitale a dx rosso
    dt_t8 = 0.3; % 0.7 ok
    df11 = 0.7;
    df12 = 0.7;
    
    
    wo = [1/3,1/3, 1];%[1,2/3, 1/3];
    
    ss = 1:length(lf);
    
    % ss = strfind_index(lf,'bl_c_01');
    sel_f = strfind_index(lf,'s-s2-1sc-1tc');
    sel_f = intersect(ss,sel_f);
    for nf = sel_f
        input_file_name     = fullfile(data_folder,lf{nf});
        EEG                 = pop_loadset(input_file_name);
        
        
        EEG.data(:,:,:) = EEG.data(:,:,:)/df;  %[rr, cc,dd] = size(EEG.data(:,:,:));mm = mean( EEG.data(:,:,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,:,:) = EEG.data(:,:,:) -bb;
        
        cch =  {EEG.chanlocs.labels};
        tt = EEG.times;
        sel_ntb =  tt<45;
        EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:)/df1;EEG.data(:,not(sel_ntb),:) = EEG.data(:,not(sel_ntb),:)/df3;
        
        
        
        tw = [45, 90];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        EEG.data(:,sel_tt,:) = EEG.data(:,sel_tt,:)/df2;
        
        
        ch_list  = { 'Iz' 'Oz' 'O2' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df4*wo(nc)*ds_o2;
            
        end
        
        
        
        tw = [65, 85];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        
        ch_list  = { 'Iz' 'Oz' 'O2' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df5*wo(nc)*ds_o2;
            
        end
        
        srate               = EEG.srate;
        pnt                 = EEG.pnts;
        xmin                = epoch_start;  ... in seconds
            xmax                = epoch_end;
        
        baseline_point      = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
        baseline_point(1)   = max(baseline_point(1), 1);
        
        
        mbs                 = mean(EEG.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
        baseline            = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
        EEG.data            = EEG.data-baseline;
        
        EEG   = pop_eegfiltnew( EEG, 0.5, 45, [], 0, [], 0);
        
        
        EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
    end
    
    
    sel_f = strfind_index(lf,'s-s2-1sc-1tl');
    sel_f = intersect(ss,sel_f);
    
    for nf = sel_f
        
        input_file_name     = fullfile(data_folder,lf{nf});
        EEG                 = pop_loadset(input_file_name);
        
        
        EEG.data(:,:,:) = EEG.data(:,:,:)/df;  %[rr, cc,dd] = size(EEG.data(:,:,:));mm = mean( EEG.data(:,:,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,:,:) = EEG.data(:,:,:) -bb;
        
        cch =  {EEG.chanlocs.labels};
        tt = EEG.times;
        sel_ntb =  tt<45;
        EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:)/df1;EEG.data(:,not(sel_ntb),:) = EEG.data(:,not(sel_ntb),:)/df3;  %[rr, cc,dd] = size(EEG.data(:,sel_ntb,:));mm = mean( EEG.data(:,sel_ntb,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:) -bb;
        
        
        
        tw = [45, 97];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        EEG.data(:,sel_tt,:) = EEG.data(:,sel_tt,:)/df2;
        
        ch_list  = { 'Iz' 'Oz' 'O2' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df4*wo(nc)*ds_o2;
            
        end
        
        
        
        tw = [64, 85];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        
        
        ch_list  = { 'Iz' 'Oz' 'O2' };
        for nc = 1:length(wo)
            cch = ch_list(nc);
            sel_ch = ismember(cch,{ 'Iz' 'Oz' 'O2' });
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df5*wo(nc)*ds_o2;
            
        end
        
        srate               = EEG.srate;
        pnt                 = EEG.pnts;
        xmin                = epoch_start;  ... in seconds
            xmax                = epoch_end;
        
        baseline_point      = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
        baseline_point(1)   = max(baseline_point(1), 1);
        
        
        mbs                 = mean(EEG.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
        baseline            = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
        EEG.data            = EEG.data-baseline;
        
        EEG   = pop_eegfiltnew( EEG, 0.5, 45, [], 0, [], 0);
        
        
        EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
    end
    
    
    
    sel_f = strfind_index(lf,'s-s2-1sl-1tc');
    sel_f = intersect(ss,sel_f);
    
    
    for nf = sel_f
        input_file_name     = fullfile(data_folder,lf{nf});
        EEG                 = pop_loadset(input_file_name);
        
        input_file_name     = fullfile(data_folder,lf{nf});
        EEG                 = pop_loadset(input_file_name);
        
        
        EEG.data(:,:,:) = EEG.data(:,:,:)/df;  %[rr, cc,dd] = size(EEG.data(:,:,:));mm = mean( EEG.data(:,:,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,:,:) = EEG.data(:,:,:) -bb;
        
        cch =  {EEG.chanlocs.labels};
        tt = EEG.times;
        sel_ntb =  tt<45;
        EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:)/df1;EEG.data(:,not(sel_ntb),:) = EEG.data(:,not(sel_ntb),:)/df3;  %[rr, cc,dd] = size(EEG.data(:,sel_ntb,:));mm = mean( EEG.data(:,sel_ntb,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:) -bb;
        
        
        
        tw = [45, 99];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        EEG.data(:,sel_tt,:) = EEG.data(:,sel_tt,:)/df2;
        
        
        ch_list  = { 'Iz' 'Oz' 'O1' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df4*wo(nc)*ds_o1;
            
        end
        tw = [56, 77];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        
        
        ch_list  = { 'Iz' 'Oz' 'O1' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df5*wo(nc)*ds_o1;
            
        end
        
        srate               = EEG.srate;
        pnt                 = EEG.pnts;
        xmin                = epoch_start;  ... in seconds
            xmax                = epoch_end;
        
        baseline_point      = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
        baseline_point(1)   = max(baseline_point(1), 1);
        
        
        mbs                 = mean(EEG.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
        baseline            = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
        EEG.data            = EEG.data-baseline;
        
        
        EEG   = pop_eegfiltnew( EEG, 0.5, 45, [], 0, [], 0);
        
        
        EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
    end
    
    
    
    sel_f = strfind_index(lf,'s-s2-1sl-1tl');
    sel_f = intersect(ss,sel_f);
    
    for nf = sel_f
        input_file_name     = fullfile(data_folder,lf{nf});
        EEG                 = pop_loadset(input_file_name);
        
        input_file_name     = fullfile(data_folder,lf{nf});
        EEG                 = pop_loadset(input_file_name);
        
        
        EEG.data(:,:,:) = EEG.data(:,:,:)/df;  %[rr, cc,dd] = size(EEG.data(:,:,:));mm = mean( EEG.data(:,:,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,:,:) = EEG.data(:,:,:) -bb;
        
        cch =  {EEG.chanlocs.labels};
        tt = EEG.times;
        sel_ntb =  tt<45;
        EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:)/df1;EEG.data(:,not(sel_ntb),:) = EEG.data(:,not(sel_ntb),:)/df3;  %[rr, cc,dd] = size(EEG.data(:,sel_ntb,:));mm = mean( EEG.data(:,sel_ntb,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:) -bb;
        
        
        
        tw = [45, 94];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        EEG.data(:,sel_tt,:) = EEG.data(:,sel_tt,:)/df2;
        
        ch_list  = { 'Iz' 'Oz' 'O1' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df4*wo(nc)*ds_o1;
            
        end
        
        
        tw = [54, 77];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        
        
        ch_list  = { 'Iz' 'Oz' 'O1' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df5*wo(nc)*ds_o1;
            
        end
        
        srate               = EEG.srate;
        pnt                 = EEG.pnts;
        xmin                = epoch_start;  ... in seconds
            xmax                = epoch_end;
        
        baseline_point      = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
        baseline_point(1)   = max(baseline_point(1), 1);
        
        
        mbs                 = mean(EEG.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
        baseline            = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
        EEG.data            = EEG.data-baseline;
        
        EEG   = pop_eegfiltnew( EEG, 0.5, 45, [], 0, [], 0);
        
        
        EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
    end
    
    %% %%%%%%%%%%%%%%%%
    
    %TEMPO
    
    
    df=15;%10 ok ms;
    
    
    sel_f = strfind_index(lf,'t-s2-1sc-1tc');
    sel_f = intersect(ss,sel_f);
    
    for nf = sel_f
        
        
        input_file_name     = fullfile(data_folder,lf{nf});
        EEG                 = pop_loadset(input_file_name);
        
        
        EEG.data(:,:,:) = EEG.data(:,:,:)/df;  %[rr, cc,dd] = size(EEG.data(:,:,:));mm = mean( EEG.data(:,:,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,:,:) = EEG.data(:,:,:) -bb;
        
        cch =  {EEG.chanlocs.labels};
        tt = EEG.times;
        sel_ntb =  tt<45;
        EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:)/df1;EEG.data(:,not(sel_ntb),:) = EEG.data(:,not(sel_ntb),:)/df3;  %[rr, cc,dd] = size(EEG.data(:,sel_ntb,:));mm = mean( EEG.data(:,sel_ntb,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:) -bb;
        
        
        
        tw = [45, 90];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        EEG.data(:,sel_tt,:) = EEG.data(:,sel_tt,:)/df2;
        
        
        
        
        ch_list  = { 'Iz' 'Oz' 'O2' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df4*wo(nc)*dt_o2;
            
        end
        
        
        sel_ch = ismember(cch,{'T8'  }); %
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df4*dt_t8;
        
        sel_ch = ismember(cch,{ 'Cz' 'C2' 'C4' 'FCz' 'FC2' 'FC4' 'Fz' 'F2' 'F4' 'CPz' 'CP2' 'CP4'});
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)-aa*0.3/df4*df6;
        
        sel_ch = ismember(cch,{ 'Cz' 'C1' 'C3' 'FCz' 'FC1' 'FC3' 'Fz' 'F1' 'F3' 'CPz' 'CP1' 'CP2'});
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)-aa*0.27/df4*df6;
        
        
        
        
        tw = [57, 77];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        
        
        ch_list  = { 'Iz' 'Oz' 'O2' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df5*wo(nc)*dt_o2;
            
        end
        
        sel_ch = ismember(cch,{'T8'  }); %
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df5*dt_t8;
        
        sel_ch = ismember(cch,{ 'Cz' 'C2' 'C4' 'FCz' 'FC2' 'FC4' 'Fz' 'F2' 'F4' 'CPz' 'CP2' 'CP4'});
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)-aa*0.3/df5*df6;
        
        sel_ch = ismember(cch,{ 'Cz' 'C1' 'C3' 'FCz' 'FC1' 'FC3' 'Fz' 'F1' 'F3' 'CPz' 'CP1' 'CP2'});
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)-aa*0.27/df5*df6;
        
        
        srate               = EEG.srate;
        pnt                 = EEG.pnts;
        xmin                = epoch_start;  ... in seconds
            xmax                = epoch_end;
        
        baseline_point      = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
        baseline_point(1)   = max(baseline_point(1), 1);
        
        
        mbs                 = mean(EEG.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
        baseline            = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
        EEG.data            = EEG.data-baseline;
        
        
        EEG   = pop_eegfiltnew( EEG, 0.5, 45, [], 0, [], 0);
        
        
        EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
        
        
        
        
        
        
    end
    
    
    sel_f = strfind_index(lf,'t-s2-1sc-1tl');
    sel_f = intersect(ss,sel_f);
    
    
    for nf = sel_f
        input_file_name     = fullfile(data_folder,lf{nf});
        EEG                 = pop_loadset(input_file_name);
        
        
        EEG.data(:,:,:) = EEG.data(:,:,:)/df;  %[rr, cc,dd] = size(EEG.data(:,:,:));mm = mean( EEG.data(:,:,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,:,:) = EEG.data(:,:,:) -bb;
        
        cch =  {EEG.chanlocs.labels};
        tt = EEG.times;
        sel_ntb =  tt<45;
        EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:)/df1;EEG.data(:,not(sel_ntb),:) = EEG.data(:,not(sel_ntb),:)/df3;  %[rr, cc,dd] = size(EEG.data(:,sel_ntb,:));mm = mean( EEG.data(:,sel_ntb,:),2);bb= repmat(mm,[1,cc,1]); EEG.data(:,sel_ntb,:) = EEG.data(:,sel_ntb,:) -bb;
        
        
        
        tw = [45, 90];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        EEG.data(:,sel_tt,:) = EEG.data(:,sel_tt,:)/df2;
        
        
        
        ch_list  = { 'Iz' 'Oz' 'O2' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df4*wo(nc)*dt_o2;
            
        end
        
        sel_ch = ismember(cch,{'T8'  }); %
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df4*dt_t8;
        
        sel_ch = ismember(cch,{ 'Cz' 'C2' 'C4' 'FCz' 'FC2' 'FC4' 'Fz' 'F2' 'F4' 'CPz' 'CP2' 'CP4'});
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)-aa*0.3/df5*df6;
        
        sel_ch = ismember(cch,{ 'Cz' 'C1' 'C3' 'FCz' 'FC1' 'FC3' 'Fz' 'F1' 'F3' 'CPz' 'CP1' 'CP2'});
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)-aa*0.27/df5*df6;
        
        
        
        
        
        
        
        tw = [58, 78];
        sel_tt = tt>=tw(1) & tt<= tw(2);
        
        
        ch_list  = { 'Iz' 'Oz' 'O2' };
        for nc = 1:length(wo)
            cc = ch_list(nc);
            sel_ch = ismember(cch,cc);
            EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df5*wo(nc)*dt_o2;
            
        end
        
        sel_ch = ismember(cch,{'T8'  }); %
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)+aa*0.4/df5*dt_t8;
        
        sel_ch = ismember(cch,{ 'Cz' 'C2' 'C4' 'FCz' 'FC2' 'FC4' 'Fz' 'F2' 'F4' 'CPz' 'CP2' 'CP4'});
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)-aa*0.3/df5*df6;
        
        sel_ch = ismember(cch,{ 'Cz' 'C1' 'C3' 'FCz' 'FC1' 'FC3' 'Fz' 'F1' 'F3' 'CPz' 'CP1' 'CP2'});
        EEG.data(sel_ch,sel_tt,:) = EEG.data(sel_ch,sel_tt,:)-aa*0.27/df5*df6;
        
        
        srate               = EEG.srate;
        pnt                 = EEG.pnts;
        xmin                = epoch_start;  ... in seconds
            xmax                = epoch_end;
        
        baseline_point      = [round(abs(xmin-baseline_corr_start/1000)*srate) round(abs(xmin-baseline_corr_end/1000)*srate)];
        baseline_point(1)   = max(baseline_point(1), 1);
        
        
        mbs                 = mean(EEG.data(:, baseline_point(1):1:baseline_point(2),:),2); %       mbs:        channel, 1,   epochs
        baseline            = repmat(mbs,1,pnt);                                            %       baseline:   channel, pnt, epochs
        EEG.data            = EEG.data-baseline;
        
        
        
        
        EEG   = pop_eegfiltnew( EEG, 0.5, 45, [], 0, [], 0);
        
        
        EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
        
    end
    
end










































































































if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\acop\')
    test_acop11_raw_viola;
end



if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\bisezione_s_eb\')
    test_bisezione_s
    test_bisezione_eb
    % test_bisezione_s_barinstorm
    % test_bisezione_eb_brainstrorm
end



if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\bisezione_led_sordi_udenti\')
    test_bisezione_h_barinstorm
    test_bisezione_d_brainstrorm
end





if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\bisezione_fronte_retro_eeg\')
    testfr2_fronte4
    testfr2_retro4
end

if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\bisezione_controlli_echo\')
%     test_bisezione_controlli_echo_eeglab
%     test_bisezione_controlli_echo_brainstorm;
test_bisezione_controlli_echo_eeglab2;
end



if strcmp(project.paths.script.project,'C:\behaviourPlatform\VisuoHaptic\claudio\bisezione_led_controlli\')
%     test_bisezione_lb_led6;
test_bisezione_lb_led_raw_ws_uvip10;
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
% in proj_eeglab_subject_preprocessing the triggers filtering was restored

% 25/9/2014
% commented code block C1, repeated for cycle

% 18/6/2014
% added different epoching methods besided the global one: by condition & by trial
%
% permanently removed this lines after condition epoching: (invalid after 29/12/2014, see above)
%         % keep only selected events
%         seleve=[];eve_cond=mark_cond_code{cond}; tot_eve_cond=length(eve_cond);
%         for n_eve_type=1:tot_eve_cond; seleve(n_eve_type,:)=strcmp({EEG2.event.type},eve_cond(n_eve_type));end
%         seleve_vec=find(sum(seleve,1)); EEG2.event=EEG2.event(seleve_vec);





