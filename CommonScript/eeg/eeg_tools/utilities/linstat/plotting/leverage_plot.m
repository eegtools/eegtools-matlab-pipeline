function [h, lh] = leverage_plot( glm, varargin )
%LEVERAGE_PLOT 
%a leverage plot showing the leverage that each observation has on 
%the regression. points with high leverage effect the parameter estimates
%more than those with low leverage
%
%LEVERAGE_PLOT( glm );
% glm is a structure containing the field dmat, which is a design matrix 
% varargin are factors used for coloring, shaping and sizing as in mscatter
%
%LEVERAGE_PLOT( glm, varargin )
% varargin is passed to mscatter
%
% [H LH] = LEVERAGE_PLOT(...)
%   returns h, handles to the grouped data points, and lh, handles to the
%   legends
%
% Example
%   load carsmall;
%   glm = encode( MPG, [3 0], 2, Model_Year, Weight );
%   [h lh] = leverage_plot(glm, Model_Year(~glm.missing), [], Weight(~glm.missing) );
%   delete(lh(3));
%
%Reference
%   Kutner et al. Applied Linear Statistical Models. 
%
%
%I'm using the diagnol of the hatmatrix. the hatmatrix
%of A can be found by q*q', where q is the q from a q,r decomposition
%it is also the same as A*inv(A'*A)*A'. 

% $Id: leverage_plot.m,v 1.6 2006/12/26 22:53:26 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if isstruct( glm ) && isfield(glm, 'hatmat')
    hatmat = stats.hatmat ;
else
if isstruct( glm )
    A = glm.dmat;
else
    A = glm;
end;
    [q,r] = qr(A,0); %#ok
    hatmat = q*q';
end

leverage = diag(hatmat);

[th,lh] = mscatter( 1:length(leverage), leverage, varargin{:} );

xlabel('observation');
ylabel('leverage');
title('leverage plot');

%don't return handle unless asked for
if nargout >= 1
    h = th;
end;
