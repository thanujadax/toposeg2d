% debug image small

rawImageDir = '/home/thanuja/projects/data/toyData/set8/raw';
rawImageFileName = '01.tif';
membraneProbMapFullFileName = '/home/thanuja/projects/data/toyData/set8/membranes_rfc/01_probability.tif';
mitoProbMapFullFileName = '';

outputRoot = '/home/thanuja/projects/RESULTS/contours/20160517_sbmrm';

checkAndCreateSubDir(outputRoot,'gsig55');
outputPath = fullfile(outputRoot,'gsig55');

checkAndCreateSubDir(outputPath,'png');
outputPathPNG = fullfile(outputPath,'png');

sbmrmOutputDir = fullfile(outputPath,'sbmrmRun');
checkAndCreateSubDir(outputPath,'sbmrmRun');

saveIntermediateImages = 1;
saveIntermediateImagesPath = fullfile(outputPath,'intermediate');
checkAndCreateSubDir(outputPath,'intermediate');

showIntermediateImages = 1;
labelImageFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/contoursSBMRM/labels/01.tif';
produceBMRMfiles = 1;
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