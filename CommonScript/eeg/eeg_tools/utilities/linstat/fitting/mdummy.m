function [d, D] = mdummy(x, method)
% MDUMMY enodes integer index (grouping) variables into a design matrix
%
% [d, D] = mdummy(x, method)
% X is a vector grouping variable
%
% METHOD specifies an encoding method
%   method = 1:   0/-1/1 coding, full rank  (aka nominal)
%   method = 2:   0/1 coding, full rank     (aka ordinal)
%   method = 3:   0/1 coding, overdetermined
%
% d is encoded design matrix
% D is the unique listing of the design matrix. Each row represents the
% encoding of the corresponding integer index
%
% Example:
%   load carbig
%   [gi, gn] = grp2ind(Cylinders);
%   [d, D]   = grp2ind( gi );

% $Id: mdummy.m,v 1.7 2006/12/26 22:53:18 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


if (nargin < 2)
    method = 1;
end

n = length(x);
g = max(x);
ncols = g - (method ~= 3);

if ( g*ncols < 1000000 )

    if method == 1
        D = eye( [g ncols] );
        D(end,:) = -1;
    elseif method == 2
        D = tril(ones([g ncols]), -1);
    else
        D = eye( [g ncols] );
    end


    d = repmat(0, n, ncols);
    d( 1:n, :) = D(x,:);

else
    if method == 1
%         D = speye( [g ncols] );
%         D(end,:) = -1;
        error('linstats:mdummy:notSupported', 'sparse encoding using method 1 is not supported');
    elseif method == 2
%         D = tril(spones([g ncols]), -1);
        error('linstats:mdummy:notSupported', 'sparse encoding using method 2 is not supported');
    else
        d = sparse( 1:n, x, 1);
    end

end