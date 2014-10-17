function [Opt, output, vout, OptH] = mmvn_fit(X, k, Init, options )
% MMVN_FIT fits a mixture of gaussians. 
%
% uses an EM algorithm to estimate parameters for a mixture of multivariate 
% guassian distributions. 
%
% Opt = mmvn_fit(X,K)
%   finds a mixture of K gaussians. X is an n observations x d dimensinos 
%   matrix of values. Initial seeds are guessed based on 
%   kmeans. Returns the structure Opt containing estimates for of the
%   means, M, variances V and class frequencies, W. M is a k x d, V is d x
%   d x k and W is k x 1. 
%
% Opt = mmvn_fit(X,K, Init)
%   finds a mixture of K gaussians given the initial starting conditions in
%   the sturcture Init. Init has the same structure as Opt and may also
%   contain a k x d constraints matrix, h0, that contains grouping
%   variables for each dimension. For example, if we have k = 3 and d = 2
%   then a constrains matrix h0 that forces the first two classes in
%   dimension 1 to have the same mean would look like this
%       h0 = [ 1 1
%              1 2
%              2 3 ];
%  Since h0(1) and h0(2) of column 1 are equal the means will be
%  constrained to be equal
%  Init may also contain a constraints matrix v0 that will constrain the 
%  variances. The structure is the same as h0. 
% 
% Opt = mmvn_fit(...,Options)
%  Options is an optional strucutre that controls the stop criteria
%  Options has 
%    MaxIter   controls the maximum number of iterations,
%    TolFun    tolerance on likelihood difference between
%    OutputFcn function called after each iterations (not implemented)
%    TolX      joint tolerance limits on the means 
%    SaveIter  If set, then Opt contains pages of results for each 
%              iteration
%
% Example
% [X idx theta] = mmvn_gen( 1000, [0 5; 5 0; 5 5; 0 0] );
% Opt = mmvn_fit( X, 4, theta );
% gscatter( X(:,1), X(:,2), idx); 
% hold on;
% ellipse( Opt.M, Opt.V);


% See also MModel, MMView, MMGate

%   
% $Id: mmvn_fit.m,v 1.9 2006/12/26 22:53:19 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

% References
%   Mardia, Multivariate Analysis
%   Xu, Lei and Jordan, Michael. "On Convergence Properties of the EM Algorithm for Gaussian
%   Mixtures", C.B.C.L. Paper No. 111 from Massachusetts Institute of
%   Technology Artificial Intelligence Laboratory and Center for Biological
%   and computational Leraning Department of Brain and Cognitive Sciences
%   (January, 1995).
%   Wickipedia.
%   

% Acknowledgements - initial concepts from 
%   Patrick P. C. Tsui,
%   PAMI research group
%   Department of Electrical and Computer Engineering
%   University of Waterloo,
%   September, 2005
%

if nargin <= 1,
    error('mmvn_fit:InvalidArgument', 'must have at least 2 input arguments');
end;

if nargin < 3 || isempty(Init)
    Init = seedInit( X, k );
else
    % Init is a structure containing starting point for search
    if isempty( Init.M )
        error('linstats:mmvn_fit:InvalidArgument', 'Init must have matrix M');
    end
    
    if size(Init.M,1) ~= k
        error('linstats:mmvn_fit:InvalidArgument', 'Init.M must be k x d matrix');
    end

    if isempty( Init.V )
        Init = seedInit( X, k, Init.M, Init.W );
    end
    
    
end

defaultopt = struct( 'MaxIter', 200*k,...
                     'TolFun',1e-4, ...,
                     'TolX', 1e-3, ...,
                     'FunValCheck','off', ...
                     'OutputFcn',[]);
                 
if nargin < 4
    options = [];
end;

tolf      = optimget(options,'TolFun',   defaultopt,'fast');
tolx      = optimget(options,'TolX',     defaultopt,'fast');
maxiter   = optimget(options,'MaxIter',  defaultopt,'fast');
outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
saveiter  = nargout > 3;

if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
end


    

h0 = [];
v0 = [];
if isfield(Init, 'h0') 
    h0 = hconstraint(Init.h0);
end

if isfield(Init, 'v0');
   v0 = bconstraint(Init.v0);
