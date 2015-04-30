%% function [dataexpcols, dataexp] = text_export_ersp_continuous_struct(out_file,ersp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_ersp_onset_offset_sub_struct(out_file,ersp_struct)


%             ersp_curve_roi_stat.dataroi(nroi).datatw.onset_offset = eeglab_study_curve_tw_onset_offset(input_onset_offset);
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
cell_subj=[];


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
cell_band                                                                  = [];




if nargin < 2
    help text_export_ersp_onset_offset_sub_struct;
    return;
end;


for nroi=1:length(ersp_struct.roi_names) % for each roi
    for nband=1:length(ersp_struct.frequency_bands_names) % for each frequency band        
        for nl1=1:length(ersp_struct.study_des.variable(1).value) % for each level of factor 1
            for nl2=1:length(ersp_struct.study_des.variable(2).value) % for each level of factor 2
                sub_list = ersp_struct.list_design_subjects{nl1,nl2};
                for nsub=1:length(sub_list) % for each subject
                    for ntw=1:length(ersp_struct.group_time_windows_names_design) % for each time window
                        
                    data = ersp_struct.dataroi(nroi).databand(nband).datatw.onset_offset.sub{nl1,nl2,nsub}.tw(ntw);
                        
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
                        
                        cell_roi                                                   = [cell_roi;ersp_struct.roi_names(nroi)];
                        cell_f1                                                    = [cell_f1; ersp_struct.study_des.variable(1).value(nl1)];
                        cell_f2                                                    = [cell_f2; ersp_struct.study_des.variable(2).value(nl2)];
                        cell_tw                                                    = [cell_tw; ersp_struct.group_time_windows_names_design(ntw)];
                        cell_subj                                                  = [cell_subj; sub_list(nsub)];
                        cell_band                                                  = [cell_band; ersp_struct.frequency_bands_names(nband)];
                    end
                end
            end
        end
    end
end


if isempty(char(ersp_struct.study_des.variable(1).label))
    dataexpcols={'subject', char(ersp_struct.study_des.variable(2).label) ,'tw',  'roi','band',...
        'tonset',                    'vonset',                  'toffset',                   'voffset',...
        'tmax_deflection',           'max_deflection',          'tmin_deflection',           'min_deflection',...
        'dt_onset_max_deflection',   'dt_max_deflection_offset','area_onset_max_deflection',...
        'area_max_deflection_offset', 'dt_onset_min_deflection', 'dt_min_deflection_offset', 'area_onset_min_deflection', ...
        'area_min_deflection_offset', 'dt_onset_offset',         'area_onset_offset',        'vmean_onset_offset', ...
        'vmedian_onset_offset',       'barycenter'...
        };
    
    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
    
    formatSpecData = '%s\t%s\t%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n';
    
    
    dataexp=[cell_subj,                      cell_f2,                      cell_tw,                       cell_roi, cell_band,...
        cell_tonset,                    cell_vonset,                  cell_toffset,                   cell_voffset,...
        cell_tmax_deflection,           cell_max_deflection,          cell_tmin_deflection,            cell_min_deflection,...
        cell_dt_onset_max_deflection,   cell_dt_max_deflection_offset,cell_area_onset_max_deflection,...
        cell_area_max_deflection_offset, cell_dt_onset_min_deflection, cell_dt_min_deflection_offset, cell_area_onset_min_deflection, ...
        cell_area_min_deflection_offset, cell_dt_onset_offset,         cell_area_onset_offset,        cell_vmean_onset_offset, ...
        cell_vmedian_onset_offset,       cell_barycenter...
        ];
    
elseif isempty(char(ersp_struct.study_des.variable(2).label))
    
    dataexpcols={'subject', char(ersp_struct.study_des.variable(1).label) ,'tw',  'roi','band',...
        'tonset',                    'vonset',                  'toffset',                   'voffset',...
        'tmax_deflection',           'max_deflection',          'tmin_deflection',           'min_deflection',...
        'dt_onset_max_deflection',   'dt_max_deflection_offset','area_onset_max_deflection',...
        'area_max_deflection_offset', 'dt_onset_min_deflection', 'dt_min_deflection_offset', 'area_onset_min_deflection', ...
        'area_min_deflection_offset', 'dt_onset_offset',         'area_onset_offset',        'vmean_onset_offset', ...
        'vmedian_onset_offset',       'barycenter'...
        };
    
    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
    
    formatSpecData = '%s\t%s\t%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n';
    
    
    dataexp=[cell_subj,                      cell_f1,                      cell_tw,                       cell_roi, cell_band,...
        cell_tonset,                    cell_vonset,                  cell_toffset,                   cell_voffset,...
        cell_tmax_deflection,           cell_max_deflection,          cell_tmin_deflection,            cell_min_deflection,...
        cell_dt_onset_max_deflection,   cell_dt_max_deflection_offset,cell_area_onset_max_deflection,...
        cell_area_max_deflection_offset, cell_dt_onset_min_deflection, cell_dt_min_deflection_offset, cell_area_onset_min_deflection, ...
        cell_area_min_deflection_offset, cell_dt_onset_offset,         cell_area_onset_offset,        cell_vmean_onset_offset, ...
        cell_vmedian_onset_offset,       cell_barycenter...
        ];
    
else
    dataexpcols={'subject', char(ersp_struct.study_des.variable(1).label), char(ersp_struct.study_des.variable(2).label),'tw',  'roi','band',...
        'tonset',                    'vonset',                  'toffset',                   'voffset',...
        'tmax_deflection',           'max_deflection',          'tmin_deflection',           'min_deflection',...
        'dt_onset_max_deflection',   'dt_max_deflection_offset','area_onset_max_deflection',...
        'area_max_deflection_offset', 'dt_onset_min_deflection', 'dt_min_deflection_offset', 'area_onset_min_deflection', ...
        'area_min_deflection_offset', 'dt_onset_offset',         'area_onset_offset',        'vmean_onset_offset', ...
        'vmedian_onset_offset',       'barycenter'...
        };
    
    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
    
    formatSpecData = '%s\t%s\t%s\t%s\t%s\t%s\t%f\t %f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t %f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n';
    
    dataexp=[cell_subj,                      cell_f1,                      cell_f2,                       cell_tw,                       cell_roi, cell_band,...
        cell_tonset,                    cell_vonset,                  cell_toffset,                   cell_voffset,...
        cell_tmax_deflection,           cell_max_deflection,          cell_tmin_deflection,            cell_min_deflection,...
        cell_dt_onset_max_deflection,   cell_dt_max_deflection_offset,cell_area_onset_max_deflection,...
        cell_area_max_deflection_offset, cell_dt_onset_min_deflection, cell_dt_min_deflection_offset, cell_area_onset_min_deflection, ...
        cell_area_min_deflection_offset, cell_dt_onset_offset,         cell_area_onset_offset,        cell_vmean_onset_offset, ...
        cell_vmedian_onset_offset,       cell_barycenter...
        ];
end

%     out_file = fullfile(plot_dir,'ersp_topo-stat.txt');
fileID = fopen(out_file,'w');
fprintf(fileID,formatSpecCols,dataexpcols{:});
[nrows,ncols] = size(dataexp);
for row = 1:nrows
    fprintf(fileID,formatSpecData,dataexp{row,:});
end


fclose(fileID);


%% export pvalues / significance for each time point


end