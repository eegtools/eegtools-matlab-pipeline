function varargout = mat2vec( A )
%MAT2VEC  converts matrix of numbers to a list of numeric cell arrays
%
% data manipulation vector to separate columns of a matrix into vectors
%
%   [a b ... i] = mat2vec( A )  
%   A is an m x n matrix
%   if i == 1 (i.e. there is only one output, then columns of A
%       are converted into vectors and stored as elements of a cell
%   if n == i
%       a = A(:,1), b = A(:,2), ... i = A(:,i)
%   if n >= i assigns  
%      a = A(:,1),  b = A(:,2), ... i = { A(:,i) A(:,i+1), ... A(:,n) }
%   if cols is a scalar equal to k, k < i then the first k columns of A 
%   are listed. 
%
%Example
%   load popcorn
%   Y = mat2vec(popcorn);
%   plot( Y{1:2}, '+' );

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
n = size(A,2);

if nargin < 2
    for i = 1:nargout
        varargout{i} = A(:,i);
    end
    if n > nargout || nargout == 1;
        c = cell( 1, n - nargout + 1);
        for i = 1:n-nargout+1
            c{i} = A(:,i);
        end;
        varargout{nargout} = c;
    end
end;


        


    