end;

Opt   = Init;       % set initial values
delta = tolf+1;
niter = 0;
Ln    = 0;

if haveoutputfcn
        vout = outputfcn( X, Opt );
else
        vout = [];
end


while abs(delta)>tolf && niter<=maxiter
    Mo     = Opt.M;     % save old means
    Lo     = Ln;
    [Ln E] = mmvn_expectation(X,Opt);       
    Opt    = mmvn_maximization(X,E,h0,v0);  
    
   
    if (niter == 0)
        delta = 1;
    else
        delta = (Lo - Ln)/Lo;
    end;
    niter = niter + 1;

    try 
        d = sqrt(sum(diag( mah( Mo, Opt.M, Opt.V ) )));
    catch 
        d = nan;
        for j = 1:size(Opt.V,3)
            [R p] = chol(Opt.V(:,:,j) );
            if p~= 0
                Opt.V(:,:,j) = 0;
                Opt.W(j) = 0;
                Opt.M(j,:) = 0;
            end
        end
    end
    output.L(niter)    = Ln;
    output.fval(niter) = d;

    if haveoutputfcn
        vout = outputfcn( X, Opt, output, vout );
    end

    if saveiter
        OptH.W(:,niter)     = Opt.W';
        OptH.M(:,:,niter)   = Opt.M';
        OptH.V(:,:,:,niter) = Opt.V;
    end;
    
    if d < tolx
        output.flag = 1;    % stopped by unchanging parameter estimates
        break;
    end;
    
end

if niter >= maxiter
    output.flag = 0;    % failed on iter
elseif delta <= tolf
    output.flag = -1;   % stopped on tolf
end

% swap-a-roo saves the constraints (if they exist) to Opt
Init.W = Opt.W;
Init.M = Opt.M;
Init.V = Opt.V;
Opt    = Init;



function Init = seedInit(X,k,M,W)
% if no input is provided then a search for modes is done (not implemented)
% if only k is provided a kmeans search is done
% if M is provided (must be k x d) then weighted variance estimates are
% produced based on euclidean distance
% if W is also provided then a weighed variance estimate is produced that
% also takes into account class frequencies. 

%% MJB 12/2005
switch nargin
    case 1      % guess at k 
        [W, M, R ] = em(X, [], 10, 10, 0, 0 );
        Init = em2mmvn( M, R, W );
    case 2      % only have k
        [n,d] = size(X);
        if k > 1
        [Ci,C] = kmeans(X,k,'Start','cluster', ...
            'Maxiter',100, ...
            'EmptyAction','drop', ...
            'Display','off'); 
        else
            C = mean(X);
            Ci = ones( n, 1);
        end;
        M = C';
        V = zeros(d,d,k);
        for i=1:k,
            j = Ci==i;
            W(i) = sum(j)/n;
            V(:,:,i) = cov(X(j,:));
        end
        Init.M = M';
        Init.W = W;
        Init.V = V;
    case 3 % only have M
        V  = cov(X);
        d2 = mah( X, M, V );
        E  = scale( 2*(1 - normcdf(sqrt(d2))') )';
        Init = mmvn_maximization( X, E );
    case 4 % have M and W
        [ll E]  = mmvn_expectation( X, M, cov(X), W );
        Init = mmvn_maximization( X, E );
end


function c0 = hconstraint( h0 )
% reformat h0 into an array of dummy variables
c0 = [];
for i = 1:size(h0,2)
    [a, c0(:,:,i)] =  indexof( h0(:,i), h0(:,i) );  %#ok
end

function b0 = bconstraint( h0 )
% TODO. This appears to get the right linear combinations
% of each variance component, but no attempt to organize
% them has been made. A scheme that `
% allows some simple matrix algebra would be best
% 
b0 = [];
if isempty(h0)
    return;
end;
[k,n] = size(h0);

z = fullfact( [n n] );
C = cell(k,1);
for i = 1:k
    f = h0 == repmat( h0(i,:), k, 1 );
    x = f(:,z(:,1) );
    y = f(:,z(:,2) );
    C{i} = x.*y;
end

b0 = reshape( cat(1,C{:}), k,k,n,n);


