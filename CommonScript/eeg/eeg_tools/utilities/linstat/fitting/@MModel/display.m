function tbl = display(mm, varnames)
%DISPLAY Display a table of centroid means for MModel objects
%
%    DISPLAY(OBJ) displays information pertaining to the MModel object.
%
  
% $Id: display.m,v 1.2 2006/12/26 22:53:09 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

theta = mm.bhat;
txt = {'opt means'};
if isempty(theta)
    theta = mm.b0;
    txt   = {'means'} ;
end;

if isempty(theta)
    tbl = [];
    return;
end

if nargin < 2
    txt = [txt 'freq' cellstr(num2str(find(mm.s(:))))']';
else
    labels = varnames(mm.s);
    txt = [txt 'freq' labels(:)'];
end;

tbl = table( txt,  mm.knames, theta.W, theta.M );

if nargout==0
    disp(tbl)
end