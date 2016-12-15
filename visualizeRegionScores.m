function regionScoreImg = visualizeRegionScores(regionScores,ws,wsIndsForRegion)
% region scores contain the cell interior probability for each region
% ws - watershed labels
% wsIndsForRegion - contains the wsID for the regionID(=ind)

numRegions = numel(regionScores);
[sizeR, sizeC] = size(ws);
regionScoreImg = zeros(sizeR,sizeC);
for i=1:numRegions
    pixInds = getInternalPixForCell(ws,wsIndsForRegion(i));
    if(~isempty(pixInds))
        regionScoreImg(pixInds) = regionScores(i);
    end
end


