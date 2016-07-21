% 
% rawType = 'tif';
% neuronProbabilityType = 'png';
% membraneProbabilityType = 'tiff';
% mitoProbabilityType = 'png';
% 
% inputPath = '/home/thanuja/projects/toyData/set8/';
% outputPath = '/home/thanuja/Dropbox/RESULTS/contourdetection/batch20140823/';
% outputPathPNG = '/home/thanuja/Dropbox/RESULTS/contourdetection/batch20140823_png/';
% % read all images in the raw images file path
% rawImagePath = fullfile(inputPath,'raw');
% allRawFiles = dir(fullfile(rawImagePath,'*.tif'));
% 
% % for each file
% numFiles = length(allRawFiles);
% for i=1:numFiles
%     disp(i);
%     imageFileName = allRawFiles(i).name;
%     segmentationOut = doILP_w_dir(inputPath,imageFileName,i,...
%         rawType,neuronProbabilityType,membraneProbabilityType,mitoProbabilityType);
%     % save segmentation output
%     writeFileName = fullfile(outputPath,imageFileName);
%     imwrite(segmentationOut,writeFileName,'tif');
%     pngFileName = sprintf('%d.png',(i-1));
%     pngFileName = fullfile(outputPathPNG,pngFileName);
%     imwrite(segmentationOut,pngFileName,'png');
% end
% 
% %%%

produceBMRMfiles = 0;

rawImageDir = '/home/thanuja/projects/data/toyData/set8/raw';
rawImageType = '*.tif';
membraneProbMapDir = '/home/thanuja/projects/data/toyData/set8/membranes_rfc';
membraneProbMapType = '*.tif';
mitoProbMapFullFileName = '';

outputRoot = '/home/thanuja/projects/RESULTS/contours/20160721';
saveOutputFormat = 'png'; % allowed: 'png', 'tif'

checkAndCreateSubDir(outputRoot,'000');
outputPath = fullfile(outputRoot,'000');

checkAndCreateSubDir(outputPath,'png');
outputPathPNG = fullfile(outputPath,'png');

sbmrmOutputDir = fullfile(outputPath,'sbmrmRun');
checkAndCreateSubDir(outputPath,'sbmrmRun');

saveIntermediateImages = 1;
saveIntermediateImagesPath = fullfile(outputPath,'intermediate');
checkAndCreateSubDir(outputPath,'intermediate');

showIntermediateImages = 0;
%labelImageFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/contoursSBMRM/labels/00.tif';
labelImageFileName = '/home/thanuja/projects/data/toyData/set12_sbmrm/groundtruth/00.tif';

logFileName = 'log.txt';
logFileFullPath = fullfile(outputPath,logFileName);

dbstop if error

rawFilesDirList = dir(fullfile(rawImageDir,rawImageType));
memProbMapDirList = dir(fullfile(membraneProbMapDir,membraneProbMapType));
for i=1:numel(rawFilesDirList)
    rawImageFileName = rawFilesDirList(i).name; % name without path
    membraneProbFileName = memProbMapDirList(i).name; %name without path
    str1 = sprintf('Raw file name: %s',rawImageFileName);
    disp(str1)
    str1 = sprintf('Membrane Prob Map file name: %s',membraneProbFileName);
    disp(str1)
    membraneProbMapFullFileName = fullfile(membraneProbMapDir,membraneProbFileName);
    segmentationOut = doILP_w_dir(rawImageDir,rawImageFileName,...
        membraneProbMapFullFileName,mitoProbMapFullFileName,...
        saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
        outputPath,produceBMRMfiles,labelImageFileName,sbmrmOutputDir,saveOutputFormat,...
        logFileFullPath);

    rawImageID = strtok(rawImageFileName,'.');
    writeFileName = fullfile(outputPathPNG,strcat(rawImageID,'.',saveOutputFormat));
    imwrite(segmentationOut,writeFileName,saveOutputFormat);

end
% pngFileName = sprintf('%s.png',(i-1));
% pngFileName = fullfile(outputPathPNG,pngFileName);
% imwrite(segmentationOut,pngFileName,'png');

% what are the conditions for the error to occur
% how to automatically stop at debug