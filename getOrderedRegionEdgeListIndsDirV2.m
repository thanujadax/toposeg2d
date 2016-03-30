function [c_edgeLIDsForRegions_dir_cw,setOfRegions_edgeLIDs,edgeLIDs2nodes_directional] ...
        = getOrderedRegionEdgeListIndsDirV2...
        (setOfRegions,edges2nodes,jAnglesAll_alpha,...
        junctionTypeListInds,nodeEdgeIDs,edgeListIndsAll,...
        edges2pixels,sizeR,sizeC)
    
% Inputs:
%   setOfRegions: edgeIDs for each region as a row vector

% Outputs:
%   c_edgeLIDsForRegions_cw: set of cells each containing directional
%   edgeLIDs for the corresponding region, in clockwise direction
%   setOfRegions_edgeLIDs: edgeLIDs for each region (undirected)

% first order the set of edges in either clockwise or counter clockwise
% order. Then decide if the order is CW or CCW. Rearrange to get CW order
% if necessary.
% at each node take a right turn. get the edge. check if that edge is in
% the set of edges.

numRegions = size(setOfRegions,1);
c_edgeLIDsForRegions_dir_cw = cell(numRegions,1);
setOfRegions_edgeLIDs = setOfRegions;

edges2nodes_complements = edges2nodes;
edges2nodes_complements(:,1) = edges2nodes(:,2);
edges2nodes_complements(:,2) = edges2nodes(:,1);
edgeLIDs2nodes_directional = [edges2nodes; edges2nodes_complements];

for i=1:numRegions
    edgeIDsOfRegion_i = setOfRegions(i,:);
    edgeIDsOfRegion_i = edgeIDsOfRegion_i(edgeIDsOfRegion_i>0);
    % arrange the edges in clockwise order of node traversal
    [~,edgeLIDsForRegion] = intersect(edgeListIndsAll,edgeIDsOfRegion_i);
    if(numel(edgeLIDsForRegion)==0)
        c_edgeLIDsForRegions_dir_cw{i} = 0;
    else
        numE_region = numel(edgeLIDsForRegion);
        setOfRegions_edgeLIDs(i,1:numE_region) = edgeLIDsForRegion;

        nodeLIdsForRegion = edgeLIDs2nodes_directional(edgeLIDsForRegion,:);
        nodeLIdsForRegion = unique(nodeLIdsForRegion);
        c_edgeLIDsForRegions_dir_cw{i} = getCwOrderedEdgesForRegion...
                (edgeLIDsForRegion,edgeLIDs2nodes_directional,junctionTypeListInds,...
                nodeEdgeIDs,jAnglesAll_alpha,edgeListIndsAll,nodeLIdsForRegion,...
                edges2nodes,edges2pixels,sizeR,sizeC);
    end
    
end

function cwOrderedDirEdgeListInds = getCwOrderedEdgesForRegion...
            (edgeListInds_region,edges2nodes_directional,junctionTypeListInds,...
            nodeEdgeIDs,jAnglesAll_alpha,edgeListIndsAll,nodeLIdsForRegion,...
            edges2nodes,edges2pixels,sizeR,sizeC)

% starting from one node, go along the consecutive nodes
orderedSetOfEdges = getOrderedSetOfEdges();

cwOrderedDirEdgeListInds = orderEdgeSetCw();



function orderedSetOfEdges = getOrderedSetOfEdges(edgeListInds_region,...
    edges2nodes_directional,edges2nodes,edgeListIndsAll)
% Pick one edge (1st in the list)
nextEdgeLID = edgeListInds_region(1);
edgeID_1 = edgeListIndsAll(nextEdgeLID);

N1LID = edges2nodes(nextEdgeLID,1);

numEdges_region = numel(edgeListInds_region);

orderedDirEdgeListInds = zeros(numEdges_region,1);
orderedNodeListInds = zeros(numEdges_region,1);

nextEdgeNodeLID_pair = edges2nodes_directional(nextEdgeLID,:);


for i=1:numEdges_region
    
    nextEdgeNodeLID_pair = edges2nodes(nextEdgeLID,:);
    if(nextEdgeNodeLID_pair(1)==N2LID)
        nextEdgeLID_dir = nextEdgeLID;
    else
        nextEdgeLID_dir = nextEdgeLID + numEdges;
    end
    
    
end








