function dest  = paste( A, i, B )
%PASTE paste columns into a matrix
%
% inspired by the unix paste command, this function pastes columns of B
% into A. The results are returned in dest.
%
% dest = paste( A, i, B )
% A is a m x n matrix
% B is a m x p matrix. If absent, columns of NaN are inserted
% i is a vector of integer indices in the range (1..p) into A where the
% corresponding column of B will be copied.
% dest(:,i(k)) = B(:,k);
% if i is a scalar then the entire B is inserted at i.
% 
% Example
%   A = repmat( 'abcd', 10, 1 );
%   B = repmat( 1:3, 10, 1 );
%   dest = paste( A, 2:2:6, B );
%
% Example 
%   dest = paste( A, 3, B );
%

% $Id: paste.m,v 1.5 2006/12/26 22:54:11 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
[m,n] = size(A);

if (nargin < 3)
    B = nan(m,length(i) );
end

[mm,nn] = size(B);
if ( mm ~= m )
    error('linstats:paste:InvalidArgument', 'incompatible sizes. The B and destination matrices must have the same number of rows' )
end

if (length(i) == 1 && nn ~= 1)
    i = i:(i+nn-1);
elseif length(i) ~= nn 
    error('linstats:paste:InvalidArgument', 'incompatible sizes. There must be an index for every column in the B matrix');
end;


N = n + nn;

% allocate memory sufficient for final matrix
dest = nan( m, N );
dest(:,i) = B;
j = true( 1,N);
j(i) = false;
dest(:,j) = A;



