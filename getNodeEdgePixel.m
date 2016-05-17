function nodePixels = getNodeEdgePixel(nodeInd,edgePixelInds,sizeR,sizeC,maxNumPix)
% nodeInd contains the pixel index of a junction node
% edgePixelInds contains a set of pixel indices of an edge attached to the
% given node
% nodePixels (output) are the 3 edge pixel indices which are closest to the node
% pixel. If there are less than 3 such pixels, only those are returned.


nextNodeInd = nodeInd;
if nargin < 5
    maxNumPix = 5;
end
numEdgePixels = numel(edgePixelInds);
if(numEdgePixels<maxNumPix)
    maxNumPix = numEdgePixels;
end
nodePixels = zeros(maxNumPix,1);

for i=1:maxNumPix
    [nodeR,nodeC] = ind2sub([sizeR sizeC],nextNodeInd);
    [pixR,pixC] = ind2sub([sizeR sizeC],edgePixelInds);
    % select the pixel which is closest to the junction node
    distance = (pixR-nodeR).^2 + (pixC-nodeC).^2;
    [sortedDists, sortedInd] = sort(distance);
    sortedPixInds = edgePixelInds(sortedInd);
    nodePixels(i) = sortedPixInds(1);
    nextNodeInd = sortedPixInds(1);
    edgePixelInds(sortedInd(1)) = [];
end
% nodePixels = sortedPixInds(1:maxNumPix); 