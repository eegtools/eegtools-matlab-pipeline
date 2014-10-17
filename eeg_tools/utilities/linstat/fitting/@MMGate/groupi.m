function i = groupi(g, mm)
%GROUPI converts gating group variable to an integer index of the named group.
%

% $Id: groupi.m,v 1.2 2006/12/26 22:53:07 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

i = g.group;
if isnumeric(g.group) 
    if ~all(g.group <= mm.k)
        error('FacsMM:Gate:BadGategroup', 'numeric groups must be equal or less than the number of classes');
    else
        return;
    end
else
    if ( iscellstr(g.group) || ischar(g.group) ) 
        [b i] = ismember( g.group, mm.knames );
        if ~all( b )
            error('FacsMM:Gate:BadGroup', 'groups must all be listed as cluster names');
        else
            return
        end
    end
end

error('FacsMM:Gate:BadGroup', 'invalid group');


