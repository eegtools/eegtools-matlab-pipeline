function L = getcontrasts( p, method )
%GETCONTRASTS returns a set of common constrasts. helper for lsconstrasts
%
%Contrasts are used to test whether whether combinations of coefficient 
%sum to zero
%
%Example
%   L = getcontrasts( p, method )
%       p is a scalar of the number of elements to contrast
%       method is a scalar indicating which type of contrast to build
%       1 = all pairwise (default) 
%           compares each combinations of pairs of levels
%       2 = adjacent pairs  compare each level i+1 - i
%       3 = baseline        compare each level i to level 1
% returns L, a set of contrasts for the given term.
%
%Example
%   compare MPG for various number of cylinder cars
%   load carbig
%   glm = encode(MPG, 3, 1, Cylinders);
%   L   = getcontrasts( length(c), 1 );
%   [u s] = lscontrast(glm, 1, L );
%   jplot_table( estimates_table(s) );
%
%See also lscontrast, coeff2eqn


% $Id: getcontrasts.m,v 1.5 2006/12/26 22:53:15 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if (nargin < 2 || method == 1)
    t = nchoosek( 1:p, 2 );
elseif method == 2
    t = zeros(p-1,2);
    t(:,1) = 1:p-1;
    t(:,2) = t(:,1) + 1;
elseif method == 3
    t = zeros(p-1,2);
    t(:,1) = 1;
    t(:,2) = 2:p;
end

m = size(t,1);
L = zeros( p, m);
i = sub2ind( size(L),  t, [(1:m)' (1:m)'] );
L(i(:,1)) = -1;
L(i(:,2)) = 1;

