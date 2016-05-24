function [nodeEdges,nodeIndsNoDuplicates,psuedoEdgeIDs,psuedoEdges2nodeInds,...
    removedPsEdgeLIDs]...
    = getNodeEdges...
    (ind4J,edgePixLabels,connectedJunctionIDs,sizeR,sizeC,...
    psuedoEdgeIDs,psuedoEdges2nodeInds)
% Inputs:
%   nodeInd - array of junction indices
%   edgePixLabels - N-by-2 array of edge labels for each pixel, given by
%   the index wrt the original image (watershed)
%   connectedJunctionIDs - list of clusterd junction indices with the associated
%   cluster label.
%   psuedoEdgeIDs - 
%   psuedoEdges2nodes - each row contains the 2 nodes which are connected
%   by a psuedoEdge

% Output:
%   nodeEdges - array with edge labels corresponding to each junction. each
%   row -> jn,edge1,edge2,edge3,edge4
%       edgeIDs sorted in ascending order 20140107
%   nodeIndsNoDuplicates - list of the pixel indices of the nodes provided
%   in nodeEdges. For the detected clustered nodes in connectedJunctions 

% for each node, get the neighbors
% get the edgeID of the neighbors
disp('Constructing nodeEdges look up table ...')
psEID_tobe_removed = [];
if(size(connectedJunctionIDs,2)==2)
    numClusters = max(connectedJunctionIDs(:,2));
    numClusteredNodes = size(connectedJunctionIDs,1);
else
    numClusters = 0;
    numClusteredNodes = 0;
end
% number of nodes after combining clusters
numNodes0 = numel(ind4J);
numNodesCombined = numNodes0 - numClusteredNodes + numClusters;

psuedoNodeInds = unique(psuedoEdges2nodeInds);
% psuedoNodeInds = ind4J(psuedoNodeInds);
% str1 = sprintf('number of pseudo nodes input: %d',numel(psuedoNodeLIDs));
% disp(str1);
% psuedoNodeLIDs = setdiff(psuedoNodeLIDs,ind4J);
% str1 = sprintf('number of pseudo nodes after removing nodes already accounted for the input list of nodes: %d',numel(psuedoNodeLIDs));
% disp(str1);
% % looks like psuedoNodeLIDs are already included in nodeInds?
% numNodesCombined = numNodesCombined + numel(psuedoNodeLIDs);

% create a list of nodeInds without duplicates
nodeIndsNoDuplicates = ind4J;
for i=1:numClusters
    cNodesListInd = find(connectedJunctionIDs(:,2)==i);
    cNodes_i = connectedJunctionIDs(cNodesListInd,1);
    numCnodes_i = numel(cNodes_i);
    for j=2:numCnodes_i
        nodeIndsNoDuplicates = nodeIndsNoDuplicates...
                    (nodeIndsNoDuplicates(:,1)~=cNodes_i(j),:);
    end    
end

nodeEdges = zeros(numNodesCombined,5); % 5 is not fixed

for i=1:numNodesCombined
    thisNodeIndex = nodeIndsNoDuplicates(i);
    neighborInds = getNeighbors(thisNodeIndex,sizeR,sizeC);
    numNeighbors = numel(neighborInds);
    nodeEdges(i,1) = thisNodeIndex;
    k = 1;
    for j=1:numNeighbors
        neighborListInd = find(edgePixLabels(:,1)==neighborInds(j));
        if(~isempty(neighborListInd))
            % there's an edge for this neighbor
            k = k + 1;
            edgeId = edgePixLabels(neighborListInd,2);
            nodeEdges(i,k) = edgeId;
        end
