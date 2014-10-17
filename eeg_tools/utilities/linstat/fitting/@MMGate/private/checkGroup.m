function group = checkGroup(group, mm)
%CHECKGROUP - internal function to error check group for class MMGate
%
% checkGroup(obj)

% $Id: checkGroup.m,v 1.3 2006/12/27 16:17:41 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

if isnumeric(group) 
    if ~all(group <= mm.k)
        error('FacsMM:Gate:BadGategroup', 'numeric groups must be equal or less than the number of classes');
    else
        return; % ok
    end
else
    if ( iscellstr(group) || ischar(group) ) 
        if ~all( ismember( group, mm.knames ) )
            error('FacsMM:Gate:BadGroup', 'groups must all be listed as cluster names');
        else
            return;
        end
    end
end

error('FacsMM:Gate:BadGroup', 'invalid group');


