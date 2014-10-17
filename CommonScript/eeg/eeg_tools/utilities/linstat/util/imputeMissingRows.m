function mat = imputeMissingRows( mat )
%IMPUTEMISSINGROWS 
%
% function mat = imputeMissingRows( mat )
% replace missing observations with the row average
% if entire row is missing it is replaced with the overall average
%
% Example
%   load popcorn
%   popcorn(7) = nan;
%   imputemissingrows(popcorn)
%
% see also impute

% $Id: imputeMissingRows.m,v 1.3 2006/12/26 22:54:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
[m, n] = size(mat);

% calculate means 
u = mgrpstats( mat');


% expand u to the same size as mat
u = repmat( u', 1, n );

% find missing values
k = isnan(mat);

% replace missing values with row mean
mat(k) = u(k);

% are any rows missing entirely?
j = all(k,2);

if any(j)
    % calculate overall mean (each row counts as 1 observations)
    % so take the mean of the row-wise nanmeans
    u = nanmean(u);
    mat(j,:) = u;   % set remaining missing values to overall mean
end;

