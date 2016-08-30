% script to process CREMI 2016 data
% reads hdf5 raw data and probability maps
% saves output to png/tif
% output has to be processed with relevant python script

%% Parameters, file paths etc
produceBMRMfiles = 0; % set to 1 to generate gold standard solution, features and constraints for structured learning
toy = 0; % only work on 400x400 image size instead of the full image
toyR = 400;
toyC = 400;
linearWeights = [-6.64336, -6.34538, 0.917042, 0.732313, -4.85328, -13.4944];
% INPUTS:
% probability map should contain the pixelwise probability of being
% membrane i.e. membranes are visualized in white
h5FileName_membranes = '/home/thanuja/projects/classifiers/greentea/caffe_neural_models/pygt_uvisual_cremi/sampla_A_20160501.h5';
h5FileName_raw = '/home/thanuja/DATA/cremi/train/hdf/sample_A_20160501.hdf';
% to be used only when generating sbmrm files
h5FileName_labels = '/home/thanuja/DATA/cremi/train/hdf/sample_A_20160501_membranes.hdf';

mitoProbMapFullFileName = '';

% OUTPUTS:
outputRoot = '/home/thanuja/projects/RESULTS/cremi/20160830';
subDir = '002';
saveOutputFormat = 'png'; % allowed: 'png', 'tif'
saveIntermediateImages = 0;
showIntermediateImages = 0;

% PARAMS:
% Steerable edge filter bank - filter sizes
barLength = 13; % should be odd
barWidth = 4; % should be even?
threshFrac = 0.005; % edges with OFR below this will not be considered

startImageID = 1;
endImageID = 1;

rStep = 330;
cStep = 330;
rOverlap = 30;
cOverlap = 30;
numBlocksR = 4;
numBlocksC = 4;

dbstop if error

%%  read probability maps
dataSet = '/main';
membraneData = h5read(h5FileName_membranes,dataSet);
membraneData = shiftdim(membraneData,3);
membraneProbMaps = membraneData(:,:,:,1);
membraneProbMaps = shiftdim(membraneProbMaps,1);
% membraneProbMaps has dimensions X,Y,Z
clear membraneData

%%  read raw images
dataSet = '/volumes/raw';
rawImages = h5read(h5FileName_raw,dataSet);
rawImages = shiftdim(rawImages,3);
% rawImage has dimensions X,Y,Z
%% read labels if inputs for structured learning are to be generated
if(produceBMRMfiles)
    dataSet = '/volumes/labels/neuron_ids';
    labelImages = h5read(h5FileName_labels,dataSet);
    labelImages = shiftdim(labelImages,3);
end

%% Create output subdirectories
checkAndCreateSubDir(outputRoot,subDir);
outputPath = fullfile(outputRoot,subDir);
checkAndCreateSubDir(outputPath,'png');
outputPathPNG = fullfile(outputPath,'png');
sbmrmOutputDir = fullfile(outputPath,'sbmrmRun');
checkAndCreateSubDir(outputPath,'sbmrmRun');
saveIntermediateImagesPath = fullfile(outputPath,'intermediate');
checkAndCreateSubDir(outputPath,'intermediate');
logFileName = 'log.txt';
logFileFullPath = fullfile(outputPath,logFileName);

if(produceBMRMfiles)
    numFilesToProcess = 1;
else
    numFilesToProcess = size(membraneProbMaps,3);
end

% main loop to process the images
%for i=1:numFilesToProcess
for i=1:1
    rawImageID = i;
    rawImageIDstr = num2str(rawImageID);
    str1 = sprintf('Processing image %d ...',i);
    disp(str1)
    membraneProbMap = membraneProbMaps(:,:,i);
    if (produceBMRMfiles)
        labelImage = labelImages(:,:,i);
    else
        labelImage = [];
    end
    rawImage = rawImages(:,:,i);
    [sizeR,sizeC] = size(rawImage);
    % break image into 9 chunks of size ~440x440
    blockDirName = num2str(rawImageID);
    checkAndCreateSubDir(saveIntermediateImagesPath,blockDirName);
    outputBlockDirFull = fullfile(saveIntermediateImagesPath,blockDirName);
    
    for r=1:numBlocksR
        rStart = (r-1)*rStep + 1 - rOverlap;
        rStart = max(1,rStart);
        rStop = rStart + rStep - 1;
        rStop = min(sizeR,rStop);
        for c = 1:numBlocksC
            cStart = (c-1)*cStep + 1 - cOverlap;
            cStart = max(1,cStart);
            cStop = cStart + cStep - 1;
            cStop = min(sizeC,cStop);
            
            blockFileName = sprintf('r%dc%d',r,c);
            
            membraneProbMap_block = membraneProbMap(rStart:rStop,cStart:cStop);
            rawImage_block = rawImage(rStart:rStop,cStart:cStop);
            if(~isempty(labelImage))
                labelImage = labelImage(rStart:rStop,cStart:cStop);
            end
                
            segmentationOut = doILP_w_dir(...
                rawImage_block,strcat(rawImageIDstr,blockFileName),...
                membraneProbMap_block,mitoProbMapFullFileName,...
                linearWeights,...
                barLength,barWidth,threshFrac,...
                saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
                outputPath,produceBMRMfiles,labelImage,sbmrmOutputDir,saveOutputFormat,...
                logFileFullPath);
            
            
            writeFileName = fullfile(outputBlockDirFull,...
                strcat(blockFileName,'.',saveOutputFormat));
            imwrite(segmentationOut,writeFileName,saveOutputFormat);
        end
    end
    % combine the 9 blocks into one image
    combineBlocks2Image(outputBlockDirFull,outputPathPNG,rawImageIDstr,...
        rStep,cStep,rOverlap,cOverlap,sizeR,sizeC,saveOutputFormat);
end