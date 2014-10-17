function mm = setKnames( mm, cstr, i )
% SETKNAMES  assigns class names to each centroid
% Example   
%        mm = setKnames(mm, cstr );
%             cstr is a cell str of legnth k or
%             a character array with size(cstr,1) == k
%        mm = setKnames(mm, cstr, i );                   
%             sets the ith kname to cstr. 

% $Id: setKnames.m,v 1.2 2006/12/26 22:53:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com


if ~iscellstr(cstr)
    cstr = cellstr(cstr);
end
cstr = cstr(:);     %force into column vector
k = size(mm.b0.M,1);
if nargin < 3
    if length(cstr) ~= k
        error('linstats:Facs:setKnames', 'must be k names in cstr');
    end
    mm.knames = cstr;
elseif length(cstr) ~= 1 || ~isscalar(i) || i > k
        error('linstats:Facs:setKnames', 'must be k names in cstr');
else
    mm.knames(i) = cstr;
end    