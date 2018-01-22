%% function [dataexpcols, dataexp] = text_export_ersp_struct(out_file,ersp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_allch_erp_time_dd_gf(out_file,output)





% mi servono i livelli dei fattori!


cell_gf =  output.cell_gf;
times=output.times;
output_dd_eeglab_mask_cell_p_gf = output.output_dd_eeglab_mask_cell_p_gf ;
allch=output.allch;
list_design_subjects = output.list_design_subjects;

name_f1 = output.name_f1;
name_f2 = output.name_f2;
levels_f1 = output.levels_f1;
levels_f2 = output.levels_f2;

name_gf = input.name_gf;
name_cf = input.name_cf;


sigcell_pruned_gf=output_dd_eeglab_mask_cell_p_gf.sigcell_pruned_gf  ;
sel_ch_cell_gf=output_dd_eeglab_mask_cell_p_gf.sel_ch_cell_gf ;
cell_tw_gf = output_dd_eeglab_mask_cell_p_gf.cell_tw_gf ;
results_tw_cell_gf = output_dd_eeglab_mask_cell_p_gf.results_tw_cell_gf ;



results_tw_cell_gf_cf_ch = output_dd_eeglab_mask_cell_p_gf.results_tw_cell_gf_cf_ch;

[s1, s2] = size(results_tw_cell_gf_cf_ch);


if strcmp(name_gf,name_f1)
    
    for ns1 = 1:s1 % per ciascun livello del primo fattore
        
        sel_ch =  sel_ch_cell_gf{ns1};
        tot_ch = length(sel_ch);
        data_exp = {};
        lf1 = levels_f1{ns1};
        
        %         estrai matrice p del grouping factor (livello s1)
        for ns2 = 1:s2 % per ogni livello del secondo fattore
            % moltipica la matrice della p del gf corrispondente a s1 per ogni livello
            % del compaing factor (s2)
            
            %  livello di gruping, per ogni livello di comparing e per ogni canale con deflessione significativa vado ad
            %  estrarmi i parametri di tutte le tw con deflessioni
            
            results_ch =  results_tw_cell_gf_cf_ch{ns1, ns2} ;
            
            subjects = list_design_subjects{ns1, ns2};
            tot_sub = length(subjects);
            
            
            
            dataexpcols     = {name_f1, name_f2 , 'subject', 'channel','time_window',...
                'tonset', 'vonset','toffset', 'voffset',...
                'tmax_deflection','max_deflection','tmin_deflection','min_deflection',...
                'dt_onset_max_deflection','dt_max_deflection_offset','area_onset_max_deflection','area_max_deflection_offset',...
                'dt_onset_min_deflection','dt_min_deflection_offset','area_onset_min_deflection','area_min_deflection_offset',...
                'dt_onset_offset','area_onset_offset','vmean_onset_offset','vmedian_onset_offset', 'barycenter'
                };
            
            formatSpecCols  = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
            
            
            
            for nch = 1:tot_ch
                ind_ch = sel_ch(nch);
                lab_ch = allch{ind_ch};
                
                output_tw = results_ch{nch};
                tot_tw = length(output_tw);
                %% output
                for ntw = 1:tot_tw
                    tonset  = output_tw(ntw).tonset                                                     ;                                            % tempo di onset
                    vonset = output_tw(ntw).vonset                                                        ;                                            % valore di onset
                    toffset=output_tw(ntw).toffset                                                       ;                                           % tempo di offset
                    voffset=output_tw(ntw).voffset                                                       ;                                           % valore di offset
                    tmax_deflection={output_tw(ntw).tmax_deflection}                                              ;                                   % tempo di valore massimo della deflessione
                    max_deflection={output_tw(ntw).max_deflection}                                               ;                                    % valore massimo della deflessione
                    tmin_deflection={output_tw(ntw).tmin_deflection}                                               ;                                   % tempo di valore minimo della deflessione
                    min_deflection={output_tw(ntw).min_deflection}                                               ;                                    % valore valore minimo della deflessione
                    dt_onset_max_deflection={output_tw(ntw).dt_onset_max_deflection}                                       ;                           % tempo tra onset e massimo di deflessione
                    dt_max_deflection_offset={output_tw(ntw).dt_max_deflection_offset}                                      ;                          % tempo tra massimo di deflessione e offset
                    area_onset_max_deflection={output_tw(ntw).area_onset_max_deflection}                                     ;                         % area tra onset e massimo di deflessione
                    area_max_deflection_offset={output_tw(ntw).area_max_deflection_offset}                                    ;                        % area tra massimo di deflessione e offset
                    dt_onset_min_deflection={output_tw(ntw).dt_onset_min_deflection}                                      ;                           % tempo tra onset e mainimo di deflessione
                    dt_min_deflection_offset={output_tw(ntw).dt_min_deflection_offset}                                      ;                          % tempo tra minimo di deflessione e offset
                    area_onset_min_deflection={output_tw(ntw).area_onset_min_deflection}                                    ;                         % area tra onset e minimo di deflessione
                    area_min_deflection_offset={output_tw(ntw).area_min_deflection_offset}                                    ;                        % area tra minimo di deflessione e offset
                    dt_onset_offset={output_tw(ntw).dt_onset_offset}                                               ;                                   % tempo tra onset e offset
                    area_onset_offset=output_tw(ntw).area_onset_offset                                             ;                                 % area tra onset e offset
                    vmean_onset_offset={output_tw(ntw).vmean_onset_offset}                                            ;                                % media curva tra onset e offset
                    vmedian_onset_offset={output_tw(ntw).vmedian_onset_offset}                                          ;                              % mediana curva tra onset e offset
                    barycenter={output_tw(ntw).barycenter}                                                   ;
                    
                    time_window = [num2str(tonset),'-',num2str(toffset)];
                    
                    for nsub = 1:tot_sub
                        subject = subjects(nsub);
                        
                        formatSpecData  =  ['%s\t%s\t%s\t%s\t%s\t', ...
                            '%d\t%d\t%d\t%d\t%d\t',...
                            '%d\t%d\t%d\t%d\t%d\t',...
                            '%d\t%d\t%d\t%d\t%d\t',...
                            '%d\t%d\t%d\t%d\t%d\t',...
                            '%d\t%d\t%d\t%d\t%d\t%d\t',...
                            '\r\n'...
                            ];
                        
                        dataexp_r     =     [name_f1, name_f2 , subject, lab_ch, time_window,...
                            tonset, vonset(nsub),toffset, voffset(nsub),...
                            tmax_deflection(nsub),max_deflection(nsub),tmin_deflection(nsub),min_deflection(nsub),...
                            dt_onset_max_deflection(nsub),dt_max_deflection_offset(nsub),area_onset_max_deflection(nsub),area_max_deflection_offset(nsub),...
                            dt_onset_min_deflection(nsub),dt_min_deflection_offset(nsub),area_onset_min_deflection(nsub),area_min_deflection_offset(nsub),...
                            dt_onset_offset,area_onset_offset(nsub),vmean_onset_offset(nsub),vmedian_onset_offset(nsub), barycenter(nsub)
                            ];
                        dataexp = [dataexp;dataexp_r];
                    end
                end
                
            end
            
        end
    end
    
    
else
    for ns2 = 1:s2 % per ciascun livello del secondo fattore
        
        sel_ch =  sel_ch_cell_gf{ns2};
        tot_ch = length(sel_ch);
        data_exp = {};
        lf2 = levels_f1{ns2};
        
        %         estrai matrice p del grouping factor (livello s2)
        for ns1 = 1:s1 % per ogni livello del secondo fattore
            % moltipica la matrice della p del gf corrispondente a s2 per ogni livello
            % del compaing factor (s1)
            
            %  livello di gruping, per ogni livello di comparing e per ogni canale con deflessione significativa vado ad
            %  estrarmi i parametri di tutte le tw con deflessioni
            
            results_ch =  results_tw_cell_gf_cf_ch{ns1, ns2} ;
            
            subjects = list_design_subjects{ns1, ns2};
            tot_sub = length(subjects);
            
            
            
            dataexpcols     = {name_f1, name_f2 , 'subject', 'channel','time_window',...
                'tonset', 'vonset','toffset', 'voffset',...
                'tmax_deflection','max_deflection','tmin_deflection','min_deflection',...
                'dt_onset_max_deflection','dt_max_deflection_offset','area_onset_max_deflection','area_max_deflection_offset',...
                'dt_onset_min_deflection','dt_min_deflection_offset','area_onset_min_deflection','area_min_deflection_offset',...
                'dt_onset_offset','area_onset_offset','vmean_onset_offset','vmedian_onset_offset', 'barycenter'
                };
            
            formatSpecCols  = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
            
            
            
            for nch = 1:tot_ch
                ind_ch = sel_ch(nch);
                lab_ch = allch{ind_ch}
                
                output_tw = results_ch{nch};
                tot_tw = length(output_tw);
                
                
                
                %% output
                for ntw = 1:tot_tw
                    
                    tonset  = output_tw(ntw).tonset                                                     ;                                            % tempo di onset
                    vonset = output_tw(ntw).vonset                                                        ;                                            % valore di onset
                    toffset=output_tw(ntw).toffset                                                       ;                                           % tempo di offset
                    voffset=output_tw(ntw).voffset                                                       ;                                           % valore di offset
                    tmax_deflection={output_tw(ntw).tmax_deflection}                                              ;                                   % tempo di valore massimo della deflessione
                    max_deflection={output_tw(ntw).max_deflection}                                               ;                                    % valore massimo della deflessione
                    tmin_deflection={output_tw(ntw).tmin_deflection}                                               ;                                   % tempo di valore minimo della deflessione
                    min_deflection={output_tw(ntw).min_deflection}                                               ;                                    % valore valore minimo della deflessione
                    dt_onset_max_deflection={output_tw(ntw).dt_onset_max_deflection}                                       ;                           % tempo tra onset e massimo di deflessione
                    dt_max_deflection_offset={output_tw(ntw).dt_max_deflection_offset}                                      ;                          % tempo tra massimo di deflessione e offset
                    area_onset_max_deflection={output_tw(ntw).area_onset_max_deflection}                                     ;                         % area tra onset e massimo di deflessione
                    area_max_deflection_offset={output_tw(ntw).area_max_deflection_offset}                                    ;                        % area tra massimo di deflessione e offset
                    dt_onset_min_deflection={output_tw(ntw).dt_onset_min_deflection}                                      ;                           % tempo tra onset e mainimo di deflessione
                    dt_min_deflection_offset={output_tw(ntw).dt_min_deflection_offset}                                      ;                          % tempo tra minimo di deflessione e offset
                    area_onset_min_deflection={output_tw(ntw).area_onset_min_deflection}                                    ;                         % area tra onset e minimo di deflessione
                    area_min_deflection_offset={output_tw(ntw).area_min_deflection_offset}                                    ;                        % area tra minimo di deflessione e offset
                    dt_onset_offset={output_tw(ntw).dt_onset_offset}                                               ;                                   % tempo tra onset e offset
                    area_onset_offset=output_tw(ntw).area_onset_offset                                             ;                                 % area tra onset e offset
                    vmean_onset_offset={output_tw(ntw).vmean_onset_offset}                                            ;                                % media curva tra onset e offset
                    vmedian_onset_offset={output_tw(ntw).vmedian_onset_offset}                                          ;                              % mediana curva tra onset e offset
                    barycenter={output_tw(ntw).barycenter}                                                   ;
                    
                    time_window = [num2str(tonset),'-',num2str(toffset)];
                    
                    for nsub = 1:tot_sub
                        subject = subjects(nsub);
                        
                        formatSpecData  =  ['%s\t%s\t%s\t%s\t%s\t', ...
                            '%d\t%d\t%d\t%d\t%d\t',...
                            '%d\t%d\t%d\t%d\t%d\t',...
                            '%d\t%d\t%d\t%d\t%d\t',...
                            '%d\t%d\t%d\t%d\t%d\t',...
                            '%d\t%d\t%d\t%d\t%d\t%d\t',...
                            '\r\n'...
                            ];
                        
                        dataexp_r     =     [name_f1, name_f2 , subject, lab_ch, time_window,...
                            tonset, vonset(nsub),toffset, voffset(nsub),...
                            tmax_deflection(nsub),max_deflection(nsub),tmin_deflection(nsub),min_deflection(nsub),...
                            dt_onset_max_deflection(nsub),dt_max_deflection_offset(nsub),area_onset_max_deflection(nsub),area_max_deflection_offset(nsub),...
                            dt_onset_min_deflection(nsub),dt_min_deflection_offset(nsub),area_onset_min_deflection(nsub),area_min_deflection_offset(nsub),...
                            dt_onset_offset,area_onset_offset(nsub),vmean_onset_offset(nsub),vmedian_onset_offset(nsub), barycenter(nsub)
                            ];
                        dataexp = [dataexp;dataexp_r];
                        
                    end
                end
                
            end
        end
        
    end
    
end

fileID          = fopen([out_file,lf2],'w');
fprintf(fileID,formatSpecCols,dataexpcols{:});
[nrows,ncols]   = size(dataexp);
for row = 1:nrows
    fprintf(fileID,formatSpecData,dataexp{row,:});
end

fclose(fileID);



end

% CHANGE LOG
% 19/6/15
% added export of fcog