function p = mmvn_pdf(X, varargin)
% MMVN_PDF Mixture of multivariate nomal probabilities
%
% Example:
% function p = mmvn_pdf(X,theta)   % provide mmvn struct
%              X is a m x d matrix
%              theta is a mmvn structure describing k classes
%              see mmvn_gen for other calling syntax
% returns  p, an m x k matrix of class membership probabilities
%
% See also mmvn_gen


theta = mmvn_getTheta( varargin{:} );

n     = size(X,1);
k     = size(theta.M,1);
p     = zeros(n,k);

for j = 1:k
    % calculate expectations
    if theta.W(j) == 0; 
        p(:,j) = 0; 
    else
        p(:,j) = theta.W(j).*mvnpdf( X, theta.M(j,:), theta.V(:,:,j) );
    end
end;


