function edgeProbabilities = getEdgeProbabilitiesFromRFC...
            (forestEdgeProb,rawImage,OFR,edgepixels,edgePriors,...
            boundaryEdgeIDs,edgeListIndsToProcess,numTrees,...
            psuedoEdgeIDs,psuedoEdges2nodes,edgeListInds,...
                membraneProbabilityMap,edgeListIndsOriginal)
        
        

fm = getEdgeFeatureMat(rawImage,edgepixels,OFR,edgePriors,boundaryEdgeIDs,...
    edgeListIndsToProcess,psuedoEdgeIDs,psuedoEdges2nodes,...
    membraneProbabilityMap,edgeListIndsOriginal);
[y_h,v] = classRF_predict(double(fm), forestEdgeProb);

edgeProbabilities = v(:,2)./numTrees;
