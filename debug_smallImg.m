% debug image small

produceBMRMfiles = 0;

rawImageDir = '/home/thanuja/projects/data/toyData/set8/raw';
rawImageFileName = '03.tif';
membraneProbMapFullFileName = '/home/thanuja/projects/data/toyData/set8/membranes_rfc/03_probability.tif';
mitoProbMapFullFileName = '';

outputRoot = '/home/thanuja/projects/RESULTS/contours/20160517';

checkAndCreateSubDir(outputRoot,'001');
outputPath = fullfile(outputRoot,'001');

checkAndCreateSubDir(outputPath,'png');
outputPathPNG = fullfile(outputPath,'png');

sbmrmOutputDir = fullfile(outputPath,'sbmrmRun');
checkAndCreateSubDir(outputPath,'sbmrmRun');

saveIntermediateImages = 1;
saveIntermediateImagesPath = fullfile(outputPath,'intermediate');
checkAndCreateSubDir(outputPath,'intermediate');

showIntermediateImages = 1;
labelImageFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/contoursSBMRM/labels/01.tif';



dbstop if error
segmentationOut = doILP_w_dir(rawImageDir,rawImageFileName,...
    membraneProbMapFullFileName,mitoProbMapFullFileName,...
    saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
    outputPath,produceBMRMfiles,labelImageFileName,sbmrmOutputDir);

writeFileName = fullfile(outputPath,rawImageFileName);
imwrite(segmentationOut,writeFileName,'tif');
% pngFileName = sprintf('%s.png',(i-1));
% pngFileName = fullfile(outputPathPNG,pngFileName);
% imwrite(segmentationOut,pngFileName,'png');

% what are the conditions for the error to occur
% how to automatically stop at debug