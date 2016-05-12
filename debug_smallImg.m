% debug image small

rawImageDir = '/home/thanuja/projects/data/toyData/set8/raw';
rawImageFileName = '02.tif';
membraneProbMapFullFileName = '/home/thanuja/projects/data/toyData/set8/membranes_rfc/02_probability.tif';
mitoProbMapFullFileName = '';

outputPath = '/home/thanuja/projects/RESULTS/contours/20160510/01_withoutRegionThresh';
outputPathPNG = '/home/thanuja/projects/RESULTS/contours/20160509/png';
sbmrmOutputDir = '/home/thanuja/projects/RESULTS/contours/20160510_sbmrm/sbmrmRun';
saveIntermediateImages = 1;
saveIntermediateImagesPath = '/home/thanuja/projects/RESULTS/contours/20160510_sbmrm/intermediate';
showIntermediateImages = 1;
labelImageFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/contoursSBMRM/labels/01.tif';
produceBMRMfiles = 0;
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