function spectra = proj_eeglab_subject_spectra(project, varargin)

spectra = [];

freqrange       = project.preproc.subject_spectra.freqrange;
freq            = project.preproc.subject_spectra.freq;
plotchans       = project.preproc.subject_spectra.plotchans;
% band_analysis    = project.preproc.subject_spectra.band_analysis;
% chan_analysis    = project.preproc.subject_spectra.chan_analysis;
scale            = project.preproc.subject_spectra.scale;


list_band_lim =  project.preproc.subject_spectra.band_analysis.lim;   %= [0, 2; 2, 4; 4, 8; 8, 12];
list_band_name = project.preproc.subject_spectra.band_analysis.name;  % = {'delta1', 'delta2', 'theta', 'alpha1', 'alpha2'};

list_roi_ch =  project.preproc.subject_spectra.roi_analysis.ch;%     =  {{'O1','O2'},{'T7','T8'}, {'C3', 'C4'}};
list_roi_name = project.preproc.subject_spectra.roi_analysis.name;   %=  {'Visual','Auditory', 'Tactile'};

list_allroi_ch = [project.preproc.subject_spectra.roi_analysis.ch{:}];

list_agebin_lim  = project.preproc.subject_spectra.agebin.lim;
list_agebin_name = project.preproc.subject_spectra.agebin.name;

tab= length(list_agebin_name);

set_caxis = project.preproc.subject_spectra.band_analysis.caxis;
plot_single_subject = project.preproc.subject_spectra.plot_single_subject;

% set_caxis                           = project.results_display.ersp.set_caxis_topo_tw_fb;


str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
study_path                  = fullfile(project.paths.output_epochs, project.study.filename);
results_path                = project.paths.results;
subject_spectra_path = fullfile(results_path,['subject_spectra','_',str,'_',scale]);
if not(exist(subject_spectra_path))
    mkdir(subject_spectra_path)
end

plot_dir = fullfile(subject_spectra_path,'plot');
if not(exist(plot_dir))
    mkdir(plot_dir)
end

plot_dir_group = fullfile(plot_dir,['group','_',project.preproc.subject_spectra.analysis_name]);
if not(exist(plot_dir_group))
    mkdir(plot_dir_group)
end


plot_dir_group_allch = fullfile(plot_dir_group,'allch');
if not(exist(plot_dir_group_allch))
    mkdir(plot_dir_group_allch)
end


plot_dir_group_allroi = fullfile(plot_dir_group,'allroi');
if not(exist(plot_dir_group_allroi))
    mkdir(plot_dir_group_allroi)
end

mat_dir = fullfile(plot_dir,'mat');
if not(exist(mat_dir))
    mkdir(mat_dir)
end



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
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end

sel_subj = ismember({project.subjects.data.name},list_select_subjects);

numsubj = length(list_select_subjects);
ageallsub = [project.subjects.data.age];
sexallsub = {project.subjects.data.gender};
groupllsub = {project.subjects.data.group};

groups = unique(groupllsub(sel_subj));
tg = length(groups);

% -------------------------------------------------------------------------------------------------------------------------------------


input_spectra.freqrange           = freqrange;
input_spectra.freq                = freq;
input_spectra.plotchans           = plotchans;
input_spectra.plot_dir            = plot_dir;
% input_spectra.band_analysis       = band_analysis;
% input_spectra.chan_analysis       = chan_analysis;
input_spectra.list_band_lim =  list_band_lim;
input_spectra.list_band_name = list_band_name;

input_spectra.list_roi_ch =  list_roi_ch;
input_spectra.list_roi_name = list_roi_name;



input_spectra.scale               = scale;
input_spectra.plot_single_subject  = plot_single_subject;


% nn = 1;
file_output1 = fullfile(plot_dir,'spectra_allsub_roi.txt');
file_output2 = fullfile(plot_dir,'spectra_allsub_freqs_roi.txt');
file_output3 = fullfile(plot_dir,'spectra_allsub_ch.txt');
file_output4 = fullfile(plot_dir,'spectra_allsub_freqs_ch.txt');


fid1 = fopen(file_output1,'a+');
fid2 = fopen(file_output2,'a+');
fid3 = fopen(file_output3,'a+');
fid4 = fopen(file_output4,'a+');


fprintf(fid1,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','group','sub','sex','age_y','duration','roi','band','max_abs','max_rel','f_max');
fprintf(fid2,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n','group','sub','sex','age_y','duration','roi','freq','abs','rel');
fprintf(fid3,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','group','sub','sex','age_y','duration','ch','band','max_abs','max_rel','f_max');
fprintf(fid4,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n','group','sub','sex','age_y','duration','ch','freq','abs','rel');



for subj=1:numsubj
    
    subj_name   = list_select_subjects{subj};
    sel_sub = ismember({project.subjects.data.name}, subj_name);
    agesub=ageallsub(sel_sub);
    sexsub = sexallsub{sel_sub};
    groupsub = groupllsub{sel_sub};
    
    
    
    input_spectra.plot_label     = [subj_name, '_',groupsub,'_' ,num2str(agesub)];
    
    
    input_spectra.input_file_name   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    
    % ciclo su soggetti di funzione applicata a singolo soggetto che mi butta fuori i parametri necessari a comporre il cell array da esportare in txt per la statistica
    
    %         [names{subj},ranks{subj},ica_types{subj},durations{subj}, EEG]         = eeglab_subject_spectra(inputfile, project.paths.output_preprocessing, project.eegdata.eeg_channels_list, project.import.reference_channels, ica_type,do_pca,ica_sr);
    %            spectra_sub         = eeglab_subject_spectra(inputfile, project.paths.output_preprocessing, project.eegdata.eeg_channels_list, project.import.reference_channels, ica_type,do_pca,ica_sr);
    
    close all
    
    set(0,'DefaultFigureVisible','off')
    spectra_sub         = eeglab_subject_spectra(input_spectra);
    
    
    fname_outputmat = ['spectra_',subj_name, '.mat'];
    file_outputmat = fullfile(mat_dir,fname_outputmat);
    save(file_outputmat,'spectra_sub');
    
    
    troi = length(list_roi_name);
    tband = length(list_band_name);
    
    
    
    
    
    for nroi = 1:troi
        
        for nband = 1:tband
            
            fprintf(fid1,...
                '%s\t%s\t%s\t%d\t%d\t%s\t%s\t%d\t%d\t%d\n',...
                groupsub,...
                subj_name,...
                sexsub,...
                agesub,...
                spectra_sub.duration,...
                list_roi_name{nroi},...
                list_band_name{nband},...
                spectra_sub.roi(nroi).band(nband).masxp_abs,...
                spectra_sub.roi(nroi).band(nband).masxp_rel,...
                spectra_sub.roi(nroi).band(nband).fmaxsp...
                );
            
        end
        
        
        for nf = 1:length(spectra_sub.freqs)
            
            fprintf(fid2,...
                '%s\t%s\t%s\t%d\t%d\t%s\t%d\t%d\t%d\n',...
                groupsub,...
                subj_name,...
                sexsub,...
                agesub,...
                spectra_sub.duration,...
                list_roi_name{nroi},...
                spectra_sub.freqs(nf),...
                spectra_sub.roi(nroi).roispectra_abs(nf),...
                spectra_sub.roi(nroi).roispectra_rel(nf));
            
            
        end
        
    end
    
    tch = length(spectra_sub.ch);
    list_ch_name = {spectra_sub.ch.name};
    
    
    for nch = 1:tch
        
        for nband = 1:tband
            
            fprintf(fid3,...
                '%s\t%s\t%s\t%d\t%d\t%s\t%s\t%d\t%d\t%d\n',...
                groupsub,...
                subj_name,...
                sexsub,...
                agesub,...
                spectra_sub.duration,...
                list_ch_name{nch},...
                list_band_name{nband},...
                spectra_sub.ch(nch).band(nband).masxp_abs,...
                spectra_sub.ch(nch).band(nband).masxp_rel,...
                spectra_sub.ch(nch).band(nband).fmaxsp...
                );
            
        end
        
        
        for nf = 1:length(spectra_sub.freqs)
            
            fprintf(fid4,...
                '%s\t%s\t%s\t%d\t%d\t%s\t%d\t%d\t%d\n',...
                groupsub,...
                subj_name,...
                sexsub,...
                agesub,...
                spectra_sub.duration,...
                list_ch_name{nch},...
                spectra_sub.freqs(nf),...
                spectra_sub.ch(nch).chspectra_abs(nf),...
                spectra_sub.ch(nch).chspectra_rel(nf));
            
            
        end
        
    end
    
    
end

fclose(fid1);
fclose(fid2);
fclose(fid3);
fclose(fid4);

if (strcmp(project.preproc.subject_spectra.do_group,'on'))
    
    file_output5 = fullfile(plot_dir,'topo_group_age_bin.txt');
    fid5 = fopen(file_output5,'a+');
    
    for nband = 1:length(list_band_name)
        cell_spectra = cell(tg,tab);
        for ng=1:tg
            for nab = 1:tab
                sel_sub = ismember(project.subjects.list, list_select_subjects);
                sel_group  = ismember(groupllsub,groups(ng));
                sel_agebin =  ageallsub >= list_agebin_lim(nab,1) & ...
                    ageallsub < list_agebin_lim(nab,2);
                sel_global =  sel_sub & sel_group & sel_agebin;
                if sum(sel_global)
                    vsub = find(sel_global);
                    mat_spectra = [];
                    for nsub = 1:length(vsub)
                        indsub = vsub(nsub);
                        subj_name = project.subjects.list{indsub};
                        fname_outputmat = ['spectra_',subj_name, '.mat'];
                        file_outputmat = fullfile(mat_dir,fname_outputmat);
                        load(file_outputmat)
                        mat_spectra(:,nsub) = spectra_sub.band(nband).rel_spectra;
                    end
                    cell_spectra{ng,nab} = mat_spectra;
                end
                %             topoplot(spectra_sub.band(1).rel_spectra,spectra_sub.chanlocs)
            end
            
        end
        group_spectra.band(nband).cell_spectra = cell_spectra;
        group_spectra.band(nband).band_name = list_band_name(nband);
        
    end
    
    group_spectra.chanlocs = spectra_sub.chanlocs;
    fname_outputcell = ['group_spectra', '.mat'];
    file_outputcell = fullfile(mat_dir,fname_outputcell);
    save(file_outputcell,'group_spectra')
    
    close all
    
    all_ch = {spectra_sub.chanlocs.labels};
    sel_roi_ch = ismember(all_ch,list_allroi_ch);
    
    %% confornto consideando tutti i canali
    %% confronto age bin within gruppi
    
    if tab > 1
        for nband = 1:length(list_band_name)
            
            % blocco il gruppo e confronto i bin di et�
            for ng = 1:tg
                %         combinazioni di tutti i bin di et� a 2 a 2
                comb_ab = nchoosek(1:tab,2);
                %         fig = figure;
                
                
                for ncomb_ab = 1:size(comb_ab,1)
                    
                    str_comp = [list_agebin_name{comb_ab(ncomb_ab,2)},'-',list_agebin_name{comb_ab(ncomb_ab,1)} ];
                    
                    fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
                    
                    
                    
                    cell4stat = group_spectra.band(nband).cell_spectra(ng,comb_ab(ncomb_ab,:));
                    %             [t, df, pvals_raw] = statcond(cell4stat);
                    [stat, df, pvals_raw] = statcond_corr(cell4stat, project.stats.ersp.num_tails, 'alpha',NaN,...
                        'naccu',project.stats.ersp.num_permutations,'method', project.stats.eeglab.ersp.method);
                    
                    pvals = mcorrect(pvals_raw,  project.stats.eeglab.ersp.correction);
                    
                    %             [t, df, pvals] = statcond(cell4stat);
                    vmean2 = nan(2,length(pvals));
                    for ncs = 1:length(cell4stat)
                        sel_ind = comb_ab(ncomb_ab,ncs);
                        vmean = mean(group_spectra.band(nband).cell_spectra{ng,sel_ind},2);
                        if not(isempty(vmean))
                            vmean2(ncs,:) = vmean;
                            subplot(1, 4, ncs);
                            if isempty(set_caxis)
                                topoplot(vmean, spectra_sub.chanlocs);
                            else
                                topoplot(vmean, spectra_sub.chanlocs,'maplimits',set_caxis(nband,:));
                            end
                            title(list_agebin_name(sel_ind))
                            cbar;
                            title('rel_power %')
                        end
                    end
                    
                    
                    if sum(isnan(pvals)) == 0
                        psig = pvals<project.stats.ersp.pvalue;
                        all_ch = {spectra_sub.chanlocs.labels};
                        sig_ch = all_ch(psig);
                        
                        
                        differ = diff(vmean2,1)';
                        if sum(isnan(differ)) == 0
                            subplot(1, 4, ncs+1);
                            if isempty(set_caxis)
                                topoplot(psig.*differ, spectra_sub.chanlocs);
                            else
                                topoplot(psig.*differ, spectra_sub.chanlocs,'maplimits',set_caxis(nband,:));
                            end
                            title({'significant differences',str_comp});
                            
                            cbar;
                            title('delta %')
                            
                            subplot(1, 4, ncs+2);
                            topoplot(psig, spectra_sub.chanlocs,'style','blank','emarker','r');
                            title('different channels');
                            
                        end
                    end
                    %             str_comp = [list_agebin_name{comb_ab(ncomb_ab,1)},'_',list_agebin_name{comb_ab(ncomb_ab,2)} ];
                    str_plot = [list_band_name{nband},'_', groups{ng}, '_',str_comp];
                    suptitle2(str_plot);
                    group_spectra.band(nband).group(ng).comparison(ncomb_ab).str_comp = str_comp;
                    group_spectra.band(nband).group(ng).comparison(ncomb_ab).sig_ch = sig_ch;
                    group_spectra.band(nband).group(ng).comparison(ncomb_ab).str_plot = str_plot;
                    
                    fprintf(fid5,'%s\n',str_plot);
                    fprintf(fid5,[repmat('%s\t',1,length(sig_ch)),'\n'],sig_ch{:});
                    
                    inputsf.plot_dir    = plot_dir_group_allch;
                    inputsf.fig         = fig;
                    inputsf.name_embed  = 'group_spectra_map';
                    inputsf.suffix_plot = str_plot;
                    save_figures(inputsf,'res','-r100','exclude_format','svg');
                end
            end
        end
    end
    %% confronto gruppi within age bin
    if tg > 1
        for nband = 1:length(list_band_name)
            
            % blocco il gruppo e confronto i bin di et�
            for nab = 1:tab
                %         combinazioni di tutti i gruppi a 2 a 2
                comb_g = nchoosek(1:tg,2);
                for ncomb_g = 1:size(comb_g,1)
                    str_comp = [groups{comb_g(ncomb_g,2)},'-',groups{comb_g(ncomb_g,1)} ];
                    
                    fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
                    
                    cell4stat = group_spectra.band(nband).cell_spectra(comb_ab(ncomb_g,:),nab);
                    %             [t, df, pvals] = statcond(cell4stat);
                    [stat, df, pvals_raw] = statcond_corr(cell4stat, project.stats.ersp.num_tails, 'alpha',NaN,...
                        'naccu',project.stats.ersp.num_permutations,'method', project.stats.eeglab.ersp.method);
                    
                    pvals = mcorrect(pvals_raw,  project.stats.eeglab.ersp.correction);
                    vmean2 = nan(2,length(pvals));
                    for ncs = 1:length(cell4stat)
                        sel_ind = comb_g(ncomb_g,ncs);
                        vmean = mean(group_spectra.band(nband).cell_spectra{sel_ind, nab},2);
                        if not(isempty(vmean))
                            vmean2(ncs,:) = vmean;
                            subplot(1, 4, ncs);
                            if isempty(set_caxis)
                                topoplot(vmean, spectra_sub.chanlocs);
                            else
                                topoplot(vmean, spectra_sub.chanlocs,'maplimits',set_caxis(nband,:));
                            end
                            title(groups(sel_ind))
                            cbar;
                            title('rel_power %')
                        end
                    end
                    
                    
                    if sum(isnan(pvals)) == 0
                        psig = pvals<project.stats.ersp.pvalue;
                        all_ch = {spectra_sub.chanlocs.labels};
                        sig_ch = all_ch(psig);
                        
                        differ = diff(vmean2,1)';
                        if sum(isnan(differ)) == 0
                            subplot(1, 4, ncs+1);
                            if isempty(set_caxis)
                                topoplot(psig.*differ, spectra_sub.chanlocs);
                            else
                                topoplot(psig.*differ, spectra_sub.chanlocs,'maplimits',set_caxis(nband,:));
                            end
                            title({'significant differences',str_comp});
                            
                            cbar;
                            title('delta %')
                            
                            subplot(1, 4, ncs+2);
                            topoplot(psig, spectra_sub.chanlocs,'style','blank','emarker','r');
                            title('different channels');
                            
                        end
                    end
                    str_plot = [list_band_name{nband},'_', list_agebin_name{nab}, '_',str_comp];
                    suptitle2(str_plot);
                    
                    group_spectra.band(nband).age_bin(nab).comparison(ncomb_g).str_comp = str_comp;
                    group_spectra.band(nband).age_bin(nab).comparison(ncomb_g).sig_ch = sig_ch;
                    group_spectra.band(nband).age_bin(nab).comparison(ncomb_g).str_plot = str_plot;
                    fprintf(fid5,'%s\n',str_plot);
                    fprintf(fid5,[repmat('%s\t',1,length(sig_ch)),'\n'],sig_ch{:});
                    
                    inputsf.plot_dir    = plot_dir_group_allch;
                    inputsf.fig         = fig;
                    inputsf.name_embed  = 'group_spectra_map';
                    inputsf.suffix_plot = str_plot;
                    save_figures(inputsf,'res','-r100','exclude_format','svg');
                end
            end
        end
    end
    %% confronto considerando solo i canali delle roi
    %% confronto age bin within gruppi
    if tab > 1
        for nband = 1:length(list_band_name)
            
            % blocco il gruppo e confronto i bin di et�
            for ng = 1:tg
                %         combinazioni di tutti i bin di et� a 2 a 2
                comb_ab = nchoosek(1:tab,2);
                %         fig = figure;
                
                
                for ncomb_ab = 1:size(comb_ab,1)
                    
                    str_comp = [list_agebin_name{comb_ab(ncomb_ab,2)},'-',list_agebin_name{comb_ab(ncomb_ab,1)} ];
                    
                    fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
                    
                    
                    
                    cell4stat = group_spectra.band(nband).cell_spectra(ng,comb_ab(ncomb_ab,:));
                    %             [t, df, pvals_raw] = statcond(cell4stat);
                    [stat, df, pvals_raw] = statcond_corr(cell4stat, project.stats.ersp.num_tails, 'alpha',NaN,...
                        'naccu',project.stats.ersp.num_permutations,'method', project.stats.eeglab.ersp.method);
                    pvals_raw_roi = pvals_raw(sel_roi_ch);
                    pvals_roi = mcorrect(pvals_raw_roi,  project.stats.eeglab.ersp.correction);
                    pvals = ones(size(pvals_raw));
                    pvals(sel_roi_ch) = pvals_roi;
                    
                    %             [t, df, pvals] = statcond(cell4stat);
                    vmean2 = nan(2,length(pvals));
                    for ncs = 1:length(cell4stat)
                        sel_ind = comb_ab(ncomb_ab,ncs);
                        vmean = mean(group_spectra.band(nband).cell_spectra{ng,sel_ind},2);
                        if not(isempty(vmean))
                            vmean2(ncs,:) = vmean;
                            subplot(1, 4, ncs);
                            if isempty(set_caxis)
                                topoplot(vmean, spectra_sub.chanlocs);
                            else
                                topoplot(vmean, spectra_sub.chanlocs,'maplimits',set_caxis(nband,:));
                            end
                            title(list_agebin_name(sel_ind))
                            cbar;
                            title('rel_power %')
                        end
                    end
                    
                    
                    if sum(isnan(pvals)) == 0
                        psig = pvals<project.stats.ersp.pvalue;
                        all_ch = {spectra_sub.chanlocs.labels};
                        sig_ch = all_ch(psig);
                        
                        
                        differ = diff(vmean2,1)';
                        if sum(isnan(differ)) == 0
                            subplot(1, 4, ncs+1);
                            if isempty(set_caxis)
                                topoplot(psig.*differ, spectra_sub.chanlocs);
                            else
                                topoplot(psig.*differ, spectra_sub.chanlocs,'maplimits',set_caxis(nband,:));
                            end
                            title({'significant differences',str_comp});
                            
                            cbar;
                            title('delta %')
                            
                            subplot(1, 4, ncs+2);
                            topoplot(psig, spectra_sub.chanlocs,'style','blank','emarker','r');
                            title('different channels');
                            
                        end
                    end
                    %             str_comp = [list_agebin_name{comb_ab(ncomb_ab,1)},'_',list_agebin_name{comb_ab(ncomb_ab,2)} ];
                    str_plot = [list_band_name{nband},'_', groups{ng}, '_',str_comp];
                    suptitle2(str_plot);
                    group_spectra.band(nband).group(ng).comparison(ncomb_ab).str_comp = str_comp;
                    group_spectra.band(nband).group(ng).comparison(ncomb_ab).sig_ch = sig_ch;
                    group_spectra.band(nband).group(ng).comparison(ncomb_ab).str_plot = str_plot;
                    
                    fprintf(fid5,'%s\n',str_plot);
                    fprintf(fid5,[repmat('%s\t',1,length(sig_ch)),'\n'],sig_ch{:});
                    
                    inputsf.plot_dir    = plot_dir_group_allroi;
                    inputsf.fig         = fig;
                    inputsf.name_embed  = 'group_spectra_map';
                    inputsf.suffix_plot = str_plot;
                    save_figures(inputsf,'res','-r100','exclude_format','svg');
                end
            end
        end
    end
    %% confronto gruppi within age bin
    if tg > 1
        for nband = 1:length(list_band_name)
            
            % blocco il gruppo e confronto i bin di et�
            for nab = 1:tab
                %         combinazioni di tutti i gruppi a 2 a 2
                comb_g = nchoosek(1:tg,2);
                for ncomb_g = 1:size(comb_g,1)
                    str_comp = [groups{comb_g(ncomb_g,2)},'-',groups{comb_g(ncomb_g,1)} ];
                    
                    fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
                    
                    cell4stat = group_spectra.band(nband).cell_spectra(comb_ab(ncomb_g,:),nab);
                    %             [t, df, pvals] = statcond(cell4stat);
                    [stat, df, pvals_raw] = statcond_corr(cell4stat, project.stats.ersp.num_tails, 'alpha',NaN,...
                        'naccu',project.stats.ersp.num_permutations,'method', project.stats.eeglab.ersp.method);
                    
                    pvals_raw_roi = pvals_raw(sel_roi_ch);
                    pvals_roi = mcorrect(pvals_raw_roi,  project.stats.eeglab.ersp.correction);
                    pvals = ones(size(pvals_raw));
                    pvals(sel_roi_ch) = pvals_roi;
                    
                    vmean2 = nan(2,length(pvals));
                    for ncs = 1:length(cell4stat)
                        sel_ind = comb_g(ncomb_g,ncs);
                        vmean = mean(group_spectra.band(nband).cell_spectra{sel_ind, nab},2);
                        if not(isempty(vmean))
                            vmean2(ncs,:) = vmean;
                            subplot(1, 4, ncs);
                            if isempty(set_caxis)
                                topoplot(vmean, spectra_sub.chanlocs);
                            else
                                topoplot(vmean, spectra_sub.chanlocs,'maplimits',set_caxis(nband,:));
                            end
                            title(groups(sel_ind))
                            cbar;
                            title('rel_power %')
                        end
                    end
                    
                    
                    if sum(isnan(pvals)) == 0
                        psig = pvals<project.stats.ersp.pvalue;
                        all_ch = {spectra_sub.chanlocs.labels};
                        sig_ch = all_ch(psig);
                        
                        differ = diff(vmean2,1)';
                        if sum(isnan(differ)) == 0
                            subplot(1, 4, ncs+1);
                            if isempty(set_caxis)
                                topoplot(psig.*differ, spectra_sub.chanlocs);
                            else
                                topoplot(psig.*differ, spectra_sub.chanlocs,'maplimits',set_caxis(nband,:));
                            end
                            title({'significant differences',str_comp});
                            
                            cbar;
                            title('delta %')
                            
                            subplot(1, 4, ncs+2);
                            topoplot(psig, spectra_sub.chanlocs,'style','blank','emarker','r');
                            title('different channels');
                            
                        end
                    end
                    str_plot = [list_band_name{nband},'_', list_agebin_name{nab}, '_',str_comp];
                    suptitle2(str_plot);
                    
                    group_spectra.band(nband).age_bin(nab).comparison(ncomb_g).str_comp = str_comp;
                    group_spectra.band(nband).age_bin(nab).comparison(ncomb_g).sig_ch = sig_ch;
                    group_spectra.band(nband).age_bin(nab).comparison(ncomb_g).str_plot = str_plot;
                    fprintf(fid5,'%s\n',str_plot);
                    fprintf(fid5,[repmat('%s\t',1,length(sig_ch)),'\n'],sig_ch{:});
                    
                    inputsf.plot_dir    = plot_dir_group_allroi;
                    inputsf.fig         = fig;
                    inputsf.name_embed  = 'group_spectra_map';
                    inputsf.suffix_plot = str_plot;
                    save_figures(inputsf,'res','-r100','exclude_format','svg');
                end
            end
        end
        
    end
    
    
    
    
    save(file_outputcell,'group_spectra')
    
    fclose(fid5);
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
