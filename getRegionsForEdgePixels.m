function regionIDs = getRegionsForEdgePixels(ws,edgepixels,sizeR,sizeC)
% returns the ws ids of the two ws regions on either side of the given edge
% Inputs:
%   ws - watershed transform
%   edgepixels - of the current edge

neighbors8_pixind = get8Neighbors(edgepixels,sizeR,sizeC);
% warning: contains zero for non existent neighbors
neighbors8_pixind = neighbors8_pixind(neighbors8_pixind>0);
wsidsFor8Neighbors = ws(neighbors8_pixind);
wsidsFor8Neighbors = wsidsFor8Neighbors(wsidsFor8Neighbors>0);

regionIDs = unique(wsidsFor8Neighbors);