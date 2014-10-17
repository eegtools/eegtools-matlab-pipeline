function method = checkMethod(method)
%CHECKTYPE - check gate type for class MMGate
%
% checkType(obj)

% $Id: checkMethod.m,v 1.5 2006/12/27 16:17:41 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

% TODO make a binary encodying for these so that combinatiosn acan be
% easily made

methods = {                                         
    'nearest and distance'                          
    'nearest'                   % based on mah      
    'distance'                  % mah < crit        
    'unclustered'               % 
    'most likely'               % based on prob     
    'probability'               % prob > crit       
    };

if isnumeric( method ) && isscalar(method) && ...
        method >=1 && method <= length(methods)
    return
elseif iscellstr(method) || ischar(method)
    method = char(method);
    [b method] = ismember( method, methods );
    if isempty(method) || method == 0
        error('FacsMM:Gate:BadGateType', '%s\n', 'unsupported method', 'available methods:', methods{:} );
    end
else
    error('FacsMM:Gate:BadGateType', 'method must must a scalar cellstr or char');
end


