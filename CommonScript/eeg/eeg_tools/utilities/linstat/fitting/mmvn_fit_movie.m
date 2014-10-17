function fout = mmvn_fit_movie( X, Opt, L, oldh ) %#ok input args by convention
%MMVN_FIT_MOVIE callback function for mmvn_fit. 
%
% Example:
% [X idx theta] = mmvn_gen( 1000, [0 5; 5 0; 5 5; 0 0] );
% Init.OutputFcn = @mmvn_fit_movie;
% figure
% gscatter( X(:,1), X(:,2), idx); 
% drawnow; pause(1);
% hold on;
% mmvn_fit( X, 4, theta,Init );

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com



h = ellipse( Opt.M, Opt.V, [1 2] );
set(h(:,1), 'linewidth', 3);
drawnow

if nargin == 4
    delete( oldh(:) );
end

pause(.3);
fout = h;