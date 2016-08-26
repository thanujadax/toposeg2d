function imCombined = combineBlocks2Image(blockDir,outputPathPNG,blockDirName,...
    rawImageIDstr,rOverlap,cOverlap,sizeR,sizeC,blockFileType)

imCombined = zeros(sizeR,sizeC);

% read all the images in the blockDir
blockFilesDirList = dir(fullfile(blockDir,blockFileType));


for i=1:numel(blockFilesDirList)    
    % make black and white images (foreground background)
    % stitch them together using min values at borders
    % assign neuron IDs (unique colors)
    im_i = imread(fullfile(blockDir,blockFilesDirList(i).name));
    im_i = im2bw(im_i, 0);
    
end


    
