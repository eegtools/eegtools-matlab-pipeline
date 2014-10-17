function [i x] = gate( g, mm )
% GATE - applies this gate to the Mixture Model
%
% Example
%        [i x] = gate( g, mm )
%                g is a Gate object and MM is a MModel obj
%                the gate from g is applied to the results optimal 
%                fit of the data to mm
%        i is an index to the included rows in x 
%        x are the included points from x

% $Id: gate.m,v 1.2 2006/12/26 22:53:07 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

i      = true( size(mm.x,1),1 );
x      = mm.x;

if isempty(mm.x) || strcmp(g.type , 'none' );
    return;
end;




type   = g.type;
method = g.method;
sigma  = g.crit;
group  = g.group;
    
if isnumeric(group)
    k = false( size(mm.b0.M,1), 1 );
    k(group) = true;
elseif ~iscellstr(group)
    group = cellstr(group);
    k     = ismember( mm.knames, group );
end;


if all(k==0)
    error('facs:MModel:gate', 'cluster with give name does not exist');
end

crit   = sigma^2;

switch method
    case 1
       [mind2, closest] = min( mm.d2, [], 2 );
        i = ismember( closest, find(k) ) & any(mm.d2(:,k) < crit,2);
    case 3
        i = any(mm.d2(:,k) < crit,2);
    case 2
        [mind2, closest] = min( mm.d2, [], 2 );
        i = ismember( closest, find(k) );
    case 4
        k  = find(~ismember( mm.knames,'ignore' ));
        if ~isempty(k)
            % find points that are further than crit away than non-ignored
            i = ~any ( mm.d2(:,k) <= crit, 2 ) ;
        end
    case 5
        w = mmvn_pdf( mm.x(:,mm.s), getTheta(mm) );
        w(isnan(w)) = 0;
        [maxw, closest] = max( w, [], 2 );
        i = ismember(closest, find(k) );
    case 6
        w = mmvn_pdf( mm.x(:,mm.s), getTheta(mm) );
        w(isnan(w)) = 0;
        w = scale(w')';
        i = any( w(:,k)> sqrt(crit),2 ) ;
end

if strcmp( type, 'exclusion');
    i = ~i;
elseif ~strcmp(type, 'inclusion');
    error('facs:MModel:gate', 'bad gating type');
end;
    
if nargout > 1 
    x = mm.x(i,:);
end

