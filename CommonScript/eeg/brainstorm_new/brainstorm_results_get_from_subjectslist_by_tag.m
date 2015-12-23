% data_file : data_average.mat

function ResultFile = brainstorm_results_get_from_subjectslist_by_tag(subjects_list, condition_name, data_file, file_tag)

    for s=1:length(subjects_list)
        
        [sStudy, iStudy, iResults] = bst_get('ResultsForDataFile', [subjects_list{s} '/' condition_name '/' data_file]);
        sFiles = {sStudy.Result.FileName}; 
        sFiles = bst_process(...
            'CallProcess', 'process_select_tag', ...
            sFiles, [], ...
            'tag', file_tag, ...
            'search', 2, ...
            'select', 1);  % Select only the files with the tag
        
        % Save report
        ReportFile      = bst_report('Save', sFiles);
        if isempty(sFiles)
            bst_report('Open', ReportFile);        
            rep = load(ReportFile);
            rep.Reports{3,4}
           keyboard 
        end         
        
        ResultFile{s} = sFiles(1).FileName;
    end
end

