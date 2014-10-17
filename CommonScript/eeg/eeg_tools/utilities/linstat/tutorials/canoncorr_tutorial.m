%% Cannonical Correlation
% Cannonical correlation is a useful tool when trying to understand the
% relationship between multiple explanatory variables and a set of response
% variables 
% This tutorial demonstrates the concepts and the computational challenges
% of canonical correlation using carbig and simulated data 

%% Example 1
% Illustrate basic use of matlab's canoncorr function and how to interpret
% results
load carbig

% build a model without an intercept
glm = encode( [Acceleration MPG], 0, eye(3), Displacement, Horsepower, Weight );


% do the canonical correlation analysis
[A B r U V] = canoncorr(zscore(glm.dmat), zscore(glm.y));

% format xlabels
xlab = coeff2eqn( A', glm.coeff_names );
ylab = coeff2eqn( B', {'Accel'; 'MPG'});

figure
plotmatrix(glm.dmat, glm.y);

figure
% plot the canonical variables, U and V
for i = 1:2
    subplot( 2,1,i);
    plot( U(:,i), V(:,i), '.' );
    xlabel( xlab{i} );
    ylabel( ylab{i} );
end;


%% using SVD
% canonical variables can be solved using SVD
% step. 
% 

x = center(glm.dmat);
y = center(glm.y);
n = size(x,1);

[qx rx px] = qr( x,0 );   % qx = x*rx^-1
[qy ry py] = qr( y,0 );   % qy = y*ry^-1

[U S V ] = svd( qx'*qy );
cv1 = qx*U*sqrt(n-1);
cv2 = qy*V*sqrt(n-1);

figure
for i = 1:2
    subplot( 2,1,i);
    plot( cv1(:,i), cv2(:,i), '.' );
    xlabel( xlab{i} );
    ylabel( ylab{i} );
    axis equal;
end;


%% simulates

close all
% setup
n = 300;
p = 2; q = 50;
y = randn( n, p );
x = randn( n, q );
y(:,1) = x(:,1) + randn(n,1)*2;
% y(:,2) = x(:,1)-x(:,3) + randn(n,1)/2;

[A B R U V stats] = canoncorr(x, y);

% figure('pos', [0   532   560   420]);
% plotmatrix(x, y);

% figure('pos', [0    30   560   420]);

% plot( U(:,1), V(:,1), '.' );
% xlab = coeff2eqn( A', glm.coeff_names );
% ylab = coeff2eqn( B', {'Accel'; 'MPG'});
% xlabel( xlab{1} );
% ylabel( ylab{2} );


disp(stats.p);
disp(sum( abs(A(:,1)) > abs(A(1))))
