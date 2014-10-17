function str = num2ord(x)
% NUM2ORD Convert numbers to an ordinal string.
%
% str = num2ord(x)
%  x is a scalar integer
%  str is a ordinal representation of the number
% e.g. 1 = 1st; 2 = 2nd;
%
%Example
% str = num2ord( 1 )



% $Id: num2ord.m,v 1.5 2006/12/26 22:54:11 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
x = round(x);

if (x<0)
    error( 'linstats:num2ord:InvalidArgument', 'input value must be positive' );
end;

str = 'th';

if x > 4  && x <= 20 
    str = 'th';
else
    o = rem(x,10);
    switch o
        case 1
            str = 'st';
        case 2
            str = 'nd';
        case 3
            str = 'rd';
    end
end

str = sprintf('%d%s',x,str);
