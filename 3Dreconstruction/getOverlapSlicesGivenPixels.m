function overlapSliceIDs = getOverlapSlicesGivenPixels...
            (slicePixels,slicesAll,sectionID,slicesPerSection,sizeR,sizeC)

% Output:
%  overlapSliceIDs - absolute sliceIDs of slices of the next section that
%  overlaps with the pixels given for the current slice. Column vector
        
nextSectionID = sectionID + 1;

nextSectionSliceID_start = sum(slicesPerSection(1:sectionID)) + 1;
nextSectionSliceID_stop = nextSectionSliceID_start + ...
        slicesPerSection(nextSectionID) - 1;
    
overlapSliceIDs = [];

for i = nextSectionSliceID_start:nextSectionSliceID_stop
    nextSlicePixels = slicesAll.pixelInds;
    commonPix = intersect(slicePixels,nextSlicePixels);
    if(~isempty(commonPix))
        overlapSliceIDs = [overlapSliceIDs; i'];
    end
end