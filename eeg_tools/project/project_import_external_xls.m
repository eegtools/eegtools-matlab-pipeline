%   import futher data/fratures about subjects from an excel file
%
function project = project_import_external_xls(project)

% project.external_xls.xls_folder  = 'C:\projects\CIUCCIO';
% project.external_xls.xls_file  = 'Database_Ciuccio.xlsx';
% project.external_xls.xls_sheet = 'external';
if isfield(project, 'external_xls')
    
    if not(isempty(project.external_xls.xls_folder)) && not(isempty(project.external_xls.xls_file)) && not(isempty(project.external_xls.xls_sheet))
        xls_path = fullfile(project.external_xls.xls_folder,project.external_xls.xls_file);
        if exist(xls_path,'file')
            [~,~,RAW] = xlsread(xls_path, project.external_xls.xls_sheet);
            
            col_names = RAW(1,:);
            sel_sub_col = ismember(lower(col_names), 'subject') | ismember(lower(col_names), 'soggetto') | ismember(lower(col_names), 'subj') | ismember(lower(col_names), 'sub');
            sub_col = RAW(2:end,sel_sub_col);
            sel_nf = find(not(sel_sub_col));
            new_fields = col_names(sel_nf);
%             project = project;
            % project.subjects.data = setfield(project.subjects.data,new_fields{2},cell( 1, length(project.subjects.data )));
            tf = length(new_fields);
            ts = length(sub_col);
            
            for ns = 1:ts
                current_subject = sub_col{ns};
                sel_sub = ismember({project.subjects.data.name},current_subject);
                inds = sel_sub(ns)+1;
                for nf = 1:tf
                    current_field = new_fields{nf};
                    current_val = RAW{inds,sel_nf(nf)};
                    project.subjects.data(ns).(current_field) = current_val;
                end
            end
        end
    end
end
end