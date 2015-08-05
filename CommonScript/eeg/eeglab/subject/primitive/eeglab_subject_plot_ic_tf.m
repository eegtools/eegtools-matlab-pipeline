function eeglab_subject_plot_ic_tf(input_file_name, output_result_path, baseline, freq_interval, subepochs_limits, varargin)

    % -------------------------------------------------------------------------------------------------------------------------------------------------
    % varargin defaults
    timesout_step           = 20;
    padratio                = 128;
    %-------------------------------------------------------------------------------------------------------------------------------------------------
    for par=1:2:length(varargin)
        switch varargin{par}
            case {'timesout_step', 'padratio'}
                if isempty(varargin{par+1})
                    continue;
                else
                    assign(varargin{par}, varargin{par+1});
                end                
        end
    end    
    %-------------------------------------------------------------------------------------------------------------------------------------------------
    [path,name_noext,ext]   = fileparts(input_file_name);
    EEG                     = pop_loadset(input_file_name);
    output_file_name        = fullfile(output_result_path, [name_noext '_' datestr(now,'dd-mmm-yyyy-HH-MM-SS')]);


    for n=1: size(EEG.icawinv ,2)
        fig=figure;
        pop_newtimef( EEG, 0, n, subepochs_limits, [0] , 'topovec', EEG.icawinv(:,n), 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', ['IC ', num2str(n)], 'baseline', baseline, 'plotphase', 'off', ...
            'padratio', padratio,'freqs',freq_interval,'timesout',subepochs_limits(1):timesout_step:subepochs_limits(2));
        print(fig, output_file_name, '-append');
        close(fig);
    end
    %-------------------------------------------------------------------------------------------------------------------------------------------------
end