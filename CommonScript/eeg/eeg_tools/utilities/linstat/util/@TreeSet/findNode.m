function i = findNode( ts, node )
%FINDNODE finds a node in a treeset
%
% Example
%  i = getDescendants( ts, node);
%  ts is class treeset
%  node is the value of a node in the tree
%  returns i an integer index of the offset of the node or 0 if it is not
%  found or is the root

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
i = 0;

for j = 1:ts.nextnode
    if isequal( ts.nodes{j}, node )
        i = j;
        break
    end
end

