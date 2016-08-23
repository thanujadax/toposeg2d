% script to process CREMI 2016 data
% reads hdf5 raw data and probability maps
% saves output to png/tif
% output has to be processed with relevant python script

%% Parameters, file paths etc
produceBMRMfiles = 0; % set to 1 to generate gold standard solution, features and constraints for structured learning
toy = 1;

% INPUTS:
% probability map should contain the pixelwise probability of being
% membrane i.e. membranes are visualized in white
h5FileName_membranes = '/home/thanuja/projects/classifiers/greentea/caffe_neural_models/pygt_uvisual_cremi/sampla_A_20160501.h5';
h5FileName_raw = '/home/thanuja/DATA/cremi/train/hdf/sample_A_20160501.hdf';
% to be used only when generating sbmrm files
h5FileName_labels = '/home/thanuja/DATA/cremi/train/hdf/sample_A_20160501_membranes.hdf';

mitoProbMapFullFileName = '';

% OUTPUTS:
outputRoot = '/home/thanuja/projects/RESULTS/contours/cremi/20160823';
subDir = '000';
saveOutputFormat = 'png'; % allowed: 'png', 'tif'
saveIntermediateImages = 1;
showIntermediateImages = 1;

% PARAMS:
% Steerable edge filter bank - filter sizes
barLength = 13; % should be odd
barWidth = 4; % should be even?
threshFrac = 0.05; % edges with OFR below this will not be considered

startImageID = 1;
endImageID = 1;

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
for i=1:numFilesToProcess
    rawImageID = i;
    str1 = sprintf('Processing image %d ...',i);
    disp(str1)
    membraneProbMap = membraneProbMaps(:,:,i);
    if (produceBMRMfiles)
        labelImage = labelImages(:,:,i);
    else
        labelImage = [];
    end
    rawImage = rawImages(:,:,i);
    segmentationOut = doILP_w_dir(rawImage,rawImageID,...
        membraneProbMap,mitoProbMapFullFileName,...
        barLength,barWidth,threshFrac,...
        saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
        outputPath,produceBMRMfiles,labelImage,sbmrmOutputDir,saveOutputFormat,...
        logFileFullPath);

    writeFileName = fullfile(outputPathPNG,strcat(rawImageID,'.',saveOutputFormat));
    imwrite(segmentationOut,writeFileName,saveOutputFormat);

end