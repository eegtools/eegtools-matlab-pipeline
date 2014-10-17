function mm = setTheta( mm, varargin )
% check initial parameter for consistency 
% returns theta, a valid paremeter estimate structure
% example
%       theta = setTheta( mm, theta )
%          theta is a structure providing M (kxd), V (dxdxk) and W(kx1)
%          theta may also provide h0, and v0, constraints (see also
%          mmvn_fit). check for consistency inside theta and with mm.s (if
%          set)
%       theta = setTheta(mm, M );   % M is a k x d matrix. V defaults to I
%       theta = setTheta(mm, M, V); % provide M and V is a d x d x k
%                                % matrix. W defaults to uniform
%       theta = setTheta(mm, M, V, W);  % provide M,V and W a k x 1 vector

% $Id: setTheta.m,v 1.2 2006/12/26 22:53:11 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
b0    = checkTheta( mm.s, varargin{:});

if ~isequal(b0, mm.b0)
    mm.b0    = b0;
    mm.bhat  = [];
    mm.u     = [];
    mm.d2    = [];
    mm.L     = [];
    if ~isempty(mm.x)
        mm.u     = weightedMeans( mm );
        mm.d2    = mah(mm );
        mm.L     = mmvn_expectation(mm.x(:,mm.s), b0);
    end;
end


