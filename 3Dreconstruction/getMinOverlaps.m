function [minOverlap_i,maxOverlap_i]= getMinOverlaps...
    (slicePixels,nextSlicePixels,commonPix)

% returns the minimum relative overlap of a given start slice and a
% stop slice

numPix1 = numel(slicePixels);
numPix2 = numel(nextSlicePixels);
numOverlapPix = numel(commonPix);

overlap1 = numOverlapPix/numPix1;
overlap2 = numOverlapPix/numPix2;

minOverlap_i = min(overlap1,overlap2);
maxOverlap_i = max(overlap1,overlap2);
