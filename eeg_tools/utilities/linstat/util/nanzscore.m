function z = nanzscore( d, reference )
%NANZSCORE  zscore for data with missing values
%
%z = zscore( d )
% d is a m x n matrix of values
% z is a m x n matrix of standardized values (mean 0, std 1) computed
% independly for each column of d
% 
% z = zscore( d, reference )
% reference is a vector of integer indices less than m specifying a subset
% of rows in d that will be used to compute the mean and variance
% return z a m x n matrix of distances from each point (in standard units)
% from the reference sample
%
% Example
%   load carbig
%   X = [MPG Acceleration Weight Displacement];
%   nanzscore(X)
%
% See also mgrpcov, mah

if (nargin < 2 )
  [mu, v] = mgrpstats(d);
else
  [mu, v] = mgrpstats(d(reference,:));
end
z = scale( center(d,mu), sqrt(v));

