function [regionPriors,regionScoreImg,regionSizes] = getCellPriors_probability(pixelProbabilities,setOfCells,...
    sizeR,sizeC,wsIndsForRegion,ws,displayImg,saveIntermediateImages,...
    saveIntermediateImagesPath,rawImageIDstr,saveOutputFormat)
% Inputs:
%   imgIn(pixelProbabilities) - normalized image. 1 -> bright
%   K - positive scalar factor for the costs 

% Output:
%   cellPriors - value between K (membrane) and -K (cell interior). 

% numpixels = numel(pixelProbabilities);

numCells = size(setOfCells,1);
regionPriors = zeros(numCells,1);
regionSizes = zeros(numCells,1);
regionScoreImg = zeros(sizeR,sizeC);

for i=1:numCells
    
    edgeSet_cell = setOfCells(i,:);
    edgeSet_cell = edgeSet_cell(edgeSet_cell>0);
    % get boundary pixels of each cell
%     boundaryPixels = getBoundaryPixelsForCell(edgeSet_cell,edges2pixels,...
%         nodeInds,edges2nodes,edges2pixels(:,1));

    % get internal pixels of each cell
%     [internalx,internaly] = getInternelPixelsFromBoundary(boundaryPixels,sizeR,sizeC);
%     
%     intPixInds = sub2ind([sizeR sizeC],internaly,internalx);
    
    intPixInds = getInternalPixForCell(ws,wsIndsForRegion(i));
    regionSizes(i) = numel(intPixInds);
    
    if(~isempty(intPixInds))
        pixelValues = pixelProbabilities(intPixInds);

        % cellPriors(i) = 1 - 2* mean(pixelValues);

        meanPixVal = mean(pixelValues); % always between 0 and 1
        theta = meanPixVal * pi;
        % regionPriors(i) = cos(theta) * K;
        regionPriors(i) = meanPixVal;
    else
        regionPriors(i) = 0;
    end
    regionScoreImg(intPixInds) = regionPriors(i);
end
% % test code
% increaseFactor_prob = 0.2;
% pickRegions_fraction = 0.2;
% regionPriorsOut = increaseMembraneProb...
%     (regionPriors,increaseFactor_prob,pickRegions_fraction);
% % end of test code

% visualize region scores

regionScoreImg = regionScoreImg./(max(max(regionScoreImg)));
if(saveIntermediateImages)
    intermediateImgDescription = 'regionUnary';
    saveIntermediateImage(regionScoreImg,rawImageIDstr,intermediateImgDescription,...
saveIntermediateImagesPath,saveOutputFormat);
end