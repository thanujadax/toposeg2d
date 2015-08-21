% debug image small

rawType = 'png';
neuronProbabilityType = 'png';
membraneProbabilityType = 'png';
mitoProbabilityType = 'png';

inputPath = '/home/thanuja/projects/data/toyData/set5/';
outputPath = '/home/thanuja/projects/tests/contours/20150514';
outputPathPNG = '/home/thanuja/projects/tests/contours/20150514png';
saveIntermediateImages = 1;
saveIntermediateImagesPath = '/home/thanuja/projects/tests/contours/20150820/smallimg';
showIntermediateImages = 0;

% read all images in the raw images file path
rawImagePath = fullfile(inputPath,'raw');
allRawFiles = dir(fullfile(rawImagePath,'*.png'));

% for each file
numFiles = length(allRawFiles);
%for i=1:numFiles
i = 1;
    disp(i);
    imageFileName = allRawFiles(i).name;
    segmentationOut = doILP_w_dir(inputPath,imageFileName,i,...
        rawType,neuronProbabilityType,membraneProbabilityType,mitoProbabilityType,...
        saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages);
    % save segmentation output
    writeFileName = fullfile(outputPath,imageFileName);
    imwrite(segmentationOut,writeFileName,'tif');
    pngFileName = sprintf('%d.png',(i-1));
    pngFileName = fullfile(outputPathPNG,pngFileName);
    imwrite(segmentationOut,pngFileName,'png');
%end