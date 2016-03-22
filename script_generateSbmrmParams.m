% script_sbmrm data generation

rawType = 'tif';
neuronProbabilityType = 'tiff';
membraneProbabilityType = 'tif';
mitoProbabilityType = 'png';

inputPath = '/home/thanuja/Dropbox/data/em_2013january/';
inputFileName = '00.tiff';
outputPath = '/home/thanuja/projects/RESULTS/contours/20160321_sbmrm';
outputPathPNG = '/home/thanuja/projects/RESULTS/contours/20160321_sbmrm/png';
saveIntermediateImages = 1;
saveIntermediateImagesPath = '/home/thanuja/projects/RESULTS/contours/20160321_sbmrm/intermediate';
showIntermediateImages = 0;

% to generate sbmrm files for structured learning
labelImagePath = '/home/thanuja/Dropbox/data/em_2013january/neurons';
labelImageFileName = '00.tiff';

% read all images in the raw images file path
rawImagePath = fullfile(inputPath,'raw');
allRawFiles = dir(fullfile(rawImagePath,'*.png'));

% for each file
numFiles = length(allRawFiles);
%for i=1:numFiles
i = 1;
%    disp(i);
%    imageFileName = allRawFiles(i).name;
     % imageFileName = fullfile(inputPath,inputFileName);
     segmentationOut = doILP_w_dir(inputPath,inputFileName,i,...
        rawType,neuronProbabilityType,membraneProbabilityType,mitoProbabilityType,...
        saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
        labelImagePath,labelImageFileName);
    % save segmentation output
    writeFileName = fullfile(outputPath,imageFileName);
    imwrite(segmentationOut,writeFileName,'tif');
    pngFileName = sprintf('%d.png',(i-1));
    pngFileName = fullfile(outputPathPNG,pngFileName);
    imwrite(segmentationOut,pngFileName,'png');
%end