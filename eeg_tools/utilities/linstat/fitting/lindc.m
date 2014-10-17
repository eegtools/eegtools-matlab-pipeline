function b = lindc( A, tol )
%LINDC returns the linear dependent columns of A
%Example
% function b = lindc( A )
% looks for linearly dependent columns of A
% and returns a matrix b so that
%   A*b = A;
% If A is full rank, then b is the identity matrix
% otherwise there is at least one column vector of
% of A that can be expressed, say A(:,j), that can be expressed as a linear
% combination of the preceeding independent vectors in A(:,1..j-1).
% The coefficients in B are zero for all dependent vectors in A.

% $Id: lindc.m,v 1.6 2006/12/26 22:53:16 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin < 2
    tol = max(size(A)) * eps(norm(A));
end

n = size(A,2);
% linearly independent columns
j = true( n, 1 ); 
% coefficient matrix
b = eye( n );

% if full rank then return
if ( rank(A, tol) == n ); return; end;

   
for i = 2:n

    % get independent columns 1..i
    cols = false(n, 1 );
    cols( 1:i ) = j(1:i);
    
    % rank of subset
    r = rank(A(:, cols ), tol);
    
    % if full rank continue
    if ( r >= sum(cols) ); continue; end;
    b(:,i) = 0;     % set diagnol to 0
    
    % set ith bit to false
    j(i) = false;
    

    %optionally solve for coefficients b, where
    %A(:,cols)*b = A(:,i);

    y = A(:,i);
    k = cols(1:i-1);
    b(k,i) = A(:,k)\y;
end;


% make values near 0,1,-1 exact
b( b.^2 < eps ) = 0;
b( (1-b).^2 < eps ) = 1;
b( (1+b).^2 < eps ) = -1;
   
    
    
    
    

