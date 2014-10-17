function mm = MModel( x, s, t, knames)
%MModel MModel class constructor 
% Used to select variables and to interactively create a mixture model 
%   mm = MModel()
%        default constructor, creates a 1x0 mixture model
%   mm = MModel( mm )
%        copy constructor
%   mm = MModel(x) 
%        x is an m,n matrix. creates a 1,n model (i.e columns means and
%        cov), x can be empty, in which case n = 0;
%   mm = MModel(x, s)
%        s is a logical n-vector selecting d columns of x. 
%        mm is a 1xd Mixture Model.  if x is empty, n = length(s), d =
%        sum(s). if s is emtpy then d = n. if x is empty then d and n are
%        taken from theta. 
%   mm = MModel(x, s, k )
%        where k is a scalar, creates a kxd model
%   mm = MModel(x, s, theta)
%        where theta is a structure of initial parameeters (see mmvn_fit)
%        b0.M is a k x d matrix. d must equal the sum(s).
%        b0.V must be a d x d x k array
%        b0.W must be a k x 1 vector
%   mm = MModel(x, s, theta, knames)
%        knames is a cellstr of length k
%Example:
%   [X idx theta] = mmvn_gen( 1000, [0 5; 5 0; 5 5; 0 0] );
%   mm = MModel( X );       
%   mv = 

% $Id: MModel.m,v 1.2 2006/12/26 22:53:09 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com


k = 1;

if nargin == 0
    x      = [];
    d      = 0;
    s      = true(1,d);
end


if nargin >= 1
    if isnumeric(x)         % define d and s in terms of x
        n = size(x,2);
        k = 1;
    elseif isa(x,'MModel');
        mm = x;
        return;
    else
        error('linstats:Facs:MModelConstructor', 'first argument must be a matrix or a MModel');
    end
end

if nargin >= 2  && ~isempty(s)
 
    if ~isvector(s) 
        error('linstats:Facs:MModelConstructor', 'second argument must be vector');
    end
    if n == 0, n = length(s), end;
    s = ind2logical( s, n );

else  % s was not provided
    if ~isempty(x)      % if x is present create default s using all columns of x
        s = true(n,1);  % s is a n x 1 logical vector
    end
    % otherwise both s and x are empty - always ok
end


mm.x    = x;        % empty or data 
mm.s    = s;        % columns of x to include in model (ie. model dims)
mm.b0   = [];       % empty or initial parameters if data is present
mm.bhat = [];       % empty or optimized parameters if em has been run
mm.u    = [];       % empty or means from each class  to every dimension if data is present
mm.d2   = [];       % empty or mah distance if data is present
mm.L    = [];       % empty of LL if data is present
mm.knames = {};



mm = class(mm, 'MModel');


if nargin >= 3
    if ~isstruct(t) && isscalar(t)
        mm = kmeans_init(mm,t);
    elseif isstruct(t)
        mm = setTheta(mm,t);
    else
        error('linstats:Facs:MModelConstructor', 'third argument must be scalar or a pararamter struct');
    end
    k = size(mm.b0.M,1);
else    
    mm = kmeans_init(mm,k);
end


if nargin == 4
    if length(knames) ~= k 
         error('linstats:Facs:MModelConstructor', 'knames must have length k');
    end
    if ~iscellstr(knames)
        knames = cellstr(knames);
    end
    mm.knames = knames(:);
else
    mm.knames = cellstr( num2str( (1:k)') );
end


