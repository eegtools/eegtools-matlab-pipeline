%% function [dataexpcols, dataexp] = text_export_erp_allch_sub_continuous_struct(out_file_folder,erp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_ersp_allch_sub_continuous_struct(out_file_folder,ersp_struct)


%% inizialize
dataexp=[];
dataexpcols=[];


% % erp_curve_allch cell array of dimension tlf1 x tlf2 , each cell of
% % dimension times x channels x subjects
% [STUDY, erp_curve_allch, times]=std_erpplot(STUDY,ALLEEG,'channels',allch,'noplot','on');


if nargin < 2
    help text_export_erp_onset_offset_sub_continuous_struct;
    return;
end;

out_file_subfolder = fullfile(out_file_folder,'allch_sub_continuous');

mkdir(out_file_subfolder);

times                                                          = ersp_struct.times;

if (length(ersp_struct.study_des.variable) > 1)
    for nb = 1:length(ersp_struct.frequency_bands_names)
        for nl1=1:length(ersp_struct.study_des.variable(1).value) % for each level of factor 1
            for nl2=1:length(ersp_struct.study_des.variable(2).value) % for each level of factor 2
                
                
                %% initialize parameters
                
                cell_curve                                                                 = [];
                cell_times                                                                 = [];
                cell_sub                                                                   = [];
                cell_ch                                                                    = [];
                cell_f1                                                                    = [];
                cell_f2                                                                    = [];
                
                
                data = ersp_struct.databand(nb).ersp_curve_allch_fb{nl1,nl2};...ersp_struct.ersp_curve_allch{nl1,nl2};
                    sub_list = ersp_struct.list_design_subjects{nl1,nl2};
                
                for nsub=1:length(sub_list) % for each subject
                    
                    for nch=1:length(ersp_struct.allch) % for each roi
                        curve                                                      = squeeze(data(:,nch,nsub));
                        lc                                                         = length(curve);
                        
                        ch                                                         = repmat(ersp_struct.allch(nch),lc,1);
                        
                        lf1                                                        = ersp_struct.study_des.variable(1).value(nl1);
                        lf2                                                        = ersp_struct.study_des.variable(2).value(nl2);
                        
                        f1                                                         = repmat(lf1,lc,1);
                        f2                                                         = repmat(lf2,lc,1);
                        sub                                                        = repmat(sub_list(nsub),lc,1);
                        
                        cell_curve                                                     = [cell_curve;                curve];
                        cell_times                                                     = [cell_times,                times];
                        cell_sub                                                       = [cell_sub; sub];
                        cell_ch                                                        = [cell_ch; ch];
                        cell_f1                                                        = [cell_f1; f1];
                        cell_f2                                                        = [cell_f2; f2];
                    end
                    
                    
                end
                
                
                cell_curve            = num2cell(cell_curve);
                cell_times            = num2cell(cell_times');
                
                
                
                if isempty(char(ersp_struct.study_des.variable(1).label))
                    dataexpcols={ char(ersp_struct.study_des.variable(2).label) ,  'ch', 'sub','times',   'curve',...
                        };
                    
                    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
                    
                    formatSpecData = '%s\t%s\t%s\t%f\t%f\r\n';
                    
                    
                    dataexp=[cell_f2,cell_ch, cell_sub,  cell_times, cell_curve ];
                    
                    
                    str = char(lf2);
                    
                    
                elseif isempty(char(ersp_struct.study_des.variable(2).label))
                    
                    dataexpcols={ char(ersp_struct.study_des.variable(1).label) ,   'ch', 'sub','times',   'curve',...
                        };
                    
                    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
                    
                    formatSpecData =  '%s\t%s\t%s\t%f\t%f\r\n';
                    
                    
                    dataexp=[cell_f1,cell_ch, cell_sub,  cell_times, cell_curve ];
                    
                    str = [char(lf1)];
                    
                else
                    dataexpcols={ char(ersp_struct.study_des.variable(1).label), char(ersp_struct.study_des.variable(2).label),  'ch', 'sub','times',   'curve',...
                        };
                    
                    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
                    
                    formatSpecData = '%s\t%s\t%s\t%s\t%f\t%f\r\n';
                    
                    dataexp=[cell_f1,cell_f2,cell_ch, cell_sub,  cell_times, cell_curve ];
                    
                    str = [ersp_struct.frequency_bands_names{nb},'_',char(lf1),'_' ,char(lf2)];
                end
                
                
                
                out_file = fullfile(out_file_subfolder,[str,'.txt']);
                fileID = fopen(out_file,'w');
                fprintf(fileID,formatSpecCols,dataexpcols{:});
                [nrows,ncols] = size(dataexp);
                for row = 1:nrows
                    fprintf(fileID,formatSpecData,dataexp{row,:});
                end
                
                
                fclose(fileID);
                
                
                
                
            end
        end
        
        
    end
else
    for nb = 1:length(ersp_struct.frequency_bands_names)
        for nl1=1:length(ersp_struct.study_des.variable(1).value) % for each level of factor 1
            
            
            %% initialize parameters
            
            cell_curve                                                                 = [];
            cell_times                                                                 = [];
            cell_sub                                                                   = [];
            cell_ch                                                                    = [];
            cell_f1                                                                    = [];
            
            
            data = ersp_struct.databand(nb).ersp_curve_allch_fb{nl1};...ersp_struct.ersp_curve_allch{nl1,nl2};
                sub_list = ersp_struct.list_design_subjects{nl1};
            
            for nsub=1:length(sub_list) % for each subject
                
                for nch=1:length(ersp_struct.allch) % for each roi
                    curve                                                      = squeeze(data(:,nch,nsub));
                    lc                                                         = length(curve);
                    
                    ch                                                         = repmat(ersp_struct.allch(nch),lc,1);
                    
                    lf1                                                        = ersp_struct.study_des.variable(1).value(nl1);
                    
                    f1                                                         = repmat(lf1,lc,1);
                    sub                                                        = repmat(sub_list(nsub),lc,1);
                    
                    cell_curve                                                     = [cell_curve;                curve];
                    cell_times                                                     = [cell_times,                times];
                    cell_sub                                                       = [cell_sub; sub];
                    cell_ch                                                        = [cell_ch; ch];
                    cell_f1                                                        = [cell_f1; f1];
                end
                
                
            end
            
            
            cell_curve            = num2cell(cell_curve);
            cell_times            = num2cell(cell_times');
            
            
            
            
            
            dataexpcols={ char(ersp_struct.study_des.variable(1).label) ,   'ch', 'sub','times',   'curve',...
                };
            
            formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
            
            formatSpecData =  '%s\t%s\t%s\t%f\t%f\r\n';
            
            
            dataexp=[cell_f1,cell_ch, cell_sub,  cell_times, cell_curve ];
            
            str = [char(lf1)];
            
            
            
            
            
            out_file = fullfile(out_file_subfolder,[str,'.txt']);
            fileID = fopen(out_file,'w');
            fprintf(fileID,formatSpecCols,dataexpcols{:});
            [nrows,ncols] = size(dataexp);
            for row = 1:nrows
                fprintf(fileID,formatSpecData,dataexp{row,:});
            end
            
            
            fclose(fileID);
            
            
            
            
        end
        
        
    end
    
end




end