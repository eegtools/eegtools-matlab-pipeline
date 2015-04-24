function output = find_long_steps(input,  varargin)

% data una funzione a gradini, tiene solo quelli che hanno una durata
% superiore ad un minimo fissato in un numero di campioni
% curve          = input.curve;
% min_duration   = input.min_duration; % in samples





% ESTRARRE LIMITI TW (ANCHE SINGOLI)


curve          = input.curve;
min_duration   = input.min_duration; % in samples


lc             = length(curve);
output         = nan(size(curve));
ind_out        = 1:length(output);


twmat      = [];
stepvec    = find(curve>0);

ini        = min(stepvec);
fin        = max(stepvec);




% fisso il candidato all'inizio del primo step l'indice del primo elemento
% >0

if not(isempty(ini))
    
    ind1    =  ini;
    ind2    =  ind1;
    ntw     =  1;
    
    while (ind1 <= fin && ind2 <= fin)        
        
        ind2_temp = ind2;        
        sbulacco1 = 0;
        sbulacco2 = 0;
        
        while (curve(ind2_temp) > 0 && not(sbulacco1) && not(sbulacco2))
            if ind2_temp < lc
                if curve(ind2_temp+1) > 0 && curve(ind2_temp) > 0
                    ind2_temp = ind2_temp+1;
                end
                if ind2_temp+1 < lc
                if not(curve(ind2_temp+1)> 0)  && curve(ind2_temp) > 0
                    sbulacco2=1;
                end
                end
            else
                ind2_temp = lc;
                sbulacco1  = 1;
            end
        end
        
        if sbulacco1
            ind2 = lc;
        else
            if sbulacco2
                ind2 = ind2_temp;
            else
                ind2 = ind2_temp-1;
            end
        end
        
        dind = ind2-ind1+1;
        
        if dind >= min_duration
            twmat(ntw,:) = [ind1, ind2];
            ntw = ntw+1;
        end
        
        ind1_temp = ind2+1;
         
        if ind1_temp > lc
            sbulacco = 1;
        else
            sbulacco = 0;
        end
        
        if not(sbulacco)
            while (not(curve(ind1_temp)> 0) && not(sbulacco))
                
                if ind1_temp < lc
                    ind1_temp = ind1_temp+1;
                else
                    sbulacco = 1;
                end
            end
        end
        
        ind1    = ind1_temp;
        ind2    = ind1;
    end
    
    for ntw = 1:size(twmat,1)
        output(ind_out >= twmat(ntw,1)    & ind_out <= twmat(ntw,2)) =1;
    end    
end
end