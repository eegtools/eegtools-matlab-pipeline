function [xx, y, h] = paired_resid_plot(a,b,c)
%PAIRED_RESID_PLOT - plots a-b versus avg(a,b)
%
%A technique to examine thousands of responses. plotting a versus b
% is not so easy to see the error about a line, but plotting a-b versus
% some combination of a and b makes it easy
%
%Example
%	[y,x] = paired_resid_plot(a,b)
%	plots a minus b versus (a+b)/2
%	results returned in x,y
%
% see also resid_plot

y = (a(:)-b(:));
x = (a(:)+b(:))/2;
if ( nargin < 3 ) 
    figure;
    c = 'k.';
else
    hold on;
end;
h = plot(x,y, c);


ylabel('a-b');
xlabel('(a+b)/2' );


%set the axis to fit all the data
a = axis;
a(2) = max( a(2), nanmax(x) );
ylim = nanmax( [abs(nanmin(y)), abs(nanmax(y)), abs(a(3)), abs(a(4)) ] );

line( [a(1) a(2)], [0 0] );


%make symmetrical around the y axis
a(3) = -ylim;
a(4) = ylim;

axis(a);


if nargout > 0
    xx = x;
end;