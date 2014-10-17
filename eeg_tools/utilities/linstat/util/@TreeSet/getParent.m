function [ch j] = getParent( ts, node )
% getParent returns the parent node of a child
%
% Example
% [ch j] = getParent( ts, ch_node);
%  ts is class treeset
%  ch_node is the value of a node in the tree
%  returns ch, the value of the parent of ch_node 
%           j, an integer index of the offset of the parent in ts.nodes

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
