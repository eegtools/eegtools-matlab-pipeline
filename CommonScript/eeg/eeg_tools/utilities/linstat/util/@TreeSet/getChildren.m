function [ch j] = getChildren( ts, node )
% getChildren gets children of node
%
% Example
% [p j] = getChildren( ts, p_node);
%  ts is class treeset
%  p_node is the value of a node in the tree
%  returns p, a cell array of all immediate descendant from p_node
%          j,  an integer index of the offset of the immediate descendants

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
ch = [];

i = findNode( ts, node );
if i == 0
  return;
end

j = find( ts.tree(i,:));

ch = ts.nodes(j);
