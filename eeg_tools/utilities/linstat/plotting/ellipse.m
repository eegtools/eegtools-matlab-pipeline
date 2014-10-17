function h = ellipse( M, V, dims, sd )
% ELLIPSE draws 2d and 3d ellipse(s)
%
% h = ellipse( M, V, dims, sd )
%     M is a kxd matrix where M(k,:) is the location of the kth ellipse
%     V is a dxdxk matrix of covariances where V(:,:,k) is the covariance
%        matrix for the kth ellipse.
%     dims is a vector of scalar indices to columns of M. It is used to 
%        selection the number (2 or 3) and which dimensions to plot
%        if d is a scalar then the first d dimensions will be plotted
%        if d is a vector then the dth dimensions will be used
%        the number of dimensions must be 2 or 3
%     SD sets the scale of the ellipse in std deviation (mahalanobis units)
%        default is 1.
%     returns h a k x 2 matrix of handles to the ellipses (column 1 ) and
%     the markers at the ellipse centers(column 2)
% 
% Example
%   V = [1 .7 0; .7 1 0; 0 0 1];
%   [X idx theta] = mmvn_gen( 1000, [0 5 0], V ); %generate 1000 correlated points in 3d with mean at (0,5,0)
%   h = ellipse( theta.M, theta.V );              % 3d ellipses
%
% Example
%     load carbig;        % load data
%     X = [MPG Acceleration Weight Displacement];
%     i = ~any(isnan(X),2);  %find present values
%     X = zscore(X(i,:));
%     [coeff, score, latent] = princomp( X );
%     [h lh ]= pcplot( score,latent, Cylinders(i,:), Origin(i,:)   );
%     set(lh(2),'location', 'southwest');
%     hold on; 
%     theta = mgrpcov( score, Cylinders(i) );
%     colormap( colorfulcube(5) ); 
%     h = ellipse(theta.M, theta.V, [1 2]); set(h(:,1), 'linewidth', 3);


% ToDo: support certain covariance matrices that aren't positive definite
% for example if plotting in 2 dimensions support a cv matrix with rank of
% 1 (plot a line(s)). Or, if we are in 3d, then plot a 2d ellipse.

% $Id: ellipse.m,v 1.7 2006/12/26 22:53:24 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


newplot
hold(gca,'on');

res = 100;    


[n,d,k] = size(V);

if ( n ~= d )
    error( 'linstats:ellipse:InvalidArgument','V must be a square positive definite matrix');
end

n = size(M,2);
if ( n ~= d )
    error( 'linstats:ellipse:InvalidArgument','M must have the same number of columns as V has rows');
end

if nargin >= 3
    
    if isempty( dims )
        dims = 1:2;
    elseif isscalar(dims)
        dims = 1:dims;
    end

    d = length(dims);
    if ( d > 3 )
        error( 'linstats:ellipse:InvalidArgument','dimensions larger than three not supported. set dims argument to select displayed dimensions');
    end

    M = M(:,dims);
    V = V(dims,dims,:);
end;

if ( nargin < 4)
    sd = 1;
end

color = colormap;
if size(color,1) < k
    color = colorfulcube(k);
end;

q = zeros(k,1);
m = q;
if d == 2
    [x,y] = pol2cart( linspace(0,2*pi,res)', 1 );
    A = [x y];
    for i = 1:k
        E =  center(A*chol(V(:,:,i)).*sd, -M(i,:) );
        q(i) = plot(E(:,1), E(:,2), 'color', color(i,:), 'linestyle', '-' );
        m(i) = plot(M(i,1), M(i,2), 'color', color(i,:), 'marker', 'o', 'markerfacecolor', 'w');
    end;
elseif d == 3
    [x,y,z] = sphere();
    xn = size(x,1);
    A = [x(:) y(:) z(:)];
    for i = 1:k
        E =  center(A*chol(V(:,:,i)).*sd, -M(i,:) );
        x = reshape(E(:,1), xn,xn);
        y = reshape(E(:,2), xn,xn);
        z = reshape(E(:,3), xn,xn);
        
        q(i) = surf( x,y,z, 'facecolor', color(i,:), 'edgecolor', 'none' );
    end;
    m = q;
end;
      
if d == 3;
    view(3)
    camlight;
    lighting gouraud;
end;

if nargout > 0
    h = [q m];
end;

