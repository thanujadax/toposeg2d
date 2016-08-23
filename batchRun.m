produceBMRMfiles = 0;
%labelImageFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/contoursSBMRM/labels/00.tif';
labelImageFileName = '/home/thanuja/projects/data/toyData/set12_sbmrm/groundtruth/00.tif';
% labelImageFileName = '/home/thanuja/projects/data/toyData/set8/groundtruth/00.tif';

rawImageDir = '/home/thanuja/projects/data/toyData/set8/raw';
rawImageType = '*.tif';
membraneProbMapDir = '/home/thanuja/projects/data/toyData/set8/membranes_rfc';
membraneProbMapType = '*.tif';
mitoProbMapFullFileName = '';

outputRoot = '/home/thanuja/projects/RESULTS/contours/20160823';
saveOutputFormat = 'png'; % allowed: 'png', 'tif'

checkAndCreateSubDir(outputRoot,'003');
outputPath = fullfile(outputRoot,'003');

checkAndCreateSubDir(outputPath,'png');
outputPathPNG = fullfile(outputPath,'png');

sbmrmOutputDir = fullfile(outputPath,'sbmrmRun');
checkAndCreateSubDir(outputPath,'sbmrmRun');

saveIntermediateImages = 1;
saveIntermediateImagesPath = fullfile(outputPath,'intermediate');
checkAndCreateSubDir(outputPath,'intermediate');

showIntermediateImages = 0;


logFileName = 'log.txt';
logFileFullPath = fullfile(outputPath,logFileName);

dbstop if error

barLength = 13; % should be odd
barWidth = 4; % should be even?

rawFilesDirList = dir(fullfile(rawImageDir,rawImageType));
memProbMapDirList = dir(fullfile(membraneProbMapDir,membraneProbMapType));
if(produceBMRMfiles)
    numFilesToProcess = 1;
else
    numFilesToProcess = numel(rawFilesDirList);
end
for i=1:numFilesToProcess
    rawImageFileName = rawFilesDirList(i).name; % name without path
    membraneProbFileName = memProbMapDirList(i).name; %name without path
    str1 = sprintf('Raw file name: %s',rawImageFileName);
    disp(str1)
    str1 = sprintf('Membrane Prob Map file name: %s',membraneProbFileName);
    disp(str1)
    membraneProbMapFullFileName = fullfile(membraneProbMapDir,membraneProbFileName);
    rawImg = double(imread(fullfile(rawImageDir,rawImageFileName)));
    rawImageID = i;
    membraneProbMap = double(imread(membraneProbMapFullFileName));
    labelImage = imread(labelImageFileName);
    segmentationOut = doILP_w_dir(rawImg,rawImageID,...
        membraneProbMap,mitoProbMapFullFileName,...
        barLength,barWidth,...
        saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
        outputPath,produceBMRMfiles,labelImage,sbmrmOutputDir,saveOutputFormat,...
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