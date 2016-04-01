% script_sbmrm data generation

produceBMRMfiles = 0;

rawType = 'tif';
neuronProbabilityType = 'tiff';
membraneProbabilityType = 'tif';
mitoProbabilityType = 'png';

% inputPath = '/home/thanuja/Dropbox/data/em_2013january/';
inputPath = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/isbiSegmentations/';
inputFileName = 'test-volume0000.tif';
outputPath = '/home/thanuja/projects/RESULTS/contours/20160321_debug/';
outputPathPNG = '/home/thanuja/projects/RESULTS/contours/20160321_debug/png';
saveIntermediateImages = 1;
saveIntermediateImagesPath = '/home/thanuja/projects/RESULTS/contours/20160321_debug/intermediate';
showIntermediateImages = 0;

% to generate sbmrm files for structured learning
labelImagePath = '/home/thanuja/Dropbox/data/em_2013january/neurons';
labelImageFileName = '00.tiff';

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