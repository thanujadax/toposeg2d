function edgePix = getPsuedoEdgePixels...
    (edgeLID,psuedoEdgeIDs,psuedoEdges2nodes,edgeListInds)

pEID = edgeListInds(edgeLID);
edgePix = psuedoEdges2nodes(psuedoEdgeIDs==pEID,:);