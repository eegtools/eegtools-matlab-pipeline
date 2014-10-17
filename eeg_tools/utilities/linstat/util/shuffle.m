function s = shuffle( d )
%SHUFFLE randomize rows of a matrix
%
%s = shuffle( d )
% d is a m x n matrix
% s is a new m x n matrix with the same rows of d in a random order
%
%Example
%   d = [1:10;10:-1:1;1:10]';
%   shuffle(d)

% $Id: shuffle.m,v 1.4 2006/12/26 22:54:13 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% '

m = size(d);

%create random order
[ignore, i] = sort( rand( m, 1 ) );

s = d(i,:);

