function [os_ver, os_bit, matlab_ver, matlab_bit, matlab_tlbx] = get_pc_settings()


    %% OS VERSION & BIT
    osv    = system_dependent('getos');
    
    if ~isempty(strfind(osv, 'Linux'))
        os_ver = 'Linux';
        
        if ~isempty(strfind(osv, 'x86_64'))
            os_bit = '64';
        else
            os_bit = '32';
        end            
        
    elseif ~isempty(strfind(osv, 'Win'))
        
        os_ver = 'Windows';

        if ~isempty(strfind(osv, 'XP'))
            os_bit ='32';
        else
            
            [status,str] = system('wmic OS get OSArchitecture');
            idx = find(double(str)==10, 1,'first');
            if strcmp(str(idx + 1:idx + 2),'64')
                os_bit = '64';
            else
                os_bit = '32';
            end
        end
        else
        os_ver = 'Mac';        
        os_bit = '64';
    end

    %% MATLAB VERSION
    matlab_ver = computer('arch');  
    
    %% MATLAB BIT
    if ~isempty(findstr('64',matlab_ver))
        matlab_bit = '64';
    else
        matlab_bit = '32';
    end

    %% MATLAB TOOLBOXES    
    tlbx_cnt = 0;
    v = ver;
    for vid=1:length(v)
        if strcmp(v(vid).Name, 'MATLAB')
            matlab_ver = v(vid).Version;
        else
            tlbx_cnt                = tlbx_cnt + 1;
            matlab_tlbx(tlbx_cnt)   = v(vid);
        end
    end
    if ~isstruct(matlab_tlbx)
        matlab_tlbx = [];
    end

end