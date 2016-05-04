% script_sbmrm data generation

produceBMRMfiles = 0;

rawType = 'tif';
neuronProbabilityType = 'png';
membraneProbabilityType = 'tiff';
mitoProbabilityType = 'png';

% inputPath = '/home/thanuja/Dropbox/data/em_2013january/';
inputPath = '/home/thanuja/projects/data/toyData/set8/';
inputFileName = '00.tif';
outputPath = '/home/thanuja/projects/RESULTS/contours/20160403_sbmrm/';
outputPathPNG = '/home/thanuja/projects/RESULTS/contours/20160403_sbmrm/png';
saveIntermediateImages = 1;
saveIntermediateImagesPath = '/home/thanuja/projects/RESULTS/contours/20160403_sbmrm/intermediate';
showIntermediateImages = 0;

% to generate sbmrm files for structured learning
labelImagePath = '/home/thanuja/projects/data/toyData/set8/neurons';
labelImageFileName = 'neurons0000.png';

% read all images in the raw images file path
rawImagePath = fullfile(inputPath,'raw');
allRawFiles = dir(fullfile(rawImagePath,strcat('*',rawType)));

% for each file
numFiles = length(allRawFiles);
%for i=1:numFiles
i = 1;
%    disp(i);
     % imageFileName = allRawFiles(i).name;
     imageFileName = fullfile(inputPath,inputFileName);
     segmentationOut = doILP_w_dir(inputPath,inputFileName,i,...
        rawType,neuronProbabilityType,membraneProbabilityType,mitoProbabilityType,...
        saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
        labelImagePath,labelImageFileName,produceBMRMfiles);
    % save segmentation output
    writeFileName = fullfile(outputPath,inputFileName);
    imwrite(segmentationOut,writeFileName,'tif');
    pngFileName = sprintf('%d.png',(i-1));
    pngFileName = fullfile(outputPathPNG,pngFileName);
    imwrite(segmentationOut,pngFileName,'png');
%end