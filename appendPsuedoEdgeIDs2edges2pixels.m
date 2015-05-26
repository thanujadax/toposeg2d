function edges2pixels = appendPsuedoEdgeIDs2edges2pixels(edges2pixels,psuedoEdgeIDs)

[sizeR,sizeC] = size(edges2pixels);

pMat = zeros(numel(psuedoEdgeIDs),sizeC);
pMat(:,1) = psuedoEdgeIDs;

edges2pixels = [edges2pixels; pMat];