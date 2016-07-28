function [overlapSliceIDs,minOverlap,maxOverlap,sizeMatch] = ...
    getOverlapSlicesGivenPixels...
            (slicePixels,slicesAll,sectionID,slicesPerSection)

% Output:
%  overlapSliceIDs - absolute sliceIDs of slices of the next section that
%  overlaps with the pixels given for the current slice. Column vector
        
nextSectionID = sectionID + 1;

nextSectionSliceID_start = sum(slicesPerSection(1:sectionID)) + 1;
nextSectionSliceID_stop = nextSectionSliceID_start + ...
        slicesPerSection(nextSectionID) - 1;
    
overlapSliceIDs = [];
minOverlap = [];
maxOverlap = [];
sizeMatch = [];

for i = nextSectionSliceID_start:nextSectionSliceID_stop
    nextSlicePixels = slicesAll(i).pixelInds;
    commonPix = intersect(slicePixels,nextSlicePixels);
    if(~isempty(commonPix))
        overlapSliceIDs = [overlapSliceIDs; i];
        [minOverlap_i,maxOverlap_i,sizeMatch_i] = getMinOverlaps...
            (slicePixels,nextSlicePixels,commonPix);
        minOverlap = [minOverlap; minOverlap_i];
        maxOverlap = [maxOverlap; maxOverlap_i];
        sizeMatch = [sizeMatch; sizeMatch_i];
    end
end