function [hh,lh] = cvplot( m, term, varargin )
% CVPLOT plots the canonical variables from a multivariate analysis
%
% canonical variables are a linear combination of responses that are
% maximally correlated with the explanatory terms in the model. These are
% scaled so that the within group variance is one. The axis are labeled
% with percent explained calculated from the the sum of the varianceof the
% canonical scores, not the total variance
%
% [h lh] = cvplot( m, term, varargin )
% M        is the results from manova
% TERM     specifies which term of the model to plot (default is 1)
% VARARGIN is passed to mscatter
% 
% returns
% H a handle to the groups of data points (see mscatter)
% LH a handle to the legends
% 
% Example
%  load carbig;        % load data
%   X = [MPG Acceleration Weight Displacement]; % response variables
%   glm = encode( X, 3, 1, Origin, Cylinders );  % Origin is explanatory variable
%   m   = manova( glm );                        % manova    
%   [h, lh] = cvplot(m, 1, Cylinders(~glm.missing), Origin(~glm.missing,:) );
%   set(lh(2), 'location', 'southwest');
% See also manova, mscatter

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin < 2 || isempty(term)
    term = 1;
end;

scores = m.canon(:,:,term);
latent = var(scores);


[h lh] = mscatter( scores(:,1), scores(:,2), varargin{:} );
axis equal

pe = latent*100./sum(latent);

xlabel( sprintf( 'CV 1 (%2.1f%% explained) ', pe(1) ));
ylabel( sprintf( 'CV 2 (%2.1f%% explained) ', pe(2) ));
title( 'CV plot');
grid on;


for i = 1:nargin-2
    lname = deblank( inputname(i+2) );
    if isempty(lname)
        lname = 'x1';
    end;
    if ~isnan(lh(i))
        set(lh(i), 'xticklabel', lname );
    end;
end;

if nargout > 0
    hh = h;
end;

