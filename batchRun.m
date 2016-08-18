produceBMRMfiles = 0;
useMitochondriaDetection = 0;

rawImageDir = '/home/thanuja/projects/data/toyData/set8/raw';
rawImageType = '*.tif';
membraneProbMapDir = '/home/thanuja/projects/data/toyData/set8/membranes_rfc';
membraneProbMapType = '*.tif';
mitoProbMapFullFileName = '';

outputRoot = '/home/thanuja/projects/RESULTS/contours/20160818';
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
str1 = sprintf('Number of raw files: %d',numel(rawFilesDirList));
disp(str1)
str1 = sprintf('Number of membrane probability maps: %d',numel(memProbMapDirList));
disp(str1)

for i=1:numel(rawFilesDirList)
    rawImageFileName = rawFilesDirList(i).name; % name without path
    membraneProbFileName = memProbMapDirList(i).name; %name without path
    str1 = sprintf('Raw file name: %s',rawImageFileName);
    disp(str1)
    str1 = sprintf('Membrane Prob Map file name: %s',membraneProbFileName);
    disp(str1)
    membraneProbMapFullFileName = fullfile(membraneProbMapDir,membraneProbFileName);
    rawImage = double(imread(fullfile(rawImageDir,rawImageFileName)));
    membraneProbMap = double(imread(membraneProbMapFullFileName));
    mitochondriaProbMap = [];
    labelImage = [];
    segmentationOut = doILP_w_dir(rawImage,membraneProbMap,i,...
        useMitochondriaDetection,mitochondriaProbMap,...
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