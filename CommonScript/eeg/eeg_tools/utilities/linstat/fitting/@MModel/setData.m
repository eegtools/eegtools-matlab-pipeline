function mm = setData( mm, x )
% SETDATA set or clears the data from a mixture model. 
%
% setting a new data matrix reset the optimized parameters 
% 
% example
%       mm = setData( mm, x )
%          x is an m x n matrix
%          if mm.s is set, then x must be compatible, otherwise all n are
%          used in the model
%          
%       mm = setData( mm, [] )
%          removes data and derived mahalonbis distances from the mm
%          this is convient for more compact storage of the results of a
%          fit

% $Id: setData.m,v 1.2 2006/12/26 22:53:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com


mm.d2   = [];

if nargin < 2 || isempty(x)
    mm.x = [];
    return;
end;

mm.L    = [];
mm.bhat = [];
mm.u    = [];

mm.x = x;
n = size(x,2);

if isempty(mm.s)           % x is being set for the first time and no
    mm.s = true(n,1);   % use all dimensions 
    mm   = setTheta(mm, repmat(x,mm.k,1), repmat(cov(x),[1 1 k]), ones(k,1)/k );
elseif n ~= length(mm.s)
    error('linstats:Facs:setTheta', 'parameter structure is incosistent with model dimensions');
else
    mm.bhat  = [];
    mm.u     = weightedMeans( mm );
    mm.d2    = mah(mm );
end



