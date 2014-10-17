function A = rotate2d( A, theta )
%ROTATE2D rotates a 2d data matrix
%
% A = rotate2d( X, theta )
% X is an m x 2 matrix;
% theta is the amount of rotation in radians
% A is a m x 2 matrix of X which has been rotated in a counter-clockwise
% direction theta radians
%
%Example
%  x = 1:20;
%  y = (1:20) + randn( [1 20] );
%  A = rotate2d( center([x' y']), deg2rad(-45) );
%  plot(A(:,1),A(:,2),'+'); axis equal;

r = [ cos(theta) sin(theta);
      -sin(theta) cos(theta) ];
  
A = A*r;


