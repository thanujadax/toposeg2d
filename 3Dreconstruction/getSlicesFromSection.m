function slices = getSlicesFromSection(imageFileName,sectionID)

% Inputs

% Output:
%   slices - structure array. Each structure has the
%   following fields:
%       slices(i).sectionID
%       slices(i).sliceLID - local ID w.r.t the current sectionID
%       slices(i).pixelInds
%       slices(i).originalLabel - stores the pixelIntensity of the input
%       segmentations to be used for sbmrm as initial neuron label (GS)

im = double(imread(imageFileName));
% figure;imagesc(im)
level = 0;
bw = im2bw(im,level);
% figure;imagesc(bw)

% get connected components

cc = bwconncomp(bw);
% e.g.: CC = 
% 
%     Connectivity: 26
%        ImageSize: [3 3 3]
%       NumObjects: 2
%     PixelIdxList: {[5x1 double]  [3x1 double]} - contains linear indices

slices = [];
if(cc.NumObjects>0)
    slices = struct(...
        'sectionID',0,...
        'sliceLID',0,...
        'pixelInds',cc.PixelIdxList,...
        'originalLabel',0.0);
    for i=1:cc.NumObjects
        slices(i).sectionID = sectionID;
        slices(i).sliceID = i;
        % slices(i).pixelInds = cc.PixelIdxList{i};
        % pixelInds are already set during initialization using
        % cc.PixelIdxList
        slices(i).originalLabel = bw(cc.PixelIdxList{i}(1)); % assigns the pixel intensity as label
    end
    
else
    str1 = sprintf('!!No slices found for section %d !!',sectionID);
    disp(str1)
    
end