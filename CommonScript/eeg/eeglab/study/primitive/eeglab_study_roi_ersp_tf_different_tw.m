function onset_offset = eeglab_study_roi_ersp_tf_different_tw(params,  varargin)
%% compare ersp time frequency distributions of different cells of a design (levels of factor 1 and factor 2, as for standard EEGLab computing), but allow different time window for different cells of the design.
% time windows of different cells are differnt but have must all the same
% length.
% it is assumed that, for each subject and cell of tyhe design. input_filename = [sub_list{nsub},common_string,str_f2{nf2},str_f1{nf1},'.set'];
%
%% extract the parameters form the input structure

name_f1             = params.name_f1;                                      % string. the name of factor 1
name_f2             = params.name_f2;                                      % string. the name of factor 2

levels_f1           = params.levels_f1;                                    % cell array of strings. levels of factor 1
levels_f2           = params.levels_f2;                                    % cell array of strings. levels of factor 2

str_f1              = params.str_f1;                                       % string. denotes the levels of factor 1 in the file names
str_f2              = params.str_f2;                                       % string. denotes the levels of factor 2 in the file names

ersp_limits         = params.ersp_limits;                                  % vector [min, max]. limits for the ERSP scale in the plots
p_limits            = params.p_limits;                                     % vector [min, max]. limits for the p value scale in the plots

sub_list            = params.sub_list;                                     % cell array of strings. list of subject names

common_string       = params.common_string;                                % string. is a common part of all file names

input_filepath      = params.input_filepath;                               % string. folder with all the data (and where the results will be saved)

roi_list            = params.roi_list;                                     % nested cell array of strings. each element is a cell array of strings with the names of the corresponding channels.
roi_names           = params.roi_names;                                    % cell array of strings. each element is a name of a roi it must have the same length of roi_list.


tw_baseline_cell    = params.tw_baseline_cell;                             % cell array with the baseline limits (i.e. min and max times in ms) for
%                                                                                  each level of factor 1 (i.e. row) and each level of factor 2 (i.e. column)

step_ms             = params.step_ms;                                      % number. set the step of each sliding window used to calculate ERSP (it will be
%                                                                               the time resolution in ms of the time -frequency decomposition), if empy, 10 (ms)


tw_epoch_cell       = params.tw_epoch_cell;                                % cell array with the epoch limits (i.e. min and max times in ms) for
%                                                                                   each level of factor 1 (i.e. row) and each level of factor 2 (i.e. column)

pvalue              = params.pvalue;                                       % number. set a significance threshold (after the chosen correction for multiple comparisons)

correction          = params.correction;                                   % string. set the method for multiple comparisons correction. order of stricntess: fdr < holms < bonferrroni

num_permutations    = params.num_permutations;                             % number. number of permutations. if empty, 10000

freq_vec            = params.freq_vec;                                      % vector. vector of frequencies of the time frequency decomposition. if empty, [3:1:35], i.e. from 3 to 35 Hz with 1 Hz resolution 



if isempty(step_ms)
    step_ms = 10;
end


if isempty(num_permutations)
    num_permutations = 10000;
end


if isempty(freq_vec)
    freq_vec = 3:35;
end



% number: total levels of each factor
tf1           = length(levels_f1);
tf2           = length(levels_f2);

% total number of subjects
tsub =length(sub_list);

% total number of channels to be processed
tch=length(num_chan_vec);

% total number of roi
troi = length(roi_names);



% intialize a cell array with the ERSP data (matrix of dimension
% frequencies x times). The cell array has 3 dimensions:
% first is the level of factor 1;
% second is the level of factor 2;
% third is the channel
% so it is a cell array of dimension: (total levels of factor 1)  x (total
% levels of factor 2) x (total number of channels)
ersp_cell = cell(tf1,tf2,tch);


% cell array with the time points vector used to compute the ERSP (i.e.
% ERSP points will be computed and saved at these times)
% for each level of factor 1 (i.e. row) and each level of factor 2 (i.e. column)

times_epoch_cell = cell(tf1,tf2);
for nf1 = 1:tf1
    
    % for each level of factor 2
    for nf2 = 1:tf2
        t1 = min(times_epoch_cell{nf1,nf2});
        t2 = max(times_epoch_cell{nf1,nf2});
        times_epoch_cell{nf1,nf2} = [t1:step_ms:t2];
    end
end





% initialize a cell array with the time vectors corresponding to the first
% and to the second level of factor 1, it is used to plot and compare different time windows (for different conddition, e.g pre- violation and vilation)
times_cell=cell(tf1,tf2);

% for each roi
for nroi = 1:troi
    
    % for each level of factor 1
    for nf1 = 1:tf1
        
        % for each level of factor 2
        for nf2 = 1:tf2
            
            % for each subject
            for nsub = 1:length(sub_list)
                
                % build the string with the name of the file to be loaded and
                % porcessed
                input_filename = [sub_list{nsub},common_string,str_f2{nf2},str_f1{nf1},'.set'];
                
                % load the file
                EEG = pop_loadset('filename',input_filename,'filepath',input_filepath);
                
                % check consistency
                EEG = eeg_checkset( EEG );
                
                all_ch = EEG.chanlocs.labels;
                
                num_chan_vec = find(ismember(all_ch,roi_list{nroi}));               
                tch_roi =length(num_chan_vec);
                
                ersp_cell_roi = cell(tch_roi);
                
                % for each channel
                for nch = 1:length(tch_roi)
                    
                    % set the number of channel to process
                    topovec = num_chan_vec(nch);
                    
                    % set the corresponding lavbel
                    ch_lab = EEG.chanlocs(topovec).labels;
                    
                    % open a figure called fig and kept invisible (to avoid
                    % thrash)
                    fig=figure('visible','off');
                    
                    % set the epoch for the selected level of factor 1 and
                    % factor 2
                    epoch = times_epoch_cell{nf1,nf2};
                    
                    %                 
                    
                    % compute the ersp, the time vector and the frequency vector for the selected level of factor 1, level of factor 2, subject and channel
                    [ersp_cell_roi{nch},itc,powbase,times,freqs,erspboot,itcboot] = ...
                        pop_newtimef( EEG , 1 , topovec , [min(epoch), max(epoch)], [0] , ...
                        'topovec', topovec , 'elocs', EEG.chanlocs ,'chaninfo', EEG.chaninfo,...
                        'caption', ch_lab ,'baseline',tw_baseline_cell{nf1,nf2} ,'freqs',  freq_vec ,...
                        'timesout', times_epoch_cell{nf1,nf2} ,'padratio', 64 ,'winsize',100);
                    
                    % close the figure with the ERSP plot
                    close(fig);
                    
                    % save the ERSP in the global cell array which was
                    % initilaized before
                    % hoocked parenthesis indicate that we are filling the
                    % element corresponding to a certain level fo fatcor 1
                    % (nf1), a certain level of factor 2 (nf2) and a certain
                    % channel (nch).
                    
                    % round parenthesis indicate that the current element o the
                    % cell array is a an array with dimensions : times  x
                    % frequencies x subjects: mow we are filling the portion
                    % dedicated to the current subject (nsub)
                                        
                end
                
                dim = ndims(ersp_cell_roi{1});          %# Get the number of dimensions for your arrays
                M = cat(dim+1,ersp_cell_roi{:});        %# Convert to a (dim+1)-dimensional matrix
                mean_ersp_roi = mean(ersp_cell_roi,dim+1);  %# Get the mean across arrays
                
                ersp_cell{nf1,nf2,nroi}(:,:,nsub)=mean_ersp_roi;
                
            end
            
            % save the time vector for the plot for the current levels of factor 1 and 2
            times_cell{nf1,nf2}=times;
        end
        
    end
    
    
    
    %%%%%%% plotting
    
    % for each roi
    for nch =1:troi
        
        % calculate statics for the comparisons between  levels of factor 1
        % (code by EEGLab as 'condstats') , between the levels of factor 2
        % (coded by EEGLab as 'groupstats') and for the intercations
        
        
        % pcond is a cell array with the matrices of p values corresponding to
        % the comparisons of rows (i.e. levels of factor 1) for each columns
        
        % pgroup is a cell array with the matrices of p values corresponding to
        % the comparisons of columns (i.e. levels of factor 2) for each row
        
        % pinter is a cell array of 3 elements:
        % the first is the pvalues comparing rows (without distinguishing
        % columns)
        % the second is the pvalues comparing columns (without distinguishing
        % rows)%
        % the third is the pvaues of the intercation in the usual sense
        % paired set the pairing of comparison for each factor
        
        
        % get the label of the current processed channel
        roi_label = roi_names{nroi};
        
        
        [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
            std_stat_corr(ersp_cell(:,:,nroi),2,'groupstats','on','condstats','on','paired',{'on','on'},'method','bootstrap', 'naccu',200, 'mcorrect',correction);
        
        % for each channel (nch), fill a cell array with both the ERSP values of each level of factor 1
        % and 2 AND the pvalues of the comparisons
        
        all_cell = [[ersp_cell(:,:,nroi);pcond],[pgroup';pinter(3)]];
        
        % save the number of rows (tr) and columns (tc) of the cell array to
        % plot
        [tr,tc]=size(all_cell);
        
        % open an invisible figure
        fig=figure('visible','off');
        
        % initialize the number of sub-plot
        nsp=1;
        
        % for each row of the subplot
        for nr = 1:tr
            
            % for each culumn of the subplot
            for nc= 1:tc
                
                % check the size o the data to plot:
                % ERSP data has 3 dimension: frequencies x times x subject
                % INSTEAD, p values data has only 2 dimensions: frequencies x times (no subject)
                
                ss=length(size(all_cell{nr,nc}));
                
                
                % if the number of dimensions is 3 (I know that we are plotting
                % ERSP data)
                if ss==3
                    
                    % calculate the averege ERSP between subjects
                    data_subplot = mean(all_cell{nr,nc},3);
                    
                    % set the color limits of ERSP
                    plot_limits =ersp_limits;
                    
                    % set the title of the ERSP (current level of factor 1, of
                    % factor 2. The title is a string: we concatenate the level
                    % of factor 1 with the level of factor 2. In between we put
                    % a comma as a string to make it easy to read (it's a
                    % a separator label)
                    
                    title_plot = char([roi_label, ': ',levels_f1{nr} ,',',levels_f2{nc}]);
                    
                    % set the time vector of ERSP computed in the current vel of factor 1 and of
                    % factor 2
                    time_vec = times_cell{nr};
                    
                    
                    % if the number of dimensions is 2 (I know that we are plotting
                    % p values)
                else
                    % aplly the significance threshold: values < threshold are
                    % set to true; values > threshold are set to false
                    % convert the data from logical (i.e. true/false values) to
                    % numeric by adding a 0
                    data_subplot = (all_cell{nr,nc}<pvalue)+0;
                    
                    % set the color limits for p values
                    plot_limits =p_limits;
                    
                    % set the title for p values:
                    % the string is made concatenating P< and the selected
                    % thresold. The selected thresold is a NUMBER: before it
                    % can be concatenated to a STRING it must be converted to a
                    % string by num2str function
                    title_plot =['P < ',num2str(sig_th)];
                    
                    % for p values we don't know a priory what time window we
                    % are comparing and possibly we are comparing different
                    % time windows, so we cannot use one or the other time
                    % window to plot, insead we plot using a vector from 1 to
                    % the total amount of time points (which is the same for
                    % all time windows)
                    time_vec = 1:size(data_subplot,2);
                end
                
                % create the current sub-plot: in a matrix of tr rows and tc
                % colums of subplots we are working on the nsp suplot
                subplot(tr,tc,nsp)
                
                % plot the matrix (either of the averaged ERPS or p values)
                imagesc(time_vec,freqs,data_subplot,plot_limits);
                
                % set the axis of frequencies, the vertical in an incrasing
                % direction
                set(gca,'YDir','normal');
                
                % set the tite
                title(title_plot);
                
                % if we are plotting the first subplot (first column and first
                % row, then print also axis labels for the horizontal and the
                % vertical axes)
                if nr ==1 && nc ==1
                    xlabel('Time (ms)'); ylabel('Frequencies (Hz)');
                end
                
                % go to the next subplot
                nsp=nsp+1;
            end
        end
        
        % add the colorbar and it's title label
        cbar;title('dB')
        
        
        
        
        % add a global (supreme) title for the whole figure, which is the name
        % of the channel
        suptitle( roi_label)
        
        % buld the string used to save results in a mat file and in plots
        % results will be placed in the FFT subfolder of the folder with the
        % processed data
        results_name = fullfile(input_filepath,'FFT',['results_FFT_', roi_label]);
        
        % graphical stuff, makes the figure better in LINUX environment
        set(fig, 'renderer', 'painter')
        
        % save the figure as a matlab fif file
        saveas(fig, [results_name,'.fig']);
        
        % save the figure in encapsulated postscript format with a 300 dpi
        % resolution
        print([results_name,'.eps'],'-depsc2','-r300');
        
        % save the figure in tif (same resolution)
        print([results_name,'.tiff'],'-dtiff','-r300');
        
        % save also in another vectorial format
        plot2svg([results_name,'.svg'])
        
        % save the data of each plot (i.e. of each channel) in a separated
        % malab mat file
        save([results_name,'.mat'],'all_cell')
        
        % close the figure fig
        close(fig);
    end
    
end

end

