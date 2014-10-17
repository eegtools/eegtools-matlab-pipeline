function x = jitter( x, range )
% JITTER adds jitter (uniform noise) to the values in x.
%
% used as a visualization aid when plot has duplicate values of x
%
% xp = jitter(x,range)
% x is a m x 1 vector of doubles
% range is a scalar. noise will be in the interval [0,range]
%
%
% Example
% load carbig
% glm = encode( MPG, 3, 2, Origin, Cylinders );
% subplot(2,1,1)
% [ph, lh] = mscatter( Cylinders(~glm.missing), glm.y, Origin(~glm.missing), Origin(~glm.missing) );
% delete(lh(1:2));
% xlabel('Cylinders');
% title('without jitter')
% subplot(2,1,2)
% [ph, lh] = mscatter( jitter(Cylinders(~glm.missing), .5), glm.y, Origin(~glm.missing), Origin(~glm.missing) );
% title('with jitter');
% delete(lh(1:2));
% xlabel('Cylinders');

% $Id: jitter.m,v 1.2 2006/12/26 22:53:26 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin < 2
    range = .1;
end

x = x + rand( size(x))*range - range/2;

