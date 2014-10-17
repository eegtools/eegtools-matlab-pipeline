function [A names fi] = vec2array( y, varargin )
% VEC2ARRAY converts a vector to n-dim array
%
% Each dim of A corresponds to a factor, f(1),f(2),..f(i) in varargin 
% and each row of a side corresponding to a factor level within the
% corresponding f.
% If there are replicates of the same factor levels then an extra dimension
% is added to A. missing values are represented as nan
%
% Example
%   load carbig
%   A = vec2array( MPG, Cylinders, Model_Year, Origin );
%        produces a 5x13x7x23 array A containing the MPG
%         measured by each unique combination (sometimes called a cell) of
%       Cylinders, Model_Year, Origin
%   Abar = nanmean(A,4)
%        produces the means of cell
%   n  = sum(~isnan(A),4) 
%        produces the number of observations of each cell
%   [A names] = vec2array(...)
%       also returns names, a vector of cell arrays. Each cell array
%       contains the unique levels for the 2nd ... nth input variable
%   [A names fi] = vec2array(...)
%       also returns fi, a matrix of indices into names, so that
%       varargin is equivalent to ind2grp( fi, names{:} )after also 
%       converting numbers to strings and treating nans as equal
%
% See also
%   array2vec

% $Id
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin < 2 
    A = y;
    return;
end

% convert input arguments to 
[fi,names] = grp2ind( varargin{:} );
[B i j] = unique(fi, 'rows');

if ( size(B,1) ~= size(fi,1) )
    k   = numreps( j );
    dim = [max(fi) max(k)];
    fi = [fi k];
else
    dim = max(fi);
end

A = nan(dim);

c = mat2vec( fi );
i = sub2ind( dim, c{:} );

A(i) = y;
