function [means, v, gn, sx, sx2, labels] = mgrpstats( x, g )
%MGRPSTATS univariate summary statistics stratified by group
%
%[means, v, gn, sx, sx2, labels] = mgrpstats( x, g )
% x is a m*n matrix. nans are ignored
% g is a grouping variable of length m. it can be integer, char or cellstr
% means - mean for each group
% v     - variance for each group
% gn    - number of present observations for each groups
% sx    - sum of the xs for each group
% sx2   - sum of squares for each group
% labels - levels of grouping variable g in the same order as the above
%          statisitics
%
% Example
%  load carbig
%  X = [MPG Acceleration Weight Displacement];
%  [u,v,gn,sx,sx2,labels] = mgrpstats( X, Cylinders);
%  table( {'Cylinders' 'MPG' 'Acc', 'Weight', 'Disp'}, labels, u );
%
% See also mgrpcov

% $Id: mgrpstats.m,v 1.7 2006/12/26 22:54:11 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if ( nargin < 2 )
    idx = ones( size(x,1), 1);
    labels = 1;
else
    if isvector(g), g = g(:); end;
    [idx,labels] = grp2ind(g);
end
[m,n] = size(x);

%transpose x if it makes more sense
if ( m ~= length(idx) ) 
     error('linstats:mgrpstats:InvalidArgument', 'g must have the same number of elements as there are rows in x'); 
end;    

m     = length(labels);
sx    = nan( m, n );
sx2   = nan( m, n );
gn    = nan( m, n );


for i = 1:m
    j = idx == i;

    % copy of relevant rows of x
    tmp = x(j,:);
    % find nans
    k = isnan( tmp );
    % set to zero
    tmp(k) = 0;

    % calc sum
    sx(i,:)  = sum ( tmp,1 );
    
    % count number of elements that aren't NaN
    gn(i,:) = sum(~k,1);

    
    % calc sum x.*x
    sx2(i,:) = sum ( tmp.^2,1 );
end;

gn(gn == 0 ) = NaN;
means = sx./gn;

gn(gn==1) = NaN;
v = ( sx2 - (sx.*sx)./gn )./(gn-1);

    
    
    