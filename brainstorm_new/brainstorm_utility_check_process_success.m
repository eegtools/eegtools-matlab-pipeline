function brainstorm_utility_check_process_success(sFiles)

    if isempty(sFiles)
        ReportFile  = bst_report('Save', sFiles);
        bst_report('Open', ReportFile);        
        rep         = load(ReportFile);
        
        a           = ismember(rep.Reports, 'error');
        row         = find(sum(a,2));
        rep.Reports{row,4}
        keyboard 
    end 
end