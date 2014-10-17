function d = mdummyx(x)
%MDUMMYX encode a design matrix for each unique crossed terms
%
% x is a set of integer grouping indices with each row specifying a unique
% combination of variables. 
%
% d is a design matrix encoding the interaction
% 
% Example:
%   icol = sortrows(ffact([2 2]));
%   % a sorted full-factorial design with 2 factors,2 levels each. 
%   d    = mdummyx( x );    % linear design matrix for each combo

% $Id: mdummyx.m,v 1.3 2006/12/26 22:53:18 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


[m,n] = size(x);
o = -cumsum([0 max(x(:,1:end-1), [], 1)]);
j = center(x,o);
dn = max(j(:,end));
j = j(:);

i = repmat( (1:m)', n, 1 );
i = i(:);



d = zeros( m, dn );

k = sub2ind( size(d), i, j );
d(k) = 1;

