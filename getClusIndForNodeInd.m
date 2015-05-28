function clusInd = getClusIndForNodeInd(nodeInd,connectedJunctionIDs)
% returns the clusInd for the given nodePixelIndex. returns 0 if the given
% pixel is not in a cluster.
if(size(connectedJunctionIDs,2)==1)
    clusInd = 0;
    
else

    clusListInd = find(connectedJunctionIDs(:,1)==nodeInd);

    if(~isempty(clusListInd))
        clusInd = connectedJunctionIDs(clusListInd,2);
    else
        clusInd = 0;
    end
end