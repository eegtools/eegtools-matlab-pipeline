function cc = colorfulcube( M, creq, method )
%COLORFULCUBE produces useful colormaps
% 
% produces a colormap suitable for scatter, plot etc with M (linear) steps
% optionally stepping through points in the given colormap
%
%cc = colorfulcube( M )
% generate Mx3 color matrix spanning the current colormap
%
%cc = colorfulcube(M, creq)
% M is a scalar
% creq is an nx3 color matrix 
% returns cc, a M x3 color matrix interpolated from the given color matrix
%
% cc = colorfulcube(M, creq, method)
% method = method used to intporlate colors (passed ton interp1)
%
%Example
%       %redwash        
%       cc = colorfulcube( 64, [1 0 0; 1 1 1] );
%       cc = colorfulcube( 64, [1 0 0; 1 1 1]);
%       %redblackblue   
%       cc = colorfulcube( 64, [1 0 0; 0 0 0; 0 0 1], 'cubic' );
%       plot(cc);
%       % pick colors only from given map (don't interpolate)
%       cc = colorfulcube( 64, unique(lines,'rows'), 'nearest');
%       % select distinct colors from current map suitable for scatter
%       group_colors = colorfulcube( 4 );
%
% colorfulcube is implemented through interpolation which supports
% the optional methods 
%
% see also interp1


% $Id: colorfulcube.m,v 1.6 2006/12/26 22:54:06 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


if nargin < 2 || isempty(creq)
    creq = colormap;
end;

n = size(creq,1);               % size of current color palette
xi = linspace( 1, n, M);        % linearly space M points

if nargin == 3
    cc = interp1( 1:n, creq, xi, method );       % return colormap
else
    cc = interp1( creq, xi );       % return colormap
end

% make sure we have valid color map
cc(cc<0) = 0;       
cc(cc>1) = 1;
