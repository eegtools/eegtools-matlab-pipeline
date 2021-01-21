%% function [dataexpcols, dataexp] = text_export_erp_continuous_struct(out_file,erp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_erp_onset_offset_avgsub_struct(out_file,erp_struct)


%             erp_curve_roi_stat.dataroi(nroi).datatw.onset_offset = eeglab_study_curve_tw_onset_offset(input_onset_offset);
%
%   output.pvec                                                         = pvec;                                              % vettore con valori di p
%     output.sigvec                                                       = sigvec;                                            % vettore con maschera significatività
%     output.tonset                                                       = tonset;                                            % tempo di onset
%     output.vonset                                                       = vonset;                                            % valore di onset
%     output.toffset                                                      = toffset;                                           % tempo di offset
%     output.voffset                                                      = voffset;                                           % valore di offset
%     output.tmax_deflection                                              = tmax_deflection;                                   % tempo di valore massimo della deflessione
%     output.max_deflection                                               = max_deflection;                                    % valore massimo della deflessione
%     output.tmin_deflection                                              = tmin_deflection;                                   % tempo di valore minimo della deflessione
%     output.min_deflection                                               = min_deflection;                                    % valore valore minimo della deflessione
%     output.dt_onset_max_deflection                                      = dt_onset_max_deflection;                           % tempo tra onset e massimo di deflessione
%     output.dt_max_deflection_offset                                     = dt_max_deflection_offset;                          % tempo tra massimo di deflessione e offset
%     output.area_onset_max_deflection                                    = area_onset_max_deflection;                         % area tra onset e massimo di deflessione
%     output.area_max_deflection_offset                                   = area_max_deflection_offset;                        % area tra massimo di deflessione e offset
%     output.dt_onset_min_deflection                                      = dt_onset_min_deflection;                           % tempo tra onset e mainimo di deflessione
%     output.dt_min_deflection_offset                                     = dt_min_deflection_offset;                          % tempo tra minimo di deflessione e offset
%     output.area_onset_min_deflection                                    = area_onset_min_deflection;                         % area tra onset e minimo di deflessione
%     output.area_min_deflection_offset                                   = area_min_deflection_offset;                        % area tra minimo di deflessione e offset
%     output.dt_onset_offset                                              = dt_onset_offset;                                   % tempo tra onset e offset
%     output.area_onset_offset                                            = area_onset_offset;                                 % area tra onset e offset
%     output.vmean_onset_offset                                           = vmean_onset_offset;                                % media curva tra onset e offset
%     output.vmedian_onset_offset                                         = vmedian_onset_offset;                              % mediana curva tra onset e offset
%     output.barycenter                                                   = barycenter;                                        % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
%

% output{nl1,nl2,ntw,nsub} = fcoo;

%% export wt parameters



%% inizialize
dataexp=[];
dataexpcols=[];




%% initialize parameters for tw statistic

cell_tonset                                                                = [];
cell_vonset                                                                = [];
cell_toffset                                                               = [];
cell_voffset                                                               = [];
cell_tmax_deflection                                                       = [];
cell_max_deflection                                                        = [];
cell_tmin_deflection                                                       = [];
cell_min_deflection                                                        = [];
cell_dt_onset_max_deflection                                               = [];
cell_dt_max_deflection_offset                                              = [];
cell_area_onset_max_deflection                                             = [];
cell_area_max_deflection_offset                                            = [];
cell_dt_onset_min_deflection                                               = [];
cell_dt_min_deflection_offset                                              = [];
cell_area_onset_min_deflection                                             = [];
cell_area_min_deflection_offset                                            = [];
cell_dt_onset_offset                                                       = [];
cell_area_onset_offset                                                     = [];
cell_vmean_onset_offset                                                    = [];
cell_vmedian_onset_offset                                                  = [];
cell_barycenter                                                            = [];

cell_roi                                                                   = [];
cell_f1                                                                    = [];
cell_f2                                                                    = [];
cell_tw                                                                    = [];





if nargin < 2
    help text_export_erp_onset_offset_avgsub_struct;
    return;
end

if (length(erp_struct.study_des.variable) > 1)
    for nroi=1:length(erp_struct.roi_names) % for each roi
        for nl1=1:length(erp_struct.study_des.variable(1).value) % for each level of factor 1
            for nl2=1:length(erp_struct.study_des.variable(2).value) % for each level of factor 2
                for ntw=1:length(erp_struct.group_time_windows_names_design) % for each time window
                    
                    tonset                                                                     = {nan};      % tempo di onset
                    vonset                                                                     = {nan};      % valore di onset
                    toffset                                                                    = {nan};      % tempo di offset
                    voffset                                                                    = {nan};      % valore di offset
                    tmax_deflection                                                            = {nan};      % tempo di valore massimo della deflessione
                    max_deflection                                                             = {nan};      % valore massimo della deflessione
                    tmin_deflection                                                            = {nan};      % tempo di valore minimo della deflessione
                    min_deflection                                                             = {nan};      % valore valore minimo della deflessione
                    dt_onset_max_deflection                                                    = {nan};      % tempo tra onset e massimo di deflessione
                    dt_max_deflection_offset                                                   = {nan};      % tempo tra massimo di deflessione e offset
                    area_onset_max_deflection                                                  = {nan};      % area tra onset e massimo di deflessione
                    area_max_deflection_offset                                                 = {nan};      % area tra massimo di deflessione e offset
                    dt_onset_min_deflection                                                    = {nan};      % tempo tra onset e mainimo di deflessione
                    dt_min_deflection_offset                                                   = {nan};      % tempo tra minimo di deflessione e offset
                    area_onset_min_deflection                                                  = {nan};      % area tra onset e minimo di deflessione
                    area_min_deflection_offset                                                 = {nan};      % area tra minimo di deflessione e offset
                    dt_onset_offset                                                            = {nan};      % tempo tra onset e offset
                    area_onset_offset                                                          = {nan};      % area tra onset e offset
                    vmean_onset_offset                                                         = {nan};      % media curva tra onset e offset
                    vmedian_onset_offset                                                       = {nan};      % mediana curva tra onset e offset
                    barycenter                                                                 = {nan};      % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
                    
                    data = erp_struct.dataroi(nroi).datatw.onset_offset.avgsub{nl1,nl2}.tw(ntw);
                    
                    
                    if not(isempty(data))
                        
                        tonset                                                                     = {data.tonset};
                        vonset                                                                     = {data.vonset};
                        toffset                                                                    = {data.toffset};
                        voffset                                                                    = {data.voffset};
                        tmax_deflection                                                            = {data.tmax_deflection};
                        max_deflection                                                             = {data.max_deflection};
                        tmin_deflection                                                            = {data.tmin_deflection};
                        min_deflection                                                             = {data.min_deflection};
                        dt_onset_max_deflection                                                    = {data.dt_onset_max_deflection};
                        dt_max_deflection_offset                                                   = {data.dt_max_deflection_offset};
                        area_onset_max_deflection                                                  = {data.area_onset_max_deflection};
                        area_max_deflection_offset                                                 = {data.area_max_deflection_offset};
                        dt_onset_min_deflection                                                    = {data.dt_onset_min_deflection};
                        dt_min_deflection_offset                                                   = {data.dt_min_deflection_offset};
                        area_onset_min_deflection                                                  = {data.area_onset_min_deflection};
                        area_min_deflection_offset                                                 = {data.area_min_deflection_offset};
                        dt_onset_offset                                                            = {data.dt_onset_offset};
                        area_onset_offset                                                          = {data.area_onset_offset};
                        vmean_onset_offset                                                         = {data.vmean_onset_offset};
                        vmedian_onset_offset                                                       = {data.vmedian_onset_offset};
                        barycenter                                                                 = {data.barycenter};
                        
                    end
                    
                    cell_tonset                                                                = [cell_tonset;                     tonset];
                    cell_vonset                                                                = [cell_vonset;                     vonset];
                    cell_toffset                                                               = [cell_toffset;                    toffset];
                    cell_voffset                                                               = [cell_voffset;                    voffset];
                    cell_tmax_deflection                                                       = [cell_tmax_deflection;            tmax_deflection];
                    cell_max_deflection                                                        = [cell_max_deflection;             max_deflection];
                    cell_tmin_deflection                                                       = [cell_tmin_deflection;            tmin_deflection];
                    cell_min_deflection                                                        = [cell_min_deflection;             min_deflection];
                    cell_dt_onset_max_deflection                                               = [cell_dt_onset_max_deflection;    dt_onset_max_deflection];
                    cell_dt_max_deflection_offset                                              = [cell_dt_max_deflection_offset;   dt_max_deflection_offset];
                    cell_area_onset_max_deflection                                             = [cell_area_onset_max_deflection;  area_onset_max_deflection];
                    cell_area_max_deflection_offset                                            = [cell_area_max_deflection_offset; area_max_deflection_offset];
                    cell_dt_onset_min_deflection                                               = [cell_dt_onset_min_deflection;    dt_onset_min_deflection];
                    cell_dt_min_deflection_offset                                              = [cell_dt_min_deflection_offset;   dt_min_deflection_offset];
                    cell_area_onset_min_deflection                                             = [cell_area_onset_min_deflection;  area_onset_min_deflection];
                    cell_area_min_deflection_offset                                            = [cell_area_min_deflection_offset; area_min_deflection_offset];
                    cell_dt_onset_offset                                                       = [cell_dt_onset_offset;            dt_onset_offset];
                    cell_area_onset_offset                                                     = [cell_area_onset_offset;          area_onset_offset];
                    cell_vmean_onset_offset                                                    = [cell_vmean_onset_offset;         vmean_onset_offset];
                    cell_vmedian_onset_offset                                                  = [cell_vmedian_onset_offset;       vmedian_onset_offset];
                    cell_barycenter                                                            = [cell_barycenter;                 barycenter];
                    
                    cell_roi                                                   = [cell_roi;erp_struct.roi_names(nroi)];
                    cell_f1                                                    = [cell_f1; erp_struct.study_des.variable(1).value(nl1)];
                    cell_f2                                                    = [cell_f2; erp_struct.study_des.variable(2).value(nl2)];
                    cell_tw                                                    = [cell_tw; erp_struct.group_time_windows_names_design(ntw)];
                end
            end
        end
    end
    
    
    
    if isempty(char(erp_struct.study_des.variable(1).label))
        dataexpcols={ char(erp_struct.study_des.variable(2).label) ,'tw',  'roi',...
            'tonset',                    'vonset',                  'toffset',                   'voffset',...
            'tmax_deflection',           'max_deflection',          'tmin_deflection',           'min_deflection',...
            'dt_onset_max_deflection',   'dt_max_deflection_offset','area_onset_max_deflection',...
            'area_max_deflection_offset', 'dt_onset_min_deflection', 'dt_min_deflection_offset', 'area_onset_min_deflection', ...
            'area_min_deflection_offset', 'dt_onset_offset',         'area_onset_offset',        'vmean_onset_offset', ...
            'vmedian_onset_offset',       'barycenter'...
            };
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        
        formatSpecData = '%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n';
        
        
        dataexp=[                      cell_f2,                      cell_tw,                       cell_roi, ...
            cell_tonset,                    cell_vonset,                  cell_toffset,                   cell_voffset,...
            cell_tmax_deflection,           cell_max_deflection,          cell_tmin_deflection,            cell_min_deflection,...
            cell_dt_onset_max_deflection,   cell_dt_max_deflection_offset,cell_area_onset_max_deflection,...
            cell_area_max_deflection_offset, cell_dt_onset_min_deflection, cell_dt_min_deflection_offset, cell_area_onset_min_deflection, ...
            cell_area_min_deflection_offset, cell_dt_onset_offset,         cell_area_onset_offset,        cell_vmean_onset_offset, ...
            cell_vmedian_onset_offset,       cell_barycenter...
            ];
        
    elseif isempty(char(erp_struct.study_des.variable(2).label))
        
        dataexpcols={ char(erp_struct.study_des.variable(1).label) ,'tw',  'roi',...
            'tonset',                    'vonset',                  'toffset',                   'voffset',...
            'tmax_deflection',           'max_deflection',          'tmin_deflection',           'min_deflection',...
            'dt_onset_max_deflection',   'dt_max_deflection_offset','area_onset_max_deflection',...
            'area_max_deflection_offset', 'dt_onset_min_deflection', 'dt_min_deflection_offset', 'area_onset_min_deflection', ...
            'area_min_deflection_offset', 'dt_onset_offset',         'area_onset_offset',        'vmean_onset_offset', ...
            'vmedian_onset_offset',       'barycenter'...
            };
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        
        formatSpecData = '%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n';
        
        
        dataexp=[                      cell_f1,                      cell_tw,                       cell_roi, ...
            cell_tonset,                    cell_vonset,                  cell_toffset,                   cell_voffset,...
            cell_tmax_deflection,           cell_max_deflection,          cell_tmin_deflection,            cell_min_deflection,...
            cell_dt_onset_max_deflection,   cell_dt_max_deflection_offset,cell_area_onset_max_deflection,...
            cell_area_max_deflection_offset, cell_dt_onset_min_deflection, cell_dt_min_deflection_offset, cell_area_onset_min_deflection, ...
            cell_area_min_deflection_offset, cell_dt_onset_offset,         cell_area_onset_offset,        cell_vmean_onset_offset, ...
            cell_vmedian_onset_offset,       cell_barycenter...
            ];
        
    else
        dataexpcols={ char(erp_struct.study_des.variable(1).label), char(erp_struct.study_des.variable(2).label),'tw',  'roi',...
            'tonset',                    'vonset',                  'toffset',                   'voffset',...
            'tmax_deflection',           'max_deflection',          'tmin_deflection',           'min_deflection',...
            'dt_onset_max_deflection',   'dt_max_deflection_offset','area_onset_max_deflection',...
            'area_max_deflection_offset', 'dt_onset_min_deflection', 'dt_min_deflection_offset', 'area_onset_min_deflection', ...
            'area_min_deflection_offset', 'dt_onset_offset',         'area_onset_offset',        'vmean_onset_offset', ...
            'vmedian_onset_offset',       'barycenter'...
            };
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        
        formatSpecData = '%s\t%s\t%s\t%s\t%f\t %f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t %f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n';
        
        dataexp=[                      cell_f1,                      cell_f2,                       cell_tw,                       cell_roi, ...
            cell_tonset,                    cell_vonset,                  cell_toffset,                   cell_voffset,...
            cell_tmax_deflection,           cell_max_deflection,          cell_tmin_deflection,            cell_min_deflection,...
            cell_dt_onset_max_deflection,   cell_dt_max_deflection_offset,cell_area_onset_max_deflection,...
            cell_area_max_deflection_offset, cell_dt_onset_min_deflection, cell_dt_min_deflection_offset, cell_area_onset_min_deflection, ...
            cell_area_min_deflection_offset, cell_dt_onset_offset,         cell_area_onset_offset,        cell_vmean_onset_offset, ...
            cell_vmedian_onset_offset,       cell_barycenter...
            ];
    end
    
    
else
    for nroi=1:length(erp_struct.roi_names) % for each roi
        for nl1=1:length(erp_struct.study_des.variable(1).value) % for each level of factor 1
            for ntw=1:length(erp_struct.group_time_windows_names_design) % for each time window
                
                tonset                                                                     = {nan};      % tempo di onset
                vonset                                                                     = {nan};      % valore di onset
                toffset                                                                    = {nan};      % tempo di offset
                voffset                                                                    = {nan};      % valore di offset
                tmax_deflection                                                            = {nan};      % tempo di valore massimo della deflessione
                max_deflection                                                             = {nan};      % valore massimo della deflessione
                tmin_deflection                                                            = {nan};      % tempo di valore minimo della deflessione
                min_deflection                                                             = {nan};      % valore valore minimo della deflessione
                dt_onset_max_deflection                                                    = {nan};      % tempo tra onset e massimo di deflessione
                dt_max_deflection_offset                                                   = {nan};      % tempo tra massimo di deflessione e offset
                area_onset_max_deflection                                                  = {nan};      % area tra onset e massimo di deflessione
                area_max_deflection_offset                                                 = {nan};      % area tra massimo di deflessione e offset
                dt_onset_min_deflection                                                    = {nan};      % tempo tra onset e mainimo di deflessione
                dt_min_deflection_offset                                                   = {nan};      % tempo tra minimo di deflessione e offset
                area_onset_min_deflection                                                  = {nan};      % area tra onset e minimo di deflessione
                area_min_deflection_offset                                                 = {nan};      % area tra minimo di deflessione e offset
                dt_onset_offset                                                            = {nan};      % tempo tra onset e offset
                area_onset_offset                                                          = {nan};      % area tra onset e offset
                vmean_onset_offset                                                         = {nan};      % media curva tra onset e offset
                vmedian_onset_offset                                                       = {nan};      % mediana curva tra onset e offset
                barycenter                                                                 = {nan};      % baricentro (tempo pesato sulle ampiezze) curva tra onset e offset
                
                data = erp_struct.dataroi(nroi).datatw.onset_offset.avgsub{nl1}.tw(ntw);
                
                
                if not(isempty(data))
                    
                    tonset                                                                     = {data.tonset};
                    vonset                                                                     = {data.vonset};
                    toffset                                                                    = {data.toffset};
                    voffset                                                                    = {data.voffset};
                    tmax_deflection                                                            = {data.tmax_deflection};
                    max_deflection                                                             = {data.max_deflection};
                    tmin_deflection                                                            = {data.tmin_deflection};
                    min_deflection                                                             = {data.min_deflection};
                    dt_onset_max_deflection                                                    = {data.dt_onset_max_deflection};
                    dt_max_deflection_offset                                                   = {data.dt_max_deflection_offset};
                    area_onset_max_deflection                                                  = {data.area_onset_max_deflection};
                    area_max_deflection_offset                                                 = {data.area_max_deflection_offset};
                    dt_onset_min_deflection                                                    = {data.dt_onset_min_deflection};
                    dt_min_deflection_offset                                                   = {data.dt_min_deflection_offset};
                    area_onset_min_deflection                                                  = {data.area_onset_min_deflection};
                    area_min_deflection_offset                                                 = {data.area_min_deflection_offset};
                    dt_onset_offset                                                            = {data.dt_onset_offset};
                    area_onset_offset                                                          = {data.area_onset_offset};
                    vmean_onset_offset                                                         = {data.vmean_onset_offset};
                    vmedian_onset_offset                                                       = {data.vmedian_onset_offset};
                    barycenter                                                                 = {data.barycenter};
                    
                end
                
                cell_tonset                                                                = [cell_tonset;                     tonset];
                cell_vonset                                                                = [cell_vonset;                     vonset];
                cell_toffset                                                               = [cell_toffset;                    toffset];
                cell_voffset                                                               = [cell_voffset;                    voffset];
                cell_tmax_deflection                                                       = [cell_tmax_deflection;            tmax_deflection];
                cell_max_deflection                                                        = [cell_max_deflection;             max_deflection];
                cell_tmin_deflection                                                       = [cell_tmin_deflection;            tmin_deflection];
                cell_min_deflection                                                        = [cell_min_deflection;             min_deflection];
                cell_dt_onset_max_deflection                                               = [cell_dt_onset_max_deflection;    dt_onset_max_deflection];
                cell_dt_max_deflection_offset                                              = [cell_dt_max_deflection_offset;   dt_max_deflection_offset];
                cell_area_onset_max_deflection                                             = [cell_area_onset_max_deflection;  area_onset_max_deflection];
                cell_area_max_deflection_offset                                            = [cell_area_max_deflection_offset; area_max_deflection_offset];
                cell_dt_onset_min_deflection                                               = [cell_dt_onset_min_deflection;    dt_onset_min_deflection];
                cell_dt_min_deflection_offset                                              = [cell_dt_min_deflection_offset;   dt_min_deflection_offset];
                cell_area_onset_min_deflection                                             = [cell_area_onset_min_deflection;  area_onset_min_deflection];
                cell_area_min_deflection_offset                                            = [cell_area_min_deflection_offset; area_min_deflection_offset];
                cell_dt_onset_offset                                                       = [cell_dt_onset_offset;            dt_onset_offset];
                cell_area_onset_offset                                                     = [cell_area_onset_offset;          area_onset_offset];
                cell_vmean_onset_offset                                                    = [cell_vmean_onset_offset;         vmean_onset_offset];
                cell_vmedian_onset_offset                                                  = [cell_vmedian_onset_offset;       vmedian_onset_offset];
                cell_barycenter                                                            = [cell_barycenter;                 barycenter];
                
                cell_roi                                                   = [cell_roi;erp_struct.roi_names(nroi)];
                cell_f1                                                    = [cell_f1; erp_struct.study_des.variable(1).value(nl1)];
                cell_tw                                                    = [cell_tw; erp_struct.group_time_windows_names_design(ntw)];
            end
        end
    end
    
    
    
    
    
    dataexpcols={ char(erp_struct.study_des.variable(1).label) ,'tw',  'roi',...
        'tonset',                    'vonset',                  'toffset',                   'voffset',...
        'tmax_deflection',           'max_deflection',          'tmin_deflection',           'min_deflection',...
        'dt_onset_max_deflection',   'dt_max_deflection_offset','area_onset_max_deflection',...
        'area_max_deflection_offset', 'dt_onset_min_deflection', 'dt_min_deflection_offset', 'area_onset_min_deflection', ...
        'area_min_deflection_offset', 'dt_onset_offset',         'area_onset_offset',        'vmean_onset_offset', ...
        'vmedian_onset_offset',       'barycenter'...
        };
    
    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
    
    formatSpecData = '%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n';
    
    
    dataexp=[                      cell_f1,                      cell_tw,                       cell_roi, ...
        cell_tonset,                    cell_vonset,                  cell_toffset,                   cell_voffset,...
        cell_tmax_deflection,           cell_max_deflection,          cell_tmin_deflection,            cell_min_deflection,...
        cell_dt_onset_max_deflection,   cell_dt_max_deflection_offset,cell_area_onset_max_deflection,...
        cell_area_max_deflection_offset, cell_dt_onset_min_deflection, cell_dt_min_deflection_offset, cell_area_onset_min_deflection, ...
        cell_area_min_deflection_offset, cell_dt_onset_offset,         cell_area_onset_offset,        cell_vmean_onset_offset, ...
        cell_vmedian_onset_offset,       cell_barycenter...
        ];
    
    
end


%     out_file = fullfile(plot_dir,'erp_topo-stat.txt');
fileID = fopen(out_file,'w');
fprintf(fileID,formatSpecCols,dataexpcols{:});
[nrows,ncols] = size(dataexp);
for row = 1:nrows
    fprintf(fileID,formatSpecData,dataexp{row,:});
end


fclose(fileID);


%% export pvalues / significance for each time point


end