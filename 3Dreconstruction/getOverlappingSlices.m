function slicesAll = getOverlappingSlices(...
            slicesAll,slicesPerSection,searchRadius)
        
% Output: 
% slicesAll struct will have a new field containing an array with all the
% overlapping slices of the (i)th slice
% slicesAll = struct(...
%         'sectionID',0,...
%         'sliceLID',0,... - local sliceID w.r.t the current sectionID
%         'pixelInds',[],...
%         'overlapSlices',[] - contains absolute sliceIDs ;
%         'overlapSliceLabels',[] - only makes sense for GT input for sbmrm  
%         'minOverlaps',[] - fractions );
%         'maxOverlaps'


% version 0.1: don't use search radius. only collect the slices which are
% directly overlapping in the next section
% TODO: search radius -> version 0.2

slicesAll().overlapSlices = [];
slicesAll().overlapSliceLabels = [];
slicesAll().minOverlaps = [];
slicesAll().maxOverlaps = [];
slicesAll().sizeDifferences = [];
numSections = numel(slicesPerSection);
currentSliceID = 0;

for i=1:numSections-1
    % we process from the 1st section to the (n-1)th section
    % link variables are defined from left(i) to right(i+1)
    for j=1:slicesPerSection(i)
        currentSliceID = currentSliceID + 1;
        slicePixels = slicesAll(currentSliceID).pixelInds;
        
        [overlapSliceIDs, ...
            slicesAll(currentSliceID).minOverlaps,...
            slicesAll(currentSliceID).maxOverlaps,...
            slicesAll(currentSliceID).sizeDifferences] = ...
            getOverlapSlicesGivenPixels(slicePixels,slicesAll,i,...
            slicesPerSection);
        
        slicesAll(currentSliceID).overlapSlices = overlapSliceIDs;
        % get the initial neuronIDs (labels) for the overlapping slices
        if(numel(overlapSliceIDs)>0)
            overlapSliceLabels = zeros(numel(overlapSliceIDs),1);
            for k=1:numel(overlapSliceIDs)
                olabel = slicesAll(overlapSliceIDs(k)).originalLabel;
                overlapSliceLabels(k,1:numel(olabel)) = slicesAll(overlapSliceIDs(k)).originalLabel;
            end
            slicesAll(currentSliceID).overlapSliceLabels = overlapSliceLabels;
        end
    end
end

    