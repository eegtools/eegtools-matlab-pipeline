function factors = ind2grp( gi, varargin )
% IND2GRP recreates factors from dummy variables and labels
%
% This function is the reciprocal of grp2ind, except
% that factors is always a includes a cell array of strings 
% 
% USAGE
% function factors = ind2grp( gi, varargin )
%
% example
%   [fi,fn] = grp2ind( factors{:} );
%   factors = ind2grp( fi, fn{:}  );
%
% example - delete duplicate rows from a dataset
%   [fi, fn] = grp2ind( f1, f2, f3 ); % f1,f2,f3 are numbers of cellstr
%   a        = unique( fi, 'rows' );     % unique combinations
%   factors  = ind2grp( a, fn{:} );      % recreate unique dataset

% $Id: ind2grp.m,v 1.1 2006/12/26 22:54:14 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

q = length(varargin);
factors = cell(q,1);
F = cell( size(gi,1), 1 );
for i = 1:q
    f = varargin{i};            % ith set of labels
    q = gi(:,i);                % convenience
    k = ~isnan(q);              % find missing values
    F(k) = f(q(k));             % build factors
    F(~k) = {''};                 % replace missing values with empty strings
    factors{i} = F;
end
    