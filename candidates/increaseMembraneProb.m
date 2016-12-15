function regionScoreOut = increaseMembraneProb...
    (regionScoreIn,regionSizes,threshScore,threshSize,replacementScore)
% (regionScoreIn,increaseFactor_prob,pickRegions_fraction)

% % version 1
% % regionScore is 1 for cell interior and 0 for membranes
% % sort the regions according to the membrane probability
% % increase the membrane probability of the top pickRegions_fraction regions
% % by a factor of increaseFactor_prob. Note that increase of membrane
% % probability means decrease of cell interior probability
% 
% numRegions = numel(regionScoreIn);
% regionScoreVector = reshape(regionScoreIn,numRegions,1);
% [sortedRegionScores,sortedInd] = sort(regionScoreVector);
% 
% numRegionsToChange = floor(numRegions * pickRegions_fraction);
% 
% % increase membrane probability = decrease cell interior probability
% % for the top numRegionsToChange only
% 
% regionIDsToChange = sortedInd(1:numRegionsToChange);
% scoresToChange = regionScoreVector(regionIDsToChange);
% newScores = scoresToChange .* (1 - increaseFactor_prob);
% 
% regionScoreOut = regionScoreIn;
% regionScoreOut(regionIDsToChange) = newScores;

% version 2
% order the regions in size
% pick the top (smallest) n regions
% replace their region score by r

numRegions = numel(regionScoreIn);
% get small regions having lower regionScore using given thresholds
rIndsToChange = (regionScoreIn < threshScore) & (regionSizes < threshSize);
regionScoreOut = regionScoreIn;
regionScoreOut(rIndsToChange) = replacementScore;




