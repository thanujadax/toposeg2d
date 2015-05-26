function repNodeInd = getRepresentativeClusNodeInd(nodeInd,clusteredJunctionIDs)

nodeLID = find(clusteredJunctionIDs(:,1));

if(~isempty(nodeLID))
    clusID = clusteredJunctionIDs(nodeLID,2);
    allClusPixInds = clusteredJunctionIDs((clusteredJunctionIDs(:,2)==clusID),1);
    repNodeInd = allClusPixInds(1);
else
    repNodeInd = nodeInd;
end