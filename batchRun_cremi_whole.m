% script to process CREMI 2016 data
% reads hdf5 raw data and probability maps
% saves output to png/tif
% output has to be processed with relevant python script

%% Parameters, file paths etc
produceBMRMfiles = 0; % set to 1 to generate gold standard solution, features and constraints for structured learning
toy = 1; % only work on 400x400 image size instead of the full image
toyR = 400;
toyC = 400;
linearWeights = [-6.64336, -6.34538, 0.917042, 0.732313, -4.85328, -13.4944];
membraneDim = 3; % 2D or 3D trained probability map
% 2D: 1250 x 1250 x 2 x 125
% 3D: 1250 x 1250 x 125 x 2
% INPUTS:
% probability map should contain the pixelwise probability of being
% membrane i.e. membranes are visualized in white
% h5FileName_membranes = '/home/thanuja/projects/classifiers/greentea/caffe_neural_models/cremi2D_xy_A/sampla_A_20160501.h5';
h5FileName_membranes = '/home/thanuja/projects/classifiers/greentea/caffe_neural_models/cremi3D_A/sample_A_20160501_3D.h5';
h5FileName_raw = '/home/thanuja/DATA/cremi/train/hdf/sample_A_20160501.hdf';
% to be used only when generating sbmrm files
h5FileName_labels = '/home/thanuja/DATA/cremi/train/hdf/sample_A_20160501_membranes.hdf';

mitoProbMapFullFileName = '';

% OUTPUTS:
outputRoot = '/home/thanuja/projects/RESULTS/contours/cremi/20160823';
subDir = '001';
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

dbstop if error

%%  read probability maps
dataSet = '/main';
membraneData = h5read(h5FileName_membranes,dataSet);
if(membraneDim==2)
    % 2D: 1250 x 1250 x 2 x 125
    membraneData = shiftdim(membraneData,3);
    membraneProbMaps = membraneData(:,:,:,1);
    membraneProbMaps = shiftdim(membraneProbMaps,1);
else
    % 3D: 1250 x 1250 x 125 x 2
    membraneProbMaps = membraneData(:,:,:,1);    
end
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
for i=6:numFilesToProcess
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
    if(toy)
        membraneProbMap = membraneProbMap(1:toyR,1:toyC);
        rawImage = rawImage(1:toyR,1:toyC);
        if(~isempty(labelImage))
            labelImage = labelImage(1:toyR,1:toyC);
        end
    end
    segmentationOut = doILP_w_dir(rawImage,rawImageID,...
        membraneProbMap,mitoProbMapFullFileName,...
        linearWeights,...
        barLength,barWidth,threshFrac,...
        saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
        outputPath,produceBMRMfiles,labelImage,sbmrmOutputDir,saveOutputFormat,...
        logFileFullPath);

    writeFileName = fullfile(outputPathPNG,...
        strcat(num2str(rawImageID),'.',saveOutputFormat));
    imwrite(segmentationOut,writeFileName,saveOutputFormat);

end