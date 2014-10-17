function [x,y] = getAxisInset( xp, yp )
% GETAXISINSET return coordinates for relative positions
%
% [x,y] = getAxisInset( xp, yp )
%     XP,YP are relative coordinates relative to lower left corner
%     RETURNS x,y the position (in axis units) from the upper left corner 
%     of the current axis
% 
% Example
% figure
% [x,y] = getAxisInset;
%  text(x,y,'lower left');
% [x,y] = getAxisInset( .1, .9);
%  text(x,y,'upper left');
% [x,y] = getAxisInset( .8, .1);
%  text(x,y,'lower right');
% [x,y] = getAxisInset( .8, .9);
%  text(x,y,'upper right');
%  


% $Id: getAxisInset.m,v 1.4 2006/12/26 22:53:25 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if (nargin == 0 )
    xp = .1;
    yp = .1; 
elseif ( nargin ==1 )
    yp = xp;
end;
    

x = get(gca, 'xlim')*[1-xp xp]';
y = get(gca, 'ylim')*[1-yp yp]';


