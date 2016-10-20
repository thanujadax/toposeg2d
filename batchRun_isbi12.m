function batchRun_isbi12()
% script to process CREMI 2016 data
% reads hdf5 raw data and probability maps
% saves output to png/tif
% output has to be processed with relevant python script
% paths changed to suit ARTON grid 20160909

%% Parameters, file paths etc
% updatePathCremi(); % add external sub directories to matlab path
noDisplay = 0;
produceBMRMfiles = 0; % set to 1 to generate gold standard solution, features and constraints for structured learning
toy = 0; % only work on 400x400 image size instead of the full image
toyR = 100;
toyC = 100;
linearWeights = [-6.64336, -6.34538, 0.917042, 0.732313, -4.85328, -13.4944];
membraneDim = 2; % 2D or 3D trained probability map
% 2D: 1250 x 1250 x 2 x 125
% 3D: 1250 x 1250 x 125 x 2

% INPUTS:
forestEdgeProbFileName = '/home/thanujaa/DATA/forestEdgeProbV7.mat'; 
% forestEdgeProbFileName = '/home/thanujaa/DATA/forestEdgeProbV7.mat'; 
% forestEdgeProbFileName = 'forestEdgeProbV7.mat'; 

% membranesDir = '/home/thanuja/DATA/ISBI2012/testvolume_membranes_rfc';
rawDir = '/home/thanuja/DATA/ISBI2012/test-volume';
h5FileName_membranes = '/home/thanuja/projects/classifiers/greentea/caffe_neural_models/isbi12_s2/isbi_20161018-test.h5';
%rawDir = '/home/thanujaa/DATA/isbi/train/raw';
%h5FileName_membranes = '/home/thanujaa/DATA/isbi/train/isbi_20161018.h5';


mitoProbMapFullFileName = '';

% OUTPUTS:
outputRoot = '/home/thanujaa/RESULTS/isbi2012';
subDir = 'train';
saveOutputFormat = 'png'; % allowed: 'png', 'tif'
saveIntermediateImages = 0;
showIntermediateImages = 0;

% PARAMS:
% Steerable edge filter bank - filter sizes
barLength = 13; % should be odd
barWidth = 4; % should be even?
threshFrac = 0.002; % edges with OFR below this will not be considered

% dbstop if error

% parallel pool set up
% poolobj = parpool('local',16);
% ms.UseParallel='always';

%%  read probability maps (tif)
% membraneFileList = dir(fullfile(membranesDir,strcat('*.tif')));

%%  read probability maps (hdf5)
dataSet = '/main';
membraneData = h5read(h5FileName_membranes,dataSet);
if(membraneDim==2)
    % 2D: 512 x 512 x 2 x 30
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
rawFileList = dir(fullfile(rawDir,strcat('*.tif')));

%% read labels if inputs for structured learning are to be generated
% if(produceBMRMfiles)
%     dataSet = '/volumes/labels/neuron_ids';
%     labelImages = h5read(h5FileName_labels,dataSet);
%     labelImages = shiftdim(labelImages,3);
% end

%% Create output subdirectories
checkAndCreateSubDir(outputRoot,subDir);
outputPath = fullfile(outputRoot,subDir);
checkAndCreateSubDir(outputPath,'png');
outputPathPNG = fullfile(outputPath,'png');
checkAndCreateSubDir(outputPath,'intermediate');
saveIntermediateImagesPath = fullfile(outputPath,'intermediate');
checkAndCreateSubDir(outputPath,'log');
outputPathLog = fullfile(outputPath,'log');


sbmrmOutputDir = fullfile(outputPath,'sbmrmRun');
checkAndCreateSubDir(outputPath,'sbmrmRun');  



if(produceBMRMfiles)
    numFilesToProcess = 1;
else
    numFilesToProcess = numel(rawFileList);
end

% main loop to process the images
for i=1:numFilesToProcess
    try
        % open new file for writing
        logFileName = sprintf('log%03d.txt',i);
        logFileFullPath = fullfile(outputPathLog,logFileName);
        logFileH = fopen(logFileFullPath,'w');
        rawImageID = i;
        str1 = sprintf('Processing image %d ...',i);
        disp(str1)
        fprintf(logFileH,str1);
        % membraneFileName = fullfile(membranesDir,membraneFileList(i).name);
        % membraneProbMap = double(imread(membraneFileName));
        membraneProbMap = membraneProbMaps(:,:,i)';
        rawFileName = fullfile(rawDir,rawFileList(i).name);
        rawImage = double(imread(rawFileName));
    %     if(produceBMRMfiles)
    %         labelImage = labelImages(:,:,i);
    %     else
    %         labelImage = [];
    %     end
        labelImage = [];

        if(toy)
            membraneProbMap = membraneProbMap(1:toyR,1:toyC);
            rawImage = rawImage(1:toyR,1:toyC);
    %         if(~isempty(labelImage))
    %             labelImage = labelImage(1:toyR,1:toyC);
    %         end
        end
        segmentationOut = doILP_w_dir(rawImage,rawImageID,...
            membraneProbMap,mitoProbMapFullFileName,...
            forestEdgeProbFileName,linearWeights,...
            barLength,barWidth,threshFrac,...
            saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
            outputPath,produceBMRMfiles,labelImage,sbmrmOutputDir,saveOutputFormat,...
            logFileH,noDisplay);

        writeFileName = fullfile(outputPathPNG,...
            strcat(num2str(rawImageID),'.',saveOutputFormat));
        imwrite(segmentationOut,writeFileName,saveOutputFormat);
        
    catch ME
        str1 = sprintf('Error occurred while processing image %d',i);
        disp(str1)
        fprintf(logFileH,str1);
	msgTxt = getReport(ME);
	disp(msgTxt)
    fprintf(logFileH,msgTxt);
    end
end
% parallel pool stop
% delete(poolobj);
exit;
