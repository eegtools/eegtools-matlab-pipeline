%% function get_stats_in_folder(input_result_folder, output_filename, varargin)
% parse a folder for design results folders
% open mat files, get stats value and print them to a file
%
% VARARGIN INPUTs
% list_windows_names :  {'P100', 'N330', etc...}
% list_subjects : {'aa', 'bb', ...etc}
%
% OUTPUT:
% a text file 


function get_stats_in_folder(input_result_folder, output_filename, varargin)


    if nargin < 1
           help get_stats_in_folder;
           return;    
    end;
    
    %% header text
    design_separator    = '% ======================================================================';
    new_line            = '';
    tw_separator        = '% -----------------------------------------------------------------------';
    roi_separator       = '% ---------';
    header_text         = 'stat results of folder:';
    sub_correction      = 1;
    p_thresh            = [];
    
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


    
    %% output file definition
    full_stats_file     = fullfile(input_result_folder, output_filename);
    [path, name, ext ]  = fileparts(full_stats_file);
    signif_stats_file   = fullfile(input_result_folder, [name '_signif.txt']);
    lat_stats_file      = fullfile(input_result_folder, [name '_latencies.txt']);
    
    fp_full             = fopen(full_stats_file, 'w');
    fp_signif           = fopen(signif_stats_file, 'w');
    fp_lat              = fopen(lat_stats_file, 'w');
    
    fprintf(fp_full,'%s\r\n', header_text);
    fprintf(fp_full,'%s\r\n', input_result_folder);    
    fprintf(fp_full,'%s\r\n', design_separator);
    fprintf(fp_full,'%s\r\n', design_separator);    
    
    fprintf(fp_signif,'%s\r\n', header_text);
    fprintf(fp_signif,'%s\r\n', input_result_folder);  
    fprintf(fp_signif,'%s\r\n', design_separator);
    fprintf(fp_signif,'%s\r\n', design_separator);    

    fprintf(fp_lat,'%s\r\n', header_text);
    fprintf(fp_lat,'%s\r\n', input_result_folder);  
    fprintf(fp_lat,'%s\r\n', design_separator);
    fprintf(fp_lat,'%s\r\n', design_separator);    
    
    %% get MAT files
    design_folders = dir(input_result_folder);
    num_des=0;
    mat_files = {};
    for fld=1:length(design_folders)
        if (design_folders(fld).isdir == 1 && (~strcmp(design_folders(fld).name, '.') && ~strcmp(design_folders(fld).name, '..')))
            
            des_path = fullfile(input_result_folder, design_folders(fld).name);
            mats = dir(fullfile(des_path, '*.mat'));
            if length(mats) == 1
               num_des = num_des + 1;
               mat_files{num_des} = fullfile(des_path, mats(1).name);
            else
                disp('more than one mat file is present');
            end
        end
    end
    
    %% Parse MAT files
    for des = 1:num_des
        
        load(mat_files{des});
        if  exist('erp_curve_roi_stat','var')
            get_erp_stats(erp_curve_roi_stat, mat_files{des}, fp_full, fp_signif, fp_lat, 'sub_correction', sub_correction, 'design_separator', design_separator, 'tw_separator', tw_separator, 'roi_separator', roi_separator, 'p_thresh', p_thresh);
        elseif exist('erp_compact','var')
            erp_compact.erp_topo_stat.study_ls = erp_compact.erp_curve_roi_stat.study_ls;
            erp_compact.erp_topo_stat.num_permutations = erp_compact.erp_curve_roi_stat.num_permutations;
            erp_compact.erp_topo_stat.correction = erp_compact.erp_curve_roi_stat.correction;
            get_erp_stats(erp_compact.erp_topo_stat, mat_files{des}, fp_full, fp_signif, fp_lat, 'sub_correction', sub_correction, 'design_separator', design_separator, 'tw_separator', tw_separator, 'roi_separator', roi_separator, 'p_thresh', p_thresh);
        else
            display('ERROR: missing data in the mat file!!!!')
            return;
        end
    end
        
    fclose(fp_full);
    fclose(fp_signif);
end