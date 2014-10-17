%% function get_erp_stats(result_struct, design_path, fp_full, fp_signif, fp_lat, design_separator, tw_separator, roi_separator)
% parse a folder for desing results folder
% open mat files, get stats value and print them to a file
%
% VARARGIN INPUTs
% list_windows_names :  {'P100', 'N330', etc...}
% list_subjects : {'aa', 'bb', ...etc}
%
% OUTPUT:
% a text file 


function get_erp_stats(result_struct, design_path, fp_full, fp_signif, fp_lat, varargin) ..., design_separator, tw_separator, roi_separator)

    if nargin < 1
           help get_erp_stats;
           return;    
    end;
     
    
    sub_correction = 1;
    p_thresh       = result_struct.study_ls;
    
    for v=1:2:length(varargin)
       if ~isempty(varargin{v+1})         
           switch varargin{v}
               case 'design_separator'
                design_separator = varargin{v+1};
               case 'tw_separator'
                tw_separator = varargin{v+1};
               case 'roi_separator'
                roi_separator = varargin{v+1};
               case 'sub_correction'
                sub_correction = varargin{v+1};
               case 'p_thresh'
                p_thresh = varargin{v+1};             
           end
       end
    end
    
    des_name    = result_struct.study_des.name;

    f1_name     = result_struct.study_des.variable(1).label;
    f1_levels   = result_struct.study_des.variable(1).value;

    f2_name     = result_struct.study_des.variable(2).label;
    f2_levels   = result_struct.study_des.variable(2).value;

    roi_names   = result_struct.roi_names;
    tw_names    = result_struct.group_time_windows_names;

    stat_type   = [result_struct.correction ':' num2str(p_thresh) ':' num2str(result_struct.num_permutations)];



    if isempty(f2_name)
        % one factor
%             name = [des_name ': ' f1_levels{1}];
%             for lvl=2:length(f1_levels)
%                name = [name ' - ' f1_levels ]; 
%             end
        contr_names = {'main effect'};
    else
        % two factors
        contr_names         = cell(1, length(f2_levels) + length(f1_levels) + 1);
        conditions_labels   = cell(1, length(f2_levels) + length(f1_levels));

        for lvl2=1:length(f2_levels)
            contr_names{lvl2}       = ['within ' f2_levels{lvl2}];
            conditions_labels{lvl2} = {f1_levels};
        end

        for lvl1=1:length(f1_levels)
            contr_names{length(f2_levels) + lvl1} = ['within ' f1_levels{lvl1}];
            conditions_labels{length(f2_levels) + lvl1} = {f2_levels};
        end

        contr_names{length(f2_levels) + length(f1_levels) + 1} = 'interaction';

    end

    fprintf(fp_full,'%s\r\n', '');
    fprintf(fp_full,'%s\r\n', ['parsing ' design_path]);
    fprintf(fp_full,'%s\r\n', '');
    fprintf(fp_full,'%s\r\n', design_separator);
    fprintf(fp_full,'%s\r\n', design_separator);
    fprintf(fp_full,'%s\r\n', des_name);
    fprintf(fp_full,'%s\r\n', design_separator);
    fprintf(fp_full,'%s\r\n', design_separator);
    fprintf(fp_full,'%s\r\n', '');
    fprintf(fp_full,'%s\r\n', '');
    fprintf(fp_full,'%s\r\n', stat_type);
    fprintf(fp_full,'%s\r\n', '');


    fprintf(fp_signif,'%s\r\n', '');
    fprintf(fp_signif,'%s\r\n', '');
    fprintf(fp_signif,'%s\r\n', design_separator);
    fprintf(fp_signif,'%s\r\n', design_separator);
    fprintf(fp_signif,'%s\r\n', des_name);
    fprintf(fp_signif,'%s\r\n', design_separator);
    fprintf(fp_signif,'%s\r\n', design_separator);
    fprintf(fp_signif,'%s\r\n', '');
    fprintf(fp_signif,'%s\r\n', '');        
    fprintf(fp_signif,'%s\r\n', stat_type);
    fprintf(fp_signif,'%s\r\n', '');        

    fprintf(fp_lat,'%s\r\n', '');
    fprintf(fp_lat,'%s\r\n', '');
    fprintf(fp_lat,'%s\r\n', design_separator);
    fprintf(fp_lat,'%s\r\n', design_separator);
    fprintf(fp_lat,'%s\r\n', des_name);
    fprintf(fp_lat,'%s\r\n', design_separator);
    fprintf(fp_lat,'%s\r\n', design_separator);
    fprintf(fp_lat,'%s\r\n', '');
    fprintf(fp_lat,'%s\r\n', '');        
    fprintf(fp_lat,'%s\r\n', stat_type);
    fprintf(fp_lat,'%s\r\n', ''); 
    
    
    for tw=1:length(tw_names)
        tw_name = tw_names{tw};

        fprintf(fp_full,'%s\r\n', '');
        fprintf(fp_full,'%s\r\n', tw_separator);
        fprintf(fp_full,'%s\r\n', tw_name);

        fprintf(fp_signif,'%s\r\n', '');
        fprintf(fp_signif,'%s\r\n', tw_separator);
        fprintf(fp_signif,'%s\r\n', tw_name);

        fprintf(fp_lat,'%s\r\n', '');
        fprintf(fp_lat,'%s\r\n', tw_separator);
        fprintf(fp_lat,'%s\r\n', tw_name);

        for roi=1:length(roi_names)
            roi_name = roi_names{roi};

            fprintf(fp_full,'%s\r\n', '');
            fprintf(fp_full,'%s\r\n', roi_separator);
            fprintf(fp_full,'%s\r\n', roi_name);

            fprintf(fp_signif,'%s\r\n', '');
            fprintf(fp_signif,'%s\r\n', roi_separator);
            fprintf(fp_signif,'%s\r\n', roi_name);

            fprintf(fp_lat,'%s\r\n', '');
            fprintf(fp_lat,'%s\r\n', roi_separator);
            fprintf(fp_lat,'%s\r\n', roi_name);
            
            if isempty(f2_name)     ... one factor

                % get stats
                df      = result_struct.dataroi(roi).dfcond;
                p       = result_struct.dataroi(roi).pcond_corr{1}(tw)/sub_correction;
                f       = result_struct.dataroi(roi).statscond{1}(tw);

                row1 = [contr_names{1} ': F=(1,' num2str(df) ')=' num2str(f) ', p=' num2str(p) ];

                % get mean & std of all levels of the factor
                row2 = [f1_levels{1} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_mean{1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_sd{1}{tw}) ];
                for lvl1=2:length(f1_levels)
                    row2 = [row2 ', ' f1_levels{lvl1} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_mean{lvl1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_sd{lvl1}{tw})];
                end

                fprintf(fp_full,'%s\r\n', row1);
                fprintf(fp_full,'%s\r\n', row2);

                row3 = [f1_levels{1} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_lat_mean{1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_lat_sd{1}{tw}) ', range=' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{1}{tw}(1)) ':' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{1}{tw}(2))];
                for lvl1=2:length(f1_levels)
                    row3 = [row3 ', ' f1_levels{lvl1} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_lat_mean{lvl1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_lat_sd{lvl1}{tw}) ', range=' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{lvl1}{tw}(1)) ':' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{lvl1}{tw}(2))];
                end                
                fprintf(fp_lat,'%s\r\n', row3);
                
                if p < p_thresh
                    fprintf(fp_signif,'%s\r\n', row1);
                    fprintf(fp_signif,'%s\r\n', row2);
                end                   

            else
                % two factors

                for lvl2=1:length(f2_levels)

                    df  = result_struct.dataroi(roi).dfcond;
                    p   = result_struct.dataroi(roi).pcond_corr{1,lvl2}(tw)/sub_correction;
                    f   = result_struct.dataroi(roi).statscond{1,lvl2}(tw);

                    row1 = [contr_names{lvl2} ': F=(' num2str(df(1)) ',' num2str(df(2)) ')=' num2str(f) ', p=' num2str(p) ];

                    % get mean & std of all levels of the factor
                    row2 = [f2_levels{lvl2} '-' conditions_labels{1}{1}{1} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_mean{lvl2,1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_sd{lvl2,1}{tw}) ];
                    for lvl1=2:length(f1_levels)
                        row2 = [row2 ', ' f2_levels{lvl2} '-' conditions_labels{lvl1}{1}{lvl1} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_mean{lvl2,lvl1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_sd{lvl2,lvl1}{tw})];
                    end                        

                    fprintf(fp_full,'%s\r\n', row1);  
                    fprintf(fp_full,'%s\r\n', row2);  
                    fprintf(fp_full,'%s\r\n', '');  
                    
                    % get mean & std of all levels of the factor
                    row3 = [f2_levels{lvl2} '-' conditions_labels{1}{1}{1} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_lat_mean{lvl2,1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_lat_sd{lvl2,1}{tw}) ', range=' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{lvl2,1}{tw}(1)) ':' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{lvl2,1}{tw}(2))];
                    for lvl1=2:length(f1_levels)
                        row3 = [row3 ', ' f2_levels{lvl2} '-' conditions_labels{lvl1}{1}{lvl1} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_mean{lvl2,lvl1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_sd{lvl2,lvl1}{tw}) ', range=' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{lvl2,lvl1}{tw}(1)) ':' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{lvl2,lvl1}{tw}(2))];
                    end                        
                    
                    fprintf(fp_lat,'%s\r\n', row3);  
                    fprintf(fp_lat,'%s\r\n', '');                     

                    if p < p_thresh
                        fprintf(fp_signif,'%s\r\n', row1);
                        fprintf(fp_signif,'%s\r\n', row2);
                        fprintf(fp_signif,'%s\r\n', '');
                    end                     
                end

                for lvl1=1:length(f1_levels)

                    df  = result_struct.dataroi(roi).dfgroup;
                    p   = result_struct.dataroi(roi).pgroup_corr{1,lvl1}(tw)/sub_correction;
                    f   = result_struct.dataroi(roi).statsgroup{1,lvl1}(tw);

                    row1 = [contr_names{length(f2_levels) + lvl1} ': F=(' num2str(df(1)) ',' num2str(df(2)) ')=' num2str(f) ', p=' num2str(p) ];

                    % get mean & std of all levels of the factor
                    row2 = [f1_levels{lvl1} '-' conditions_labels{length(f2_levels) + 1}{1}{1} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_mean{1,lvl1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_sd{1,lvl1}{tw}) ];
                    for lvl2=2:length(f2_levels)
                        row2 = [row2 ', ' f1_levels{lvl1} '-' conditions_labels{length(f2_levels) + lvl1}{1}{lvl2} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_mean{lvl2,lvl1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_sd{lvl2,lvl1}{tw})];
                    end                          

                    fprintf(fp_full,'%s\r\n', row1);  
                    fprintf(fp_full,'%s\r\n', row2);  
                    fprintf(fp_full,'%s\r\n', '');
                    
                    % get mean & std of all levels of the factor
                    row3 = [f1_levels{lvl1} '-' conditions_labels{length(f2_levels) + 1}{1}{1} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_lat_mean{1,lvl1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_lat_sd{1,lvl1}{tw}) ', range=' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{1,lvl1}{tw}(1)) ':' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{1,lvl1}{tw}(2))];
                    for lvl2=2:length(f2_levels)
                        row3 = [row3 ', ' f1_levels{lvl1} '-' conditions_labels{length(f2_levels) + lvl1}{1}{lvl2} ' = ' num2str(result_struct.dataroi(roi).datatw.extr_lat_mean{lvl2,lvl1}{tw}) ' +- ' num2str(result_struct.dataroi(roi).datatw.extr_lat_sd{lvl2,lvl1}{tw}) ', range=' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{lvl2,lvl1}{tw}(1)) ':' num2str(result_struct.dataroi(roi).datatw.extr_lat_range{lvl2,lvl1}{tw}(2))];
                    end                          
                    
                    fprintf(fp_lat,'%s\r\n', row3);  
                    fprintf(fp_lat,'%s\r\n', '');
                    

                    if p < p_thresh
                        fprintf(fp_signif,'%s\r\n', row1);
                        fprintf(fp_signif,'%s\r\n', row2);
                        fprintf(fp_signif,'%s\r\n', '');  
                    end    
                end

                df  = result_struct.dataroi(roi).dfinter;
                p   = result_struct.dataroi(roi).pinter_corr{1,3}(tw)/sub_correction;
                f   = result_struct.dataroi(roi).statsinter{1,3}(tw);                  

                row = [contr_names{length(f2_levels) + lvl1 + 1} ': F=(' num2str(df(1)) ',' num2str(df(2)) ')=' num2str(f) ', p=' num2str(p) ];
                fprintf(fp_full,'%s\r\n', row); 
                fprintf(fp_full,'%s\r\n', '');  

                if p < p_thresh
                    fprintf(fp_signif,'%s\r\n', row);
                    fprintf(fp_signif,'%s\r\n', '');                    
                end         
            end                
        end
    end
end