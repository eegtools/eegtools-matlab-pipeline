function [ch j] = getAncestors( ts, node )
% GETANCESTORS returns all ancestors of a child node
%
% Example
% [p j] = getDescendants( ts, c_node);
%  ts is class treeset
%  c_node is the value of a node in the tree
%  returns p, a cell array of all ancestors of c_node
%          j,  an integer index of the offset of the ancestors

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

ch = [];
j = [];

i = findNode( ts, node );
if i == 0
  return;
end

j = find( ts.tree(:,i));
if ~isempty(j)
    ch = ts.nodes{j};
end;
