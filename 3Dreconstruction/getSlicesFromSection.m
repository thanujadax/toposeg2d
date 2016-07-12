function slices = getSlicesFromSection(imageFileName,sectionID)

% Inputs

% Output:
%   slices - structure array. Each structure has the
%   following fields:
%       slices(i).sectionID
%       slices(i).sliceLID - local ID w.r.t the current sectionID
%       slices(i).pixelInds

im = double(imread(imageFileName));
figure;imagesc(im)
level = 0;
bw = im2bw(im,level);
figure;imagesc(bw)

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
        'pixelInds',cc.PixelIdxList);
    for i=1:cc.NumObjects
        slices(i).sectionID = sectionID;
        slices(i).sliceID = i;
        % slices(i).pixelInds = cc.PixelIdxList{i};
        % pixelInds are already set during initia
    end
    
else
    str1 = sprintf('No slices found for section %d',sectionID);
    disp(str1)
    
end