function [y] = zt(x, dim)
% funzione per z-tasformare, prende vettori o matrici mxn. se input sono
% matrici, si può sceliere se z trasformare lungo le righe (1) o le  colonne (2)

y = [];

if nargin==1,
    % Determine which dimension SUM will use
    dim = find(size(x)~=1, 1 );
    if isempty(dim), dim = 1; end
    
    y = (x-mean(x))/std(x);
else
    y = x;
    
    [tr tc] =  size(x);
    
    if dim == 1
        for nr = 1:tr
            y(nr,:) = (x(nr,:)-mean(x(nr,:)))/std(x(nr,:));
        end
    elseif dim == 2
        for nc = 1:tc
            y(:,nc) = (x(:,nc)-mean(x(:,nc)))/std(x(:,nc));
        end
    else
        disp('error input a matrix m x n with m and n < 3');
        return
    end
    
end
