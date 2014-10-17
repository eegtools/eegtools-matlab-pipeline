function tbl = fan_table(Loadings, varnames) 
%FAN_TABLE  factor analysis table
%
%function tbl = fan_table(Loadings, varnames);
% produces a table with the following elements
% Communality is the sum of the square of the loading per variable
%   -- Proportion of variation of each variable involved in patterns.
% Eigenvalues is the sum of the square of each factor loading
%   -- Rule of thumb is to discontinue factoring when eigenvalues are less
%      than 0.50.
% PercentTotalVariance is eigenvalues * 10. 
%   -- It is the percent of variation among all the variables
%       involved in the particular pattern.
% H is the sum of the PercentTotalVariance.
%   -- It is the Percent of variation involved in the patters.
% PercentCommonVariance is the PercentTotalVariance divided by H.
%   -- Variation among all the variables involved a particular pattern as a
%      percent of that involved in all patterns.
% Loadings = factoran(data, noFactors);
%
% Example
%   load carbig
%   X = [Acceleration Displacement Horsepower MPG Weight];
%   X = X(all(~isnan(X),2),:);
%   [Lambda, Psi, T, stats, F] = factoran(X, 2, 'scores', 'regr');
%   varn = {'Acceleration' 'Displacement' 'Horsepower' 'MPG' 'Weight'}';
%   tbl = fan_table( Lambda, varn );
%   jplot_table(tbl);

% $Id: fan_table.m,v 1.3 2006/12/26 22:54:07 Mike Exp $
% Copyright 2006 Lori Twehues
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

r = round( Loadings*100 )/100;

Communality = round(100*sum(Loadings.^2,2))/100;
Eigenvalues = round(100*sum(Loadings.^2))/100;
PercentTotalVariance = 100*Eigenvalues / size(Loadings,1);
H = sum(PercentTotalVariance);
PercentCommonVariance = (PercentTotalVariance / H) * 100;


% calculate the size of the table
nvars = size(Loadings,1);
n = size(Loadings,2) + 2;

tbl = [r Communality];
tbl = [tbl;PercentTotalVariance H; PercentCommonVariance NaN; Eigenvalues NaN ];
tbl = num2cell(tbl);
tbl(end-1:end,end) = {[]};

colh = cell( 1, n );
colh{1} = 'Variables';
for i = 2:n-1
    colh{i} = num2str(i-1);
end;
colh{end} = 'h^2';

if nargin < 2
    varnames = cellstr(num2str( (1:nvars)' ));
end;

varnames{end+1} = '% tot var';
varnames{end+1} = '% com var';
varnames{end+1} = 'Eigenvalues';
tbl = [ colh; ...
       varnames tbl];

