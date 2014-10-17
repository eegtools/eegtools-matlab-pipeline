function i = checkDim(g, i )
%CHECKDIM - error check view dimensions 
%

% $Id: checkDim.m,v 1.2 2006/12/26 22:53:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if ~isnumeric(i)  || any(i) > size(g.mm.x,2)
    error( 'FacsMM:AnalysisStep:BadConstructor', 'Bad dim' );
end
