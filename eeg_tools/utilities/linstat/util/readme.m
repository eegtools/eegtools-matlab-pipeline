% For this file assume
% A,B are arrays
% u,v are vectors
% C is a cell array

readme.m	% this file

% used by linstats
grp2ind.m	% improved version of matlab's grp2idx.m
center.m	% subtract v from each row of A
scale.m		% divide   v from each row of B 
table.m		% build a table from  mixture of A v and C 
num2ord     % converts a number like 2 to text like 2nd
colorfulcube.m	% find a "good" spectrum of colors for n objects
bincalc.m	% calculate a "good" number of bins for continuous data
indexof.m	% find first occurence of v(i) in A for all i. Use matlabs ismember instead
isdiscrete.m %heuristic to determin with v or C is discrete or continuous


% perhaps useful 
mah.m		% mahalonobis distances from one or more multivariate gaussians. 
tail.m		% last lines of A, v or C
head.m		% first few lines of A, v or C
export.m	% export a table to a file
export_table.m	% another interface to export
isnested.m	% is one factor a subset of another	
paste.m		% paste columns of A into B at specified locations
shuffle.m	% random shuffle of rows in A
swap.m		% swap two variables
rad2deg.m	% converts radians to degrees
deg2rad.m	% converts degress to radians
mrange.m    % improved version of matlab's range
nanzscore.m	% improved version of matlab's zscore
mgrpstats.m	% group mean and other statistics for each column of A (see also gmean)	
svd_filter.m	% uses svd to compress (or smooth) A. 
fexact.m		% fisher exact test (hypergeometric cdf)
findMode.m		% finds the modes of the estimated distribution of v


% obscure
ind2subl.m	% convert indices from upper triangular to rectangular
tri2sqind.m	% same as above
sqform.m	% converts a vector representation of ut matrix to square form	
fan_table.m		% standardized tbl for factor analysis
imputeMissingRows.m	% imputes missing values in an unsophisticated way	
