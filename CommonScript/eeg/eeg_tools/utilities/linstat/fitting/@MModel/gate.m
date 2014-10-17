function [i x] = gate( mm, group, sigma, method, type)
% GATE - extracts rows of x that meet gating criteria
%
% example
%      [i x] = gate( mm, group, sigman, method, type)
%        group is the name of clusters to find (target clusters) or an
%        integer specify the groupth cluster
%        sigma is a threshold mahalonobis distance (not d2)
%        method is one an integer specifying a method
%           1   finds all points within sigma^2 that are neaerest target
%           2   finds all points that are closest to a target cluster 
%           3   finds all points with sigma^2 of target clusters
%           4   finds all points that are farther than sigma^2 of all 
%               non-ignored clusters 
%           5   finds points that are most likely in the target cluster
%        type is a string equal to 
%           'exclusion'     exclude the points found
%           'inclusion'
%       returns i a boolean vector of the points passing through the gate
%       and x the gated points
%               
%     [i x] = gate( mm, gate )
%             gate is a structure containing the fields: k, crit, method,
%             type

% $Id: gate.m,v 1.2 2006/12/26 22:53:09 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

% default is to keep all;
i      = true( size(mm.x,1),1 );
x      = [];

if isempty(mm.x)
    return;
end;

if isstruct( group )
    type   = group.type;
    method = group.method;
    sigma  = group.crit;
    group  = group.group;
end;
    
if isnumeric(group)
    k = false( size(mm.b0.M,1), 1 );
    k(group) = true;
elseif ~iscellstr(group)
    group = cellstr(group);
    k     = ismember( mm.knames, group );
end;


if isempty(k)
    error('facs:MModel:gate', 'cluster with give name does not exist');
end

if isempty(mm.bhat)
    % could optimize it
    error('facs:MModel:gate', 'no optimized fit');
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
        w = mmvn_pdf( mm.x(:,mm.s), mm.bhat );
        w(isnan(w)) = 0;
        [maxw, closest] = max( w, [], 2 );
        i = ismember(closest, find(k) );
end

if strcmp( type, 'exclusion');
    i = ~i;
elseif ~strcmp(type, 'inclusion');
    error('facs:MModel:gate', 'bad gating type');
end;
    
if nargout > 1
    x = mm.x(i,:);
end

