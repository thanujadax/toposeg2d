% debug image small

rawImageDir = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/contoursSBMRM/raw';
rawImageFileName = '01.tif';
membraneProbMapFullFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/contoursSBMRM/membranes/01.tif';
mitoProbMapFullFileName = '';

outputPath = '/home/thanuja/projects/RESULTS/contours/20160510_sbmrm';
outputPathPNG = '/home/thanuja/projects/RESULTS/contours/20160509/png';
sbmrmOutputDir = '/home/thanuja/projects/RESULTS/contours/20160510_sbmrm/sbmrmRun';
saveIntermediateImages = 1;
saveIntermediateImagesPath = '/home/thanuja/projects/RESULTS/contours/20160510_sbmrm/intermediate';
showIntermediateImages = 0;
labelImageFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/contoursSBMRM/labels/01.tif';
produceBMRMfiles = 1;

segmentationOut = doILP_w_dir(rawImageDir,rawImageFileName,...
    membraneProbMapFullFileName,mitoProbMapFullFileName,...
    saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
    outputPath,produceBMRMfiles,labelImageFileName,sbmrmOutputDir);

writeFileName = fullfile(outputPath,rawImageFileName);
imwrite(segmentationOut,writeFileName,'tif');
% pngFileName = sprintf('%s.png',(i-1));
% pngFileName = fullfile(outputPathPNG,pngFileName);
% imwrite(segmentationOut,pngFileName,'png');