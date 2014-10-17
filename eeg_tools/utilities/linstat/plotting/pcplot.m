function [hh,lh] = pcplot( scores, latent, varargin )
%PCPLOT plots principal components colored by explanatory factors
%
%function [h lh] = pcplot( scores, latent, varargin )
%  plots the first two principal components and
%  labels the groups according to varargin 
%  varargin arguments are passed to mscatter
%  if present they will effect the color, shape and size (in that order)
%  of each point in the plot
%
%Example
%    X = [MPG Acceleration Weight Displacement];
%    i = ~any(isnan(X),2);  %find present values
%    X = zscore(X(i,:));
%   [coeff, score, latent] = princomp( X );
%    pcplot( score,latent, Cylinders(i,:), Origin(i,:)   );
%
% See also mscatter

% $Id: pcplot.m,v 1.10 2006/12/26 22:53:27 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


[h lh] = mscatter( scores(:,1), scores(:,2), varargin{:} );
axis equal

if nargin < 2 || isempty(latent)
    latent = var(scores);
end;

pe = latent*100./sum(latent);

xlabel( sprintf( 'PC 1 (%2.1f%% explained) ', pe(1) ));
ylabel( sprintf( 'PC 2 (%2.1f%% explained) ', pe(2) ));
title( 'PC plot');
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



