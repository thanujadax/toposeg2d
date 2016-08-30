function canvas = combineBlocks2Image(blockDir,outputPathPNG,blockDirName,...
    rawImageIDstr,rOverlap,cOverlap,sizeR,sizeC,blockFileType)

canvas = zeros(sizeR,sizeC);

% read all the images in the blockDir
blockFilesDirList = dir(fullfile(blockDir,blockFileType));

% replace the pixel value of the canvas with max(currentVal,blockVal)

for i=1:numel(blockFilesDirList)    
    % make black and white images (foreground background)
    % stitch them together using min values at borders
    % assign neuron IDs (unique colors)
    im_i = imread(fullfile(blockDir,blockFilesDirList(i).name));
    im_i = im2bw(im_i, 0); % any value above zero is replaced by 1
    % get the corner coordinates of the block wrt canvas
    [blockSizeR,blockSizeC] = size(im_i);
    [rStart,rStop,cStart,cStop] = getBlockPositionForCanvas...
        (blockFilesDirList(i).name,blockSizeR,blockSizeC,sizeR,sizeC);
    % max fill
    canvas = maxFillCanvas(canvas,im_i,rStart,rStop,cStart,cStop);
    
end
