function [p j] = getDescendants( ts, node )
% GETDESCENDANTS get all descendants of given node
%
% Example
% [p j] = getDescendants( ts, p_node);
%  ts is class treeset
%  p_node is the value of a node in the tree
%  returns p, a cell array of all nodes descendant from p_node
%          j,  an integer index of the offset of the descendants

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
 

j  = false( size(ts.nodes) );

[nodes k] = getChildren(ts,node);
j(k) = true;
for a = 1:length(nodes)
    [p k] = getDescendants(ts, nodes{a});
    j(k) = true;
end;


p = ts.nodes(j);
j  = find(j);
