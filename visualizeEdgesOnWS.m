function visualizeEdgesOnWS(ws,edgeIDs,edges2pixels)
% under utilized edges are the edges that appear only in one region, when
% building up c_setOfRegions. This (debug) method visualizes these edges in
% the ws region map

edgeIDsAll = edges2pixels(:,1);
edgepixels = edges2pixels;
edgepixels(:,1) = [];

[~,edgeListIndsToVisualize] = intersect(edgeIDsAll,edgeIDs);

edgePixelsToVisualize = edgepixels(edgeListIndsToVisualize,:);
edgePixelsToVisualize = edgePixelsToVisualize(edgePixelsToVisualize>0);

ws2 = assignRandomIndicesToWatershedTransform(ws);
edgeCode = 2 * max(max(ws2));

ws2(edgePixelsToVisualize) = edgeCode;

figure;imagesc(ws2)


