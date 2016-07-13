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
%         'minOverlaps',[] - fractions );

% version 0.1: don't use search radius. only collect the slices which are
% directly overlapping in the next section
% TODO: search radius -> version 0.2

slicesAll().OverlapSlices = [];
numSections = numel(slicesPerSection);
currentSliceID = 0;

for i=1:numSections-1
    % we process from the 1st section to the (n-1)th section
    % link variables are defined from left(i) to right(i+1)
    for j=1:slicesPerSection(i)
        currentSliceID = currentSliceID + 1;
        slicePixels = slicesAll(currentSliceID).pixelInds;
        [slicesAll(currentSliceID).overlapSlices, ...
            slicesAll(currentSliceID).minOverlaps] = ...
            getOverlapSlicesGivenPixels(slicePixels,slicesAll,i,...
            slicesPerSection);
    end
end

    