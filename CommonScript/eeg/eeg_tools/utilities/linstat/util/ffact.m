function a = ffact( q )
%FFACT full facorial design
%function a = ffact( v )
% v is a n-vector containing the number of factor levels for n factors
% a is a prod(v) x n matrix of integer indices representing factor level
% combinations
% 
% Example
%      a = ffact( [ 5 2 3] ); 

% $Id: ffact.m,v 1.3 2006/12/26 22:54:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
if ~isvector(q)
    error('linstats:ffact:InvalidArgument', 'input must be a vector');
end;

if any(q<1)
    error('linstats:ffact:InvalidArgument', ...
          'elements of input vector must be greater or equal one');
end;

m = prod(q);        % size
n = length(q);
p = cumprod(q);
r = p./q;
s = m./p;
a = zeros(m,n);
for i = 1:n
   
    b = repmat( (1:q(i)), r(i), s(i) );
    
    a(:,i)  = b(:);
end;
     
    
    