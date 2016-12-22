function batch_generate2Dcandidates()

% multiple 2D segmentations (with increasingly more splits)
dbstop if error
%% Parameters, file paths etc
% updatePathISBI(); % add external sub directories to matlab path
noDisplay = 0;
produceBMRMfiles = 0; % set to 1 to generate gold standard solution, features and constraints for structured learning
toy = 0; % only work on 400x400 image size instead of the full image
toyR = 250;
toyC = 250;
linearWeights = [-6.64336, -6.34538, 0.917042, 0.732313, -4.85328, -13.4944];
membraneDim = 2; % 2D or 3D trained probability map
% 2D: 1250 x 1250 x 2 x 125
% 3D: 1250 x 1250 x 125 x 2
g = 1; % grow segmented neuron slices by 1 pixel

% for 2D candidate generation
% mLevels = [0,0.60,0.70,0.80,0.85]; % regionScore upper thresholds to be changed
mLevels = 0; % regionScore upper thresholds to be changed
threshRsize = 250; % all regions smaller than this size in pixels are considered
newRscore = 0.20; % new score assigned for oversegmentation of neurons

% INPUTS:
forestEdgeProbFileName = '/home/thanuja/DATA/forestEdgeProbV7.mat'; 
% forestEdgeProbFileName = 'forestEdgeProbV7.mat'; 
precomputedEdgeUnary = 0; % 1 if precomputed edgeUnary is to be used

% membranesDir = '/home/thanuja/RESULTS/isbi2012/CNN/train/probMaps_rfcilp_inv_20161102';
% rawDir = '/home/thanuja/DATA/ISBI2012/train-volume';

membranesDir = '/home/thanuja/DATA/ISBI2012/trainvolume_membranes_rfc';
rawDir = '/home/thanuja/DATA/ISBI2012/train-volume';

mitoProbMapFullFileName = '';

% OUTPUTS:
% outputRoot = '/home/thanuja/RESULTS/isbi2012/2Dcandidates/20161130_cnn';
outputRoot = '/home/thanuja/RESULTS/isbi2012/forthesis';
subDir = '010';
saveOutputFormat = 'png'; % allowed: 'png', 'tif'
saveIntermediateImages = 1;
showIntermediateImages = 1;

% PARAMS:
% Steerable edge filter bank - filter sizes
barLength = 13; % should be odd
barWidth = 4; % should be even?
threshFrac = 0.000; % edges with OFR below this will not be considered

dbstop if error

% parallel pool set up
% poolobj = parpool('local',16);
% ms.UseParallel='always';

%%  read probability maps
membraneFileList = dir(fullfile(membranesDir,strcat('*.tif')));


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
    numFilesToProcess = numel(membraneFileList);
end


% main loop to process the images
% for i=1:numFilesToProcess

i = 11;
     try
        % open new file for writing
        logFileName = sprintf('log%03d.txt',i);
        logFileFullPath = fullfile(outputPathLog,logFileName);
        logFileH = fopen(logFileFullPath,'w');
        rawImageID = i;
        str1 = sprintf('Processing image %d ...',i);
        disp(str1)
        fprintf(logFileH,str1);
        membraneFileName = fullfile(membranesDir,membraneFileList(i).name);
        membraneProbMap = double(imread(membraneFileName));
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
        % edgeUnary = []; % read from precomputed files
        
        if (numel(mLevels)>1)
            % create a separate output directory for each image to have its
            % candidates
            outputPathSeg = fullfile(outputPathPNG,sprintf('%03d',rawImageID));
            checkAndCreateSubDir(outputPathPNG,sprintf('%03d',rawImageID));
            
            
        else    
            outputPathSeg = outputPathPNG;
        end
        edgeUnary = [];
        segmentationOut = doILP_w_dir(rawImage,rawImageID,...
            membraneProbMap,mitoProbMapFullFileName,...
            forestEdgeProbFileName,edgeUnary,linearWeights,...
            barLength,barWidth,threshFrac,...
            saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
            outputPathSeg,produceBMRMfiles,labelImage,sbmrmOutputDir,saveOutputFormat,...
            logFileH,noDisplay,g,mLevels,threshRsize,newRscore);
        
    catch ME
        str1 = sprintf('Error occurred while processing image %d',i);
        disp(str1)
        fprintf(logFileH,str1);
    	  msgTxt = getReport(ME);
    	  disp(msgTxt)
        fprintf(logFileH,msgTxt);
    end

% end
% parallel pool stop
% delete(poolobj);
