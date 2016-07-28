function [minOverlap_i,maxOverlap_i,sizeMatch_i]= getMinOverlaps...
    (slicePixels,nextSlicePixels,commonPix)

% returns the minimum relative overlap, max relative overlap and the size
% difference score of a given start slice and a
% stop slice

numPix1 = numel(slicePixels);
numPix2 = numel(nextSlicePixels);
numOverlapPix = numel(commonPix);

overlap1 = numOverlapPix/numPix1;
overlap2 = numOverlapPix/numPix2;

minOverlap_i = min(overlap1,overlap2);
maxOverlap_i = max(overlap1,overlap2);

sizeMatch_i = abs(numPix1-numPix2)/min(numPix1,numPix2);
