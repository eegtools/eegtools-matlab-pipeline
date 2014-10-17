function s = viewToModelDims( v, viewdims )
%VIEWTOMODELDIMS maps view dimensions to model dimensions
%
% convert the viewed dimensions to model dimensions. If the view is
% outside the model an error is thrown
% 
% Example
%       s = viewToModelDims( v )
%           returns a k x 1 vector of integer indices into the model that
%           are currently being viewed
%
%       s = viewToModelDims( v, dims )
%           maps the given dimesniosn to to model dimensions

% $Id: viewToModelDims.m,v 1.3 2006/12/23 18:41:19 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin < 2
    viewdims = v.dims;
end

% dimensions to merge
s         = v.mm.s;         % model dimensions
g(s==1)   = 1:sum(s);
g(end+1)  = -1;

viewdims(viewdims<1 | viewdims > length(g)-1 ) = length(g);
s         = g(viewdims);      

if any(s<1) 
    error( 'MMView:viewToModelDims:IndexOutOfBounds', 'viewdimensions are outside of model');
end