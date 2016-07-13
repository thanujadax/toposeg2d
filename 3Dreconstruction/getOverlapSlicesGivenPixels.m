function [overlapSliceIDs,minOverlap] = getOverlapSlicesGivenPixels...
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

for i = nextSectionSliceID_start:nextSectionSliceID_stop
    nextSlicePixels = slicesAll(i).pixelInds;
    commonPix = intersect(slicePixels,nextSlicePixels);
    if(~isempty(commonPix))
        overlapSliceIDs = [overlapSliceIDs; i];
        minOverlap_i = getMinOverlaps(slicePixels,nextSlicePixels,commonPix);
        minOverlap = [minOverlap; minOverlap_i];
    end
end