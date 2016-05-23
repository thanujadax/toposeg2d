function [adjacencyMat,nodeEdges,edges2nodes,edges2pixels,connectedJunctionIDs,...
    selfEdgePixelSet,ws,ws_original,removedWsIDs,newRemovedEdgeLIDs,...
    psuedoEdgeIDs,psuedoEdges2nodeInds]...
    = getGraphFromWS(ws,hsvOutput,displayImg,saveIntermediateImages,...
      saveIntermediateImagesPath,rawImageID)

% Outputs:
% nodeEdges: contains the set of edgeIDs for each nodePixInd

saveMatrices = 0;  % to save some of the generated matrices

% % test input ws
% ws = imread('toyWS.png');
[sizeR,sizeC] = size(ws);

% the edges (watershed boundaries) are labeled 0
% extract those
ind0 = find(ws==0);
% [r0,c0] = ind2sub([sizeR sizeC],ind0);
wsBoundaries = int8(zeros(sizeR,sizeC));
wsBoundaries(ind0) = 1;
% figure;imshow(wsBoundaries);
% title('watershed boundaries')

%% extracting junctions
% look at the 4 neighborhood of each pixel
fourNH = zeros(size(ws));
numEdgePixels = numel(ind0);  % watershed edge pixels
% fourNHcount = int8(zeros(numEdgePixels));
disp('Extracting junctions from WS')
for i=1:numEdgePixels
    % calculate n.o. 4 neighbors
    ind = ind0(i);
    [r c] = ind2sub([sizeR sizeC],ind);
    nh = zeros(1,4);
    
    if((r-1)>0)
        nh(1) = wsBoundaries(r-1,c);
    end
    if((r+1)<=sizeR)
        nh(2) = wsBoundaries(r+1,c);
    end
    if((c-1)>0)
        nh(3) = wsBoundaries(r,c-1);
    end
    if((c+1)<=sizeC)
        nh(4) = wsBoundaries(r,c+1);
    end
    
    fourNH(ind) = sum(nh);
    % fourNHcount(i) = sum(nh);
end

% get the pixels which are having a 4NH > 2
ind4J = find(fourNH>2);         % indices of junctions wrt to ws segmentation
% ind4J = find(fourNHcount>2);
clear fourNHcount
disp('Junctions extracted!')
% visualize junctions
wsJ = zeros(sizeR,sizeC);
wsJ(ind4J) = 1;

% save image
if(saveIntermediateImages)
    wsVis = zeros(sizeR,sizeC,3);
    wsVis(:,:,3) = wsBoundaries;
    wsVis(:,:,1) = wsJ;
    intermediateImgDescription = 'WSjunctions';
    saveIntermediateImage(wsVis,rawImageID,intermediateImgDescription,...
    saveIntermediateImagesPath);
    figure;imshow(wsVis);
    % title('Junctions from WS')
end
% ws edges with OFR color code
hsvOutput_V = hsvOutput(:,:,3);
edgepix = zeros(sizeR,sizeC);
edgepix(wsBoundaries>0) = hsvOutput_V(wsBoundaries>0);
edgepix(wsJ>0) = 1;
hsvOutput(:,:,3) = edgepix;
if(saveMatrices)
    save('edgepix.mat','edgepix');
end
hsvImg = cat(3,hsvOutput(:,:,1),hsvOutput(:,:,2),hsvOutput(:,:,3));
RGBimg = hsv2rgb(hsvImg);
if(displayImg)
    figure;imshow(RGBimg);
end

if(saveIntermediateImages)
    intermediateImgDescription = 'orientationFiltering_WS';
    saveIntermediateImage(RGBimg,rawImageID,intermediateImgDescription,...
    saveIntermediateImagesPath);
end
%% extracting edges connecting junctions
% assign unique labels for edges
% all the pixels in each edge should have the same label

disp('Extracting edges connecting junctions in WS')
wsEdges = wsBoundaries;
wsEdges(ind4J) = 0;         % setting junctions to zero. only edges are 1
pixList = find(wsEdges);    % edge pixels without junctions.
edgePixLabels = zeros(numel(pixList),2); % 2nd column stores the edge label
edgePixLabels(:,1) = pixList;
currentLabel = 0;       
for i=1:numel(pixList)
    if(edgePixLabels(i,2)==0)
        % assign label
        currentLabel = currentLabel + 1;
        edgePixLabels = labelPixelNeighbors(edgePixLabels,pixList(i),currentLabel,...
                sizeR,sizeC);
    else
        continue
    end
end
disp('done!')
%% visualization
% % assign random colors to edges
% % TODO: assign colors from the OFR to each edge
% edgePixColors = edgePixLabels;
% edgePixColors(:,2) = mod(edgePixColors(:,2),100);
% wsEdges2 = wsBoundaries;
% wsEdges2(edgePixColors(:,1)) = edgePixColors(:,2);
% % figure;imshow(wsEdges2);title('edges between junctions labeled separately')
%% extract edges with zero pixel length
% connectedJunctionIDs = getClusteredJunctions(wsJ);
disp('Extracting psuedo edges ..')
[connectedJunctionIDs,psuedoEdges2nodeInds] = ...
                getClusterNodesAndPsEdges(wsJ);
disp('done!')
% connectedJunctionIDs contain the same ID for each node that is connected
% together with zero length edges, in the 4 neighborhood.
% pEdges2nodes - each row will give 2 nodes connected by a zero length edge

%% Build the adjacency matrix of the junction nodes
% edge to pixel correspondence
disp('get edges2pixels ..')
edges2pixels = getEdges2Pixels(edgePixLabels);
disp('done!')
% edges2ignore = getEdgesToIgnore(edges2pixels,connectedJunctionIDs,sizeR,sizeC);
% for each node, get a list of edge IDs connected to it

numPsuedoEdges = size(psuedoEdges2nodeInds,1);
maxEdgeID = size(edges2pixels,1);
psuedoEdgeIDs = (maxEdgeID+1) : (maxEdgeID+numPsuedoEdges);
% append psuedoEdgeIDs to edges2pixels
edges2pixels = appendPsuedoEdgeIDs2edges2pixels(edges2pixels,psuedoEdgeIDs);

disp('get nodeEdges ..')
[nodeEdges,nodeInds,psuedoEdgeIDs,psuedoEdges2nodeInds] = getNodeEdges(ind4J,edgePixLabels,connectedJunctionIDs,sizeR,sizeC,...
            psuedoEdgeIDs,psuedoEdges2nodeInds);
disp('done!')

disp('get adjacencyMat')
% nodeEdges already contains psuedo edges
[adjacencyMat,edges2nodes,selfEdgeIDs,edges2nodes_edgeIDs] = getAdjacencyMat(nodeEdges);
disp('done!')
% all edges without 2 distinct nodes are assigned as selfEdges
str1 = sprintf('Number of self edges found = %d',numel(selfEdgeIDs));
disp(str1)

% remove ps edges from self edges, if any.
psuedoSelfEdgeIDs = intersect(selfEdgeIDs,psuedoEdgeIDs);
str1 = sprintf('%d out of %d self edges are psueodo edges. Removing those..',...
            numel(psuedoSelfEdgeIDs),numel(selfEdgeIDs));
disp(str1)
selfEdgeIDs = setdiff(selfEdgeIDs,psuedoEdgeIDs);


% psuedoEdges2nodeLIDs = getNodeLIDsForNodeIDs(psuedoEdges2nodes,nodeInds);
% edges2nodes = [edges2nodes; psuedoEdges2nodeLIDs];

% calculate new ws by merging those ws regions that were initially separated
ws_original = ws;
disp('getCorrectedWSregions ..')
[ws,removedWsIDs, newRemovedEdgeLIDs] = getCorrectedWSregions(ws,selfEdgeIDs,edges2pixels,displayImg);
disp('done!')

% initialize output
selfEdgePixelSet = [];

disp('remove selfedges ..')
if(selfEdgeIDs(1)~=0)
%     % remove selfEdges from nodeEdges, edges2nodes and edges2pixels
%     % edges2nodes
%     edges2nodes = edges2nodes((edges2nodes(:,1)~=0),:);
% 
%     [nodeEdgeRows,nodeEdgeCols] = size(nodeEdges);
%     numSelfEdges = numel(selfEdgeIDs);
%     for i=1:numSelfEdges
%         % nodeEdges
%         [rx,cx] = find(nodeEdges(:,2:nodeEdgeCols)==selfEdgeIDs(i));
%         cx = cx + 1; 
%         nodeEdges(rx,cx)=0;    
%         % edges2pixels
%         [~,selfEdgeLID_i] = intersect(edges2pixels(:,1),selfEdgeIDs(i)); 
%         selfEdgePixelSet = [selfEdgePixelSet; edges2pixels(selfEdgeLID_i,:)]; 
%         edges2pixels(selfEdgeLID_i,2:(size(edges2pixels,2))) = 0;  % set the self edge 'pixel' to zero
%     end
%     % from edges2pixels, remove the rows who's second column has a zero
%     edges2pixels = edges2pixels((edges2pixels(:,2)~=0),:);
%     % nodeEdges may contain zeros for edgeIDs among nonzero entries. get rid of
%     % the zeros
%     % the above operation also removes the psuedoEdges. Reinsert them:
%     edges2pixels = appendPsuedoEdgeIDs2edges2pixels(edges2pixels,psuedoEdgeIDs);
%     numNodes = size(nodeEdges,1);
%     for i=1:numNodes
%        nodeEdgesList_i = nodeEdges(i,(nodeEdges(i,:)>0)); 
%        numEdges = numel(nodeEdgesList_i);
%        for j=1:numEdges
%           nodeEdges2(i,j) = nodeEdgesList_i(j); 
%        end
%     end
%     nodeEdges = nodeEdges2;
%     clear nodeEdges2;
    
    nodeEdges = removeSelfEdgesFromNodeEdges(nodeEdges,selfEdgeIDs);
    
    [edges2pixels,edges2nodes,selfEdgePixelSet] = removeSelfEdgesFromEdges2Pixels2Nodes...
            (edges2pixels,edges2nodes,selfEdgeIDs);
    
    % Now, after removing the self edges, the graph contains some junctions
    % with only two edges connecting to them. i.e. they are not junctions
    % anymore but just edges. At the moment we just keep them. and treat them
    % as 2 edge junctions.
    
    
end

disp('done!')

disp('remove middle zeros from nodeEdges')
nodeEdges = removeMiddleZeros(nodeEdges);
disp('done!')


if(saveMatrices)
    save('edges2pixels.mat','edges2pixels')
end


%% visualize graph
if(0)
    [r,c] = ind2sub([sizeR sizeC],nodeInds);
    xy = [c r];
    % figure;gplot(adjacencyMat,xy,'-*');
    figure;gplotwl(adjacencyMat,xy);
    set(gca,'YDir','reverse');
    axis square
end


% n = size(adjacencyMat,1);
% k = 1:n;
% figure;gplot(adjacencyMat(k,k),xy(k,:),'-*')
% set(gca,'YDir','reverse');
% axis square

function nodeEdges = removeSelfEdgesFromNodeEdges(nodeEdges,selfEdgeIDs)

nodeInds = nodeEdges(:,1);
nodeEdges_wo_nIDs = nodeEdges;
nodeEdges_wo_nIDs(:,1) = []; % removed first col which contains the nodeIDs
selfEdgeIndInNodeEdges_logical = ismember(nodeEdges_wo_nIDs,selfEdgeIDs);
% selfEdgeIndInNodeEdges = find(selfEdgeIndInNodeEdges_logical);
% get which rows are affected
% [affectedRows,~] = find(selfEdgeIndInNodeEdges_logical);
% affectedRows = unique(affectedRows);

% set selfEdges to zero
nodeEdges_wo_nIDs(selfEdgeIndInNodeEdges_logical) = 0;
% some edgeIDs are set to zero and there are nonZero edgeIDs after them in
% the same row. Shift the edgeIDs appropriately so that there are no zeros
% in the middle of a row.
% if(numel(affectedRows)>0)
%     for i=1:numel(affectedRows)
%         rowID = affectedRows(i);
%         nzEdgeIDs = nodeEdges_wo_nIDs(rowID,:);
%         nzEdgeIDs = nzEdgeIDs(nzEdgeIDs>0);
%         nodeEdges_wo_nIDs(rowID,:) = 0;
%         nodeEdges_wo_nIDs(rowID,1:numel(nzEdgeIDs)) = nzEdgeIDs;
%     end
% end
nodeEdges = [nodeInds nodeEdges_wo_nIDs];

function [edges2pixels,edges2nodes,selfEdgePixelSet] = removeSelfEdgesFromEdges2Pixels2Nodes...
            (edges2pixels,edges2nodes,selfEdgeIDs)
        
% already removed psuedoEdgeIDs from selfEdgeIDs

        
edgeLIDsAll = edges2pixels(:,1);
[~,selfEdgeLIDs] = intersect(edgeLIDsAll,selfEdgeIDs);
selfEdgePixelSet = edges2pixels(selfEdgeLIDs,:);
selfEdgePixelSet(:,1) = [];
edges2pixels(selfEdgeLIDs,:) = 0;

% from edges2pixels, remove the rows who's first column has a zero
edges2pixels = edges2pixels((edges2pixels(:,1)~=0),:);
% nodeEdges may contain zeros for edgeIDs among nonzero entries. get rid of
% the zeros
% the above operation also removes the psuedoEdges. Reinsert them:
% edges2pixels = appendPsuedoEdgeIDs2edges2pixels(edges2pixels,psuedoEdgeIDs);

% remove selfEdges from nodeEdges, edges2nodes and edges2pixels
% edges2nodes

nodeLessEdgeLIDs_logical = (edges2nodes(:,1)==0);
nodeLessEdgeIDs = edgeLIDsAll(nodeLessEdgeLIDs_logical);

a = setdiff(nodeLessEdgeIDs,selfEdgeIDs);
b = setdiff(selfEdgeIDs,nodeLessEdgeIDs);
if(~isempty(a) || ~isempty(b))
    error('problem in edges2nodes. node-less edges and self edges dont match!!')
end
edges2nodes = edges2nodes(~nodeLessEdgeLIDs_logical,:);


function nodeEdges = removeMiddleZeros(nodeEdges)
nodeInds = nodeEdges(:,1);
nodeEdgesWoNIDs = nodeEdges;
nodeEdgesWoNIDs(:,1) = [];
numNodes = size(nodeEdges,1);
for i=1:numNodes
    nzEdges = nodeEdgesWoNIDs(i,:);
    nzEdges = nzEdges(nzEdges>0);
    nodeEdgesWoNIDs(i,:) = 0;
    nodeEdgesWoNIDs(i,1:numel(nzEdges)) = nzEdges;
end
nodeEdges = [nodeInds nodeEdgesWoNIDs] ;