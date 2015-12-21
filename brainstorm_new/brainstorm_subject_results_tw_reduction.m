%% brainstorm_subject_results_tw_reduction(input_data_file, output_data_file, tw_limits, write_mode)

% tw_limits: cell array containing the start and end timepoint of each tw:  {[tw1_st tw1_end],[tw2_st tw2_end],[tw3_st tw3_end]}
% write_mode:   "average"   write one mean timepoint for each input tw
%               "all"       write all the timepoint contained within the tw


%%
function brainstorm_subject_results_tw_reduction(input_data_file, sec_tw_limits, write_mode, output_data_postfix)

    if nargin < 1
        help brainstorm_subject_results_tw_reduction;
    end
    if nargin < 4
        output_data_postfix = '';
    end
    if nargin < 3
        write_mode          = 'average';
    end
    

    % load source file
    [inpath, inname, inext]     = fileparts(input_data_file);
    input_result                = load(input_data_file);

    n_tw                        = length(sec_tw_limits);
    n_src                       = size(input_result.ImageGridAmp, 1);
    
    time_start                  = input_result.Time(1);
    time_step                   = input_result.Time(2) - input_result.Time(1);
    
    tp_tw_limits                = cell(1, n_tw);
    for tw=1:n_tw
        tp_tw_limits{tw}(1)     = (sec_tw_limits{tw}(1) - time_start)/time_step;
        tp_tw_limits{tw}(2)     = (sec_tw_limits{tw}(2) - time_start)/time_step;
    end
    
    % load original datafile
    original_data_file          = input_result.DataFile;
    data_file                   = load(file_fullpath(original_data_file)); 
    n_ch                        = size(data_file.F, 1);
     
    %% calculate reduced amplitudes
    switch write_mode
        
        case 'average'
            tot_tp                  = n_tw;
            new_data_f              = zeros(n_ch, tot_tp);
            new_sources             = zeros(n_src, tot_tp);
            for tw=1:n_tw
                new_data_f(:,tw)    = mean(data_file.F(:, round([tp_tw_limits{tw}(1):tp_tw_limits{tw}(2)])),2);
                new_sources(:,tw)   = mean(input_result.ImageGridAmp(:, round([tp_tw_limits{tw}(1):tp_tw_limits{tw}(2)])),2);
            end
            
            if tot_tp == 1 
                new_data_f(:,2)     = new_data_f(:,1);
                new_sources(:,2)    = new_sources(:,1);
                tot_tp              = 2;
            end

        case 'average_abs'
            tot_tp                  = n_tw;
            new_data_f              = zeros(n_ch, tot_tp);
            new_sources             = zeros(n_src, tot_tp);
            for tw=1:n_tw
                new_data_f(:,tw)    = mean(data_file.F(:, round([tp_tw_limits{tw}(1):tp_tw_limits{tw}(2)])),2);
                new_sources(:,tw)   = mean(abs(input_result.ImageGridAmp(:, round([tp_tw_limits{tw}(1):tp_tw_limits{tw}(2)])),2));
            end
            
            if tot_tp == 1 
                new_data_f(:,2)     = new_data_f(:,1);
                new_sources(:,2)    = new_sources(:,1);
                tot_tp              = 2;
            end

        case 'all'
            tot_tp                  = 0;
            curr_tw_end             = cell(1, n_tw);
            curr_tw_end{1}          = length([tp_tw_limits{1}(1):tp_tw_limits{1}(2)]);
            for tw=2:n_tw
                curr_tw_end{tw}     = curr_tw_end{tw-1} + length([tp_tw_limits{tw}(1):tp_tw_limits{tw}(2)]);
            end
            tot_tp                  = curr_tw_end{end};
            
            new_sources             = zeros(n_src, tot_tp);
            new_data_f              = zeros(n_ch, tot_tp);

            new_data_f(:,1:curr_tw_end{1})    = data_file.F(:, round([tp_tw_limits{1}(1):tp_tw_limits{1}(2)]));
            new_sources(:,1:curr_tw_end{1})   = input_result.ImageGridAmp(:, round([tp_tw_limits{1}(1):tp_tw_limits{1}(2)]));
            
            
            for tw=2:n_tw
                new_data_f(:,(curr_tw_end{tw-1}+1):curr_tw_end{tw})    = data_file.F(:, round([tp_tw_limits{tw}(1):tp_tw_limits{tw}(2)]));
                new_sources(:,(curr_tw_end{tw-1}+1):curr_tw_end{tw})   = input_result.ImageGridAmp(:, round([tp_tw_limits{tw}(1):tp_tw_limits{tw}(2)]));
            end

            
%             if n_tw > 1
%                 for tw=1:n_tw-1
%                     new_data_f(:,(num_prev_tp{tw}+1):num_prev_tp{tw+1})    = data_file.F(:, round(num_prev_tp{tw}+[tp_tw_limits{tw}(1):tp_tw_limits{tw}(2)]));
%                     new_sources(:,(num_prev_tp{tw}+1):num_prev_tp{tw+1})   = input_result.ImageGridAmp(:, round(num_prev_tp{tw}+[tp_tw_limits{tw}(1):tp_tw_limits{tw}(2)]));
%                 end
%                 keyboard
%                 new_data_f(:,(num_prev_tp{tw+1}+1):tot_tp)    = data_file.F(:, round(num_prev_tp{tw+1}+[tp_tw_limits{tw+1}(1):tp_tw_limits{tw+1}(2)]));
%                 new_sources(:,(num_prev_tp{tw+1}+1):tot_tp)   = input_result.ImageGridAmp(:, round(num_prev_tp{tw+1}+[tp_tw_limits{tw+1}(1):tp_tw_limits{tw+1}(2)]));
%             end
    end
    input_result.Time               = [1:tot_tp];    
    
    %% override and save a new time-reduced datafile, with the same temporal information of the present temporal reduction
    data_file.Time      = input_result.Time;
    data_file.F         = new_data_f;
    
    % get full path of original data_file (e.g.  /data/proj/X/bst_db/data/subj/cond)
    [indatafullpath, indatafullname, indatafullext] = fileparts(file_fullpath(input_result.DataFile));
    output_data_fullpath                            = fullfile(indatafullpath, [indatafullname '_tw_' write_mode output_data_postfix indatafullext]);
     save(output_data_fullpath, '-struct', 'data_file');
    
    % get brainstorm path of original data_file (e.g.  subj/cond)
    [indatapath, indataname, indataext] = fileparts(input_result.DataFile);
    output_data_file                    = fullfile(indatapath, [indataname '_tw_' write_mode output_data_postfix indataext]);

    %% save new time-reduced result file
    input_result.DataFile           = output_data_file;
    input_result.Comment            = [input_result.Comment ' | tw_' write_mode output_data_postfix];
    input_result.ImageGridAmp       = new_sources;
    input_result.Options.DataTime   = input_result.Time;
    
    output_result_file              = fullfile(inpath, [inname '_tw_' write_mode output_data_postfix inext]);
    save(output_result_file, '-struct', 'input_result');
    
    %% refresh subject
    [sStudy, iStudy, iData] = bst_get('DataFile', original_data_file);
    db_reload_studies(iStudy)
    
end
