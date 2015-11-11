function eeglab_subject_tf_plot_2conditions(input_set1, input_set2, ch_label, varargin) .... pvalue, save_fig, fig_output_path)

    [path1,name_noext1,ext1] = fileparts(input_set1);
    [path2,name_noext2,ext2] = fileparts(input_set2);
    
    EEG1 = pop_loadset('filename', {[name_noext1 ext1] }, 'filepath', path1);
    EEG2 = pop_loadset('filename', {[name_noext2 ext2] }, 'filepath', path2);

    chanlist={EEG1(1).chanlocs.labels};
    chan_num=find(strcmp(ch_label,chanlist));
    srate=EEG1(1).srate;
    pnt=EEG1(1).pnts;
    xmin=EEG1(1).xmin;
    xmax=EEG1(1).xmax;    
    
    % default values
    pvalue = 0.05;
    save_fig=0;
    fig_output_path='';
    baseline=[xmin 0]*1000; ...i need it in milliseconds

    options_num=size(varargin,2);
    opt=1;
    
    while options_num>0
        switch varargin{opt}
            case 'pvalue'
                opt=opt+1;
                pvalue=varargin{opt};                  
            case 'baseline'
                opt=opt+1;
                baseline=varargin{opt};
            case 'save_fig'
                opt=opt+1;
                save_fig=varargin{opt};              
            case 'fig_output_path'
                opt=opt+1;
                fig_output_path=varargin{opt};
        end
        opt=opt+1;
        options_num=options_num-2;
    end
    %-------------------------------------------------------------------------------------------------------
    set(0,'DefaultTextInterpreter','none');
    title_name=[name_noext1 '_vs_' name_noext2 '_' ch_label];
    ...fig=figure()
    [ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef({EEG1.data(chan_num,:,:) EEG2.data(chan_num,:,:)} ,pnt, [xmin xmax]*1000, srate, 0, 'alpha', pvalue,'plotitc', 'off', 'erspmax',4, 'baseline', baseline,'trialbase','full');
    suptitle(title_name);
    if save_fig
        hfig=gcf();
        output_file=fullfile(fig_output_path, [title_name '.jpg']);
        saveas(hfig,output_file,'jpg')
    end
    clear EEG
end    