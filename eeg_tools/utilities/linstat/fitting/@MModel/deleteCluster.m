function mm = deleteCluster( mm, k )
% DELETECLUSTER - delete the kth cluster from the mixture model
%
% Example
%   [X idx theta] = mmvn_gen( 1000, [0 5; 5 0; 5 5; 0 0] );
%   mm = MModel( X, [], 5); %model with 5 components
%   mm = deleteCluster(mm,5);   % delete the 5th component

% $Id: deleteCluster.m,v 1.2 2006/12/26 22:53:09 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

b0 = getTheta(mm);

b0.M(k,:)   = [];
b0.V(:,:,k) = [];
b0.W(k)     = [];
b0.W        = scale(b0.W);

if ~isempty( b0.h0 )
    b0.h0(k,:) = [];
end

if ~isempty( b0.v0 )
    b0.v0(k,:) = [];
end;

mm.knames(k)   = [];

mm = setTheta(mm, b0);
