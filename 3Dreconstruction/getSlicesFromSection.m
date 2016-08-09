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

str1 = sprintf('Extracting slices from image file: %s',imageFileName);
disp(str1)

im = double(imread(imageFileName));
[sizeR,sizeC,sizeZ] = size(im); 
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
        'pixelInds',cc.PixelIdxList);
    for i=1:cc.NumObjects
        slices(i).sectionID = sectionID;
        slices(i).sliceID = i;
        % slices(i).pixelInds = cc.PixelIdxList{i};
        % pixelInds are already set during initialization using
        % cc.PixelIdxList
        pix = cc.PixelIdxList{i}(1);
        [pR,pC] = ind2sub([sizeR sizeC],pix);
        if(size(im,3)==3)
            %gr = rgb2gray(im);
            % get RGB label vector
            slices(i).originalLabel = reshape(im(pR,pC,:),1,3); 
        else
            % get gray value
            slices(i).originalLabel = im(pR,pC); 
            % assigns the pixel intensity as label
        end
        
    end
    
else
    str1 = sprintf('!!No slices found for section %d !!',sectionID);
    disp(str1)
    
end