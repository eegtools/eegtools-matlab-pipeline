%% vtest plots
% this is a test to see that major
% plot routines complete without error using various inputs. It is assumed 
% that the output is correct.
%   checks directly or indirectly
%       mscatter
%       ciplot
%       iplot
%       pcplot

load weather.mat
errors = 0;
total_errors = errors;

glm       = encode( y, [ 3 3 3], 2, g1, g2, g3 );
glm.ls    = mstats(glm);
glm.anova = anova(glm);
iplot( glm, 1 );
iplot( glm, 2 );
iplot( glm, 3 );
iplot( glm, [1 2] );
iplot( glm, [1 3] );
iplot( glm, [2 3] );
dvplot( glm );


%% test multi-variate plots
clf
load carbig
X = [MPG Acceleration Weight Displacement];  % response variables
glm = encode( X, 3, 1, Origin );         % Origin is explanatory variable
[coeff,score,latent] = princomp( glm.y, 'econ');
O  = Origin(~glm.missing);
pcplot( score, latent, O, O, O );
pcplot( score, latent, O, O, [] );
pcplot( score, latent, O, O, [] );
pcplot( score, latent, O, [], O );
pcplot( score, latent, [], O, O );





