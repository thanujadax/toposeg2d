function canvas = combineBlocks2Image(blockDirFull,outputPathPNG,...
    rawImageIDstr,rStep,cStep,rOverlap,cOverlap,sizeR,sizeC,blockFileType)

canvas = zeros(sizeR,sizeC);

% read all the images in the blockDir
blockFilesDirList = dir(fullfile(blockDirFull,strcat('*.',blockFileType)));

% replace the pixel value of the canvas with max(currentVal,blockVal)

for i=1:numel(blockFilesDirList)    
    % make black and white images (foreground background)
    % stitch them together using min values at borders
    % assign neuron IDs (unique colors)
    im_i = imread(fullfile(blockDirFull,blockFilesDirList(i).name));
    im_i = im2bw(im_i, 0); % any value above zero is replaced by 1
    % get the corner coordinates of the block wrt canvas
    [blockSizeR,blockSizeC] = size(im_i);
    [rStart,rStop,cStart,cStop] = getBlockPositionForCanvas...
        (blockFilesDirList(i).name,rStep,cStep,rOverlap,cOverlap,sizeR,sizeC);
    % max fill
    canvas = maxFillCanvas(canvas,im_i,rStart,rStop,cStart,cStop);
    
end

% save canvas in output path with corresponding rawImg file name
outputFileName = fullfile(outputPathPNG,strcat(rawImageIDstr,'.',blockFileType));
figure;imshow(canvas)
imwrite(canvas,outputFileName);
str1 = sprintf('Output segmentation (combined canvas) saved at %s',...
    outputFileName);
disp(str1)
