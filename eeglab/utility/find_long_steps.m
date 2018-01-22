function output = find_long_steps(input,  varargin)

% data una funzione a gradini, tiene solo quelli che hanno una durata
% superiore ad un minimo fissato in un numero di campioni
% curve          = input.curve;
% min_duration   = input.min_duration; % in samples





% ESTRARRE LIMITI TW (ANCHE SINGOLI)


curve          = input.curve;
min_duration   = input.min_duration; % in samples


% lc             = length(curve);
output         = nan(size(curve));
% ind_out        = 1:length(output);


stepvec    = find(curve>0);

lsv = length(stepvec);






% fisso il candidato all'inizio del primo step l'indice del primo elemento
% >0

if lsv
    
    output0 = zeros(size(output));
    
    
    for nn = 1:lsv
        
        ini = stepvec(nn) - min_duration/2;
        fin = stepvec(nn) + min_duration/2;
        
        sel = stepvec >= ini & stepvec <= fin;
        
        selint = stepvec(sel);
        if not(isempty(selint))
            i1 = min(selint);
            i2 = max(selint);
            output0(i1:i2) = 1;            
        end        
    end
    
    dd = diff(output0);
    
    ii = find(dd == 1);
    ff = find(dd == -1);
    
    
    
    for mm = 1:length(ff)
        rr = ff(mm) - ii(mm);
        
        if rr >= min_duration
            output(ii(mm):ff(mm)) = 1;
        end
        
    end
    
    if length(ff)<length(ii) 
        output(ii(mm+1):end) = 1;
    end
    
end

    
    
end