% debug image small

produceBMRMfiles = 0;

rawImageDir = '/home/thanuja/projects/data/toyData/set8/raw';
rawImageFileName = '00.tif';
membraneProbMapFullFileName = '/home/thanuja/projects/data/toyData/set8/membranes_rfc/00_probability.tif';
mitoProbMapFullFileName = '';

outputRoot = '/home/thanuja/projects/RESULTS/contours/20160529';
saveOutputFormat = 'png'; % allowed: 'png', 'tif'

checkAndCreateSubDir(outputRoot,'009');
outputPath = fullfile(outputRoot,'009');

checkAndCreateSubDir(outputPath,'png');
outputPathPNG = fullfile(outputPath,'png');

sbmrmOutputDir = fullfile(outputPath,'sbmrmRun');
checkAndCreateSubDir(outputPath,'sbmrmRun');

saveIntermediateImages = 1;
saveIntermediateImagesPath = fullfile(outputPath,'intermediate');
checkAndCreateSubDir(outputPath,'intermediate');

showIntermediateImages = 1;
%labelImageFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/contoursSBMRM/labels/00.tif';
labelImageFileName = '/home/thanuja/projects/data/toyData/set12_sbmrm/groundtruth/00.tif';

logFileName = 'log.txt';
logFileFullPath = fullfile(outputPath,logFileName);


dbstop if error
segmentationOut = doILP_w_dir(rawImageDir,rawImageFileName,...
    membraneProbMapFullFileName,mitoProbMapFullFileName,...
    saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
    outputPath,produceBMRMfiles,labelImageFileName,sbmrmOutputDir,saveOutputFormat,...
    logFileFullPath);

writeFileName = fullfile(outputPath,rawImageFileName);
imwrite(segmentationOut,writeFileName,saveOutputFormat);
% pngFileName = sprintf('%s.png',(i-1));
% pngFileName = fullfile(outputPathPNG,pngFileName);
% imwrite(segmentationOut,pngFileName,'png');

% what are the conditions for the error to occur
% how to automatically stop at debug