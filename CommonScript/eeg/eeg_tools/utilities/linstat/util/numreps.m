function k = numreps( Y )
%NUMREPS returns a unique replicate number for an observation 
%
% K = NUMREPS(Y)
% 
% Y is a N x 1 vector of integer grouping variables in the range i = 1..k
% where level i occurs n(i) times
%
% K is a N x 1 matrix of counts of the number of times that the
% corresponding level of Y has been observed in the preceeding rows of data 
%
% Example
%   load carbig
%   k = numreps( grp2ind(Cylinders));

% $Id: numreps.m,v 1.2 2006/12/26 22:54:11 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

N = size(Y,1);
i = max(Y);

n = zeros(i,1);

k = nan(N,1);

for j = 1:N
    y = Y(j);
    n(y) = n(y)+1;
    k(j) = n(y);
end;
    