%         % if neighbor is in the psuedoEdges2nodes list, add the
%         % psuedoEdgeID
%         psuedoEdgeIDs_i = getPsuedoEdgeLID(thisNodeIndex,psuedoEdgeIDs,psuedoEdges2nodes);
%         if ~(psuedoEdgeIDs_i(1)==0)
%             % add the psuedoEIDs to nodeEdges
%             k = k+1;
%             numPEs = numel(psuedoEdgeIDs_i);
%             nodeEdges(i,k:(k+numPEs-1)) = psuedoEdgeIDs_i;
%         end

    end
    % if this node is in psuedoEdges2nodes, add the psuedoEdgeID
    % only if this node and the its neighbor connected via a ps edge is
    % not already connected with a real edge. If there's already an edge, remove
    % the corresponding psEdgeId and psEdges2Nodes entries by recording
    % that instance, to be later removed!
    if(sum(ismember(psuedoNodeInds,thisNodeIndex)))

        [psEIDs_thisNode,neighborNodeInds] = getPSedgeIDsForThisNode...
            (thisNodeIndex,psuedoEdges2nodeInds,psuedoEdgeIDs);
        if(~isempty(psEIDs_thisNode))
            for p=1:numel(psEIDs_thisNode)
                if(isempty(isEdgeBetweenNodes...
                        (thisNodeIndex,neighborNodeInds(p),...
                        edgePixLabels,connectedJunctionIDs,sizeR,sizeC)))
                    k = k+1;
                    nodeEdges(i,k) = psEIDs_thisNode(p);
                else
                    % this psEID should be removed. also from
                    % psEdges2nodes
                    psEID_tobe_removed = [psEID_tobe_removed; psEIDs_thisNode(p)];
                end
            end
        end
    end    
    
    % check if it has directly neighboring nodes
    connectedJInd = find(connectedJunctionIDs(:,1)==thisNodeIndex);
    if(~isempty(connectedJInd))
        % this junction has other directly neighboring junctions
        duplicateLabel = connectedJunctionIDs(connectedJInd,2);
        neighboringCJListInd = find(connectedJunctionIDs(:,2)==duplicateLabel(1));
        
        numNeighJ = numel(neighboringCJListInd);
        for m=2:numNeighJ      % start with 2 to skip the current junction node
            % for each neighboring junction,
            neighJ_ind = connectedJunctionIDs(neighboringCJListInd(m),1);
            % get its edges and,
            % add its edges to the list of edges under 'thisNodeIndex'
            jNeighborInd = getNeighbors(neighJ_ind,sizeR,sizeC);
            jNeighborInd = jNeighborInd(jNeighborInd~=thisNodeIndex);
            numJNeighbors = numel(jNeighborInd);
            for j=1:numJNeighbors
                jNeighborListInd = find(edgePixLabels(:,1)==jNeighborInd(j));
                if(~isempty(jNeighborListInd))
                    % there's an edge for this neighbor
                    % check first, if this edge is already in the list for
                    % thisNodeIndex
                    edgeId = edgePixLabels(jNeighborListInd,2);
                    if(isempty(find(nodeEdges(i,:)==edgeId)) )
                        k = k + 1;
                        nodeEdges(i,k) = edgeId;
                    end
                end
            end                        
        end
    end
    
    % sort edgeIDs in ascending order
    if(k>1)
        edgeList_i = unique(nodeEdges(i,2:k));
        edgeList_i = sort(edgeList_i);
        edgeList2 = zeros(1,(k-1));
        edgeList2(1:numel(edgeList_i)) = edgeList_i;
        nodeEdges(i,2:k) = edgeList2;
        
    end
end
psEID_tobe_removed = unique(psEID_tobe_removed);
% removing psuedo edges which are already covered by real edges
disp('Updating psuedoEdgeIDs and psuedoEdges2Nodes by removing psuedoEdges that are already covered by real edges ...')
str1 = sprintf('Removing %d out of %d psuedo edges ..',...
    numel(psEID_tobe_removed),numel(psuedoEdgeIDs));
disp(str1)
[~,removedPsEdgeLIDs]=intersect(psuedoEdgeIDs,psEID_tobe_removed);
psuedoEdgeIDs(removedPsEdgeLIDs) = [];
psuedoEdges2nodeInds(removedPsEdgeLIDs,:) = [];