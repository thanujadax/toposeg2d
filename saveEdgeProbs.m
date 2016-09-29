function saveEdgeProbs(rawImg,rawImageID,...
    membraneProbMap,mitoProbMapFullFileName,...
    forestEdgeProbFileName,linearWeights,...
    barLength,barWidth,threshFrac,...
    saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
    outputPathEdgeProbs,produceBMRMfiles,labelImage,sbmrmOutputDir,...
    saveOutputFormat,logFileH,noDisplay)

% version 6. 20160821: removed input file handling
% version 5. 20160509: 
% version 4. 2014.01.06
% each edge in the ws graph is represented by 2 (oppositely) directed edges 
% 20160321 - updated with new node angle cost function

%% Settings

% produceBMRMfiles = 1;  % set label file below if 1
% labelImageFileName = '00.tiff'; % for sbmrm. TODO: parameterize
% showIntermediateImages = 1;
set(0,'RecursionLimit',5000);
fillSpaces = 1;          % fills holes in segmentationOut
useGurobi = 1;
useMembraneProbMapForOFR = 1;  %%%%%%%%% TODO %%%%%%%%%%%
usePrecomputedProbabilityMaps = 1;
useMitochondriaDetection = 0;

%% File names and paths
% corresponding images inside different subdirectories should have the same
% name i.e 00.tif, 01.tif etc

% trained RFC for edge probability
% forestEdgeProbFileName = 'forestEdgeProbV7.mat'; 
% rawImageFullFile = fullfile(rawImageDir,rawImageFileName);
% rawImageIDstr = num2str(rawImageID);
rawImageIDstr = sprintf('%03d',rawImageID);
fprintf(logFileH,'Processsing image file: %s \n',rawImageIDstr);

%% Parameters
orientationStepSize = 10;
orientations = 0:orientationStepSize:350;

smoothenOFR = 1; % if OFR should be smoothened before generating WS transform
wsgsigma = 1.4;
wsgmask = 9;

gsigma = 55; % spread for the smoothness cost of nodes (gaussian sigma)

marginSize = ceil(barLength/2);
marginPixValRaw = 0;
marginPixValMem = 1;
% threshFrac = 0;   % threshold for OFR 0.1 for raw images, 0 for membraneProbMaps
medianFilterH = 0;
invertImg = 1;      % 1 for EM images when input image is taken from imagePath
b_imWithBorder = 1; % add thick dark border around the image

numTrees = 500;

lenThresh = 25;     % max length of edges to be checked for misorientations
lenThreshBB = 4;    % min length of edges to be considered for being in the backbone (BB)
priorThreshFracBB = 0.55; % threshold of edgePrior for an edge to be considered BB
minNumActEdgesPercentage = 0;  % percentage of the tot num edges to retain (min)

% param

bbEdgeReward = 1;
offEdgeReward = 1;

bbJunctionReward = 1;       % inactivation cost for bbjunction
boundaryEdgeReward = 1;     % prior value for boundary edges so that
                            % they won't have too much weight
%% Set parameters
regionOffThreshold = 0.21;  % ** NOT USED **threshold to pick likely off regions to set off score 
% to +1*w_off_r in the objective
                            
%%  learned parameters
%   1. w_off_e
%   2. w_on_e
%   3. w_off_n
%   4. w_on_n
%   5. w_on_r
%   6. w_off_r

% 20160822: after removing input file handling and bug fixing in membrane
% normalization. DATASET: drosophila larva ssTEM 
% linearWeights = [-6.64336, -6.34538, 0.917042, 0.732313, -4.85328, -10.4944];
% linearWeights = [-6.64336, -6.34538, 0.917042, 0.732313, -4.85328, -21.4944];

if(produceBMRMfiles)
    % set all parameters to  be learned to 1
    w_on_e = 1;     % edge weight
    w_off_e = 1;
    w_off_n = 1;    % node off weight
    w_on_n = 1;     % node on weight
    w_on_r = 1;     % region weight
    w_off_r = 1;
    fprintf(logFileH,'Setting all linear weights to 1 to produce files for sbmrm ... \n')
else
    % use pre-learned parameters
    % optimial w is [-7.52064, -7.38296, 0.468054, 0.403942, -7.79221, -5.75401]
%    w_on_e = -7.52064;     % edge weight
    w_on_e = linearWeights(1);
    w_off_e = linearWeights(2);

    w_off_n = linearWeights(3);    % node off weight
    w_on_n = linearWeights(4);     % node on weight
    w_on_r = linearWeights(5);     % region weight
    w_off_r = linearWeights(6);
end

fprintf(logFileH,'Linear weights: \n');
fprintf(logFileH,'w_on_e:%0.4f, w_off_e:%0.4f, w_off_n:%0.4f, w_on_n:%0.4f, w_on_r:%0.4f, w_off_r:%0.4f, \n',...
    w_on_e,w_off_e,w_off_n,w_on_n,w_on_r,w_off_r);

% tot num of int variables = 2*numEdges + 4*numJ3 + 7*numJ4
% coeff (unary prior) for turning off each edge = +edgePriors (col vector)
% coeff (unary prior) for turning on each edge = -edgePriors (col vector)
% coeff for turning off J3s: min(j3NodeAngleCost): max(j3NodeAngleCost)
% coeff for turning on J3-config(1 to 3): j3NodeAngleCost
% coeff for turning off J4s: max(j3NodeAngleCost)
% coeff for turning on J4-config(1 to 6): j4NodeAngleCost

%% read inputimage and get orientedScoreSpace and max_abs value of OFR
disp('using image file:')
% rawImg = double(imread(rawImageFullFile));
[a,b,c] = size(rawImg);
if(c==3)
    rawImg = rgb2gray(rawImg);
end
fprintf(logFileH,'input image size: [%d, %d] pixels\n',size(rawImg,1),size(rawImg,2));

% membraneProbMap = double(imread(membraneProbMapFullFileName));
% fprintf(logFileH,'using membrane probability map file: %s \n',membraneProbMapFullFileName);

if(max(max(membraneProbMap))>1)
    membraneProbMap = membraneProbMap./255;
end

if(useMitochondriaDetection)
    mitochondriaProbabilityImage = double(imread(mitoProbMapFullFileName));
else
    mitochondriaProbabilityImage = [];
end

% if(produceBMRMfiles)
%     labelImage = imread(labelImageFileName);
%     fprintf(logFileH,'using lablel image file: %s \n',labelImageFileName);
%     % labelImage = labelImage(1:128,:,:);
% end
% add thick border
if(b_imWithBorder)
    rawImg = addThickBorder(rawImg,marginSize,marginPixValRaw);
    membraneProbMap = addThickBorder(membraneProbMap,marginSize,marginPixValMem);
    if(saveIntermediateImages)
        intermediateImgDescription = 'rawImage';
        imgInNormal = rawImg./max(max(rawImg));
        saveIntermediateImage(imgInNormal,rawImageIDstr,intermediateImgDescription,...
    saveIntermediateImagesPath,saveOutputFormat);
    end
    if(produceBMRMfiles)
        labelImage = addThickBorder(labelImage,marginSize,marginPixValRaw);
    end
end


%% Oriented Edge Filtering
if(useMembraneProbMapForOFR)
    [output,rgbimg,OFR] = getOFR(membraneProbMap,orientations,...
                        barLength,barWidth,invertImg,threshFrac);
else
    [output,rgbimg,OFR] = getOFR(rawImg,orientations,...
                        barLength,barWidth,invertImg,threshFrac);
end
% output is in HSV form
OFR_mag = output(:,:,3);
OFR_hue = output(:,:,1);
% generate hsv outputs using the orientation information
% output(:,:,1) contains the hue (orinetation) information

if(saveIntermediateImages)
    intermediateImgDescription = 'orientationFiltering';
%     rgbimg = rgbimg./(max(max(max(rgbimg))));
    saveIntermediateImage(rgbimg,rawImageIDstr,intermediateImgDescription,...
    saveIntermediateImagesPath,saveOutputFormat);
end

%% watershed segmentation
if(smoothenOFR)
    fprintf(logFileH,'Smoothening OFR before WS transform sigma %0.4f, mask %d \n',...
        wsgsigma,wsgmask);
    OFR_mag = gaussianFilter(OFR_mag,wsgsigma,wsgmask);
end
ws = watershed(OFR_mag);
[sizeR,sizeC] = size(ws);
% randomize WS region IDs
ws = assignRandomIndicesToWatershedTransform(ws);

%% generate graph from the watershed edges
str1 = 'Creating graph from watershed boundaries';
disp(str1);
fprintf(logFileH,str1);
[adjacencyMat,nodeEdges,edges2nodes,edges2pixels,connectedJunctionIDs,selfEdgePixelSet,...
    ws,ws_original,removedWsIDs,newRemovedEdgeLIDs,psuedoEdgeIDs,psuedoEdges2nodes,...
    selfEdgeIDs,nodelessEdgeIDs] ...
    = getGraphFromWS(ws,output,showIntermediateImages,saveIntermediateImages,...
      saveIntermediateImagesPath,rawImageIDstr,saveOutputFormat);

% edges2nodes is already appended with psuedoEdges2nodes
% edges2pixels is already appended with psuedoEdgeIDs, with zeros as
% pixInds.

% clear adjacencyMat
% clear output
% nodeEdges - contain edgeIDs for each node

nodeInds = nodeEdges(:,1);                  % indices of the junction nodes
edgeListInds = edges2pixels(:,1);
junctionTypeListInds = getJunctionTypeListInds(nodeEdges);
% col1 has the listInds of type J2, col2: J3 etc. listInds are wrt
% nodeInds list of pixel indices of the detected junctions
if(size(connectedJunctionIDs,2)==2)
    clusterNodeIDs = connectedJunctionIDs(:,1); % indices of the clustered junction nodes
else
    clusterNodeIDs = 0;
end
str1 = 'graph created!';
disp(str1)
fprintf(logFileH,str1);
wsRegionBoundariesFromGraph = zeros(sizeR,sizeC);
wsRegionBoundariesFromGraph(nodeInds) = 0.7;          % junction nodes
if(size(connectedJunctionIDs,2)==2)
    wsRegionBoundariesFromGraph(clusterNodeIDs) = 0.5;    % cluster nodes
end
[nre,nce] = size(edges2pixels);  % first column is the edgeID
edgepixels = edges2pixels(:,2:nce);
wsRegionBoundariesFromGraph(edgepixels(edgepixels>0)) = 1; % edge pixels

if(saveIntermediateImages)
    intermediateImgDescription = 'wsRegions2';
    saveIntermediateImage(wsRegionBoundariesFromGraph,rawImageIDstr,intermediateImgDescription,...
    saveIntermediateImagesPath,saveOutputFormat);
end

numEdges = size(edges2nodes,1);

% boundary edges
% boundaryEdgeIDs = getBoundaryEdges2(wsRegionBoundariesFromGraph,barLength,edgepixels,...
%     nodeEdges,edgeListInds,showIntermediate);

boundaryEdgeIDs = getBoundaryEdgeIDs(ws,edges2pixels);
numBoundaryEdges = numel(boundaryEdgeIDs);

[~,boundaryEdgeListInds] = intersect(edgeListInds,boundaryEdgeIDs); 

disp('preparing coefficients for ILP solver...')
%% Edge unary values
% edge priors - from orientation filters
edgePriors = getEdgeUnaryAbs(edgepixels,OFR_mag,...
    psuedoEdgeIDs,psuedoEdges2nodes,edgeListInds);

% get edge activation probabilities from RFC

if(0) % not using precomputed probability maps for graph edges - doesn't make sense!
    % calculate edgeUnary from probability map image
    edgeUnary = getEdgeProbabilityFromMap(...
        membraneProbMap,edgepixels,marginSize,(1-marginPixVal));
else
    
    if ~exist(forestEdgeProbFileName,'file')
        str1 = 'RF for edge classification. Training new classifier...';
        disp(str1)
        fprintf(logFileH,str1);
        forestEdgeProb = trainRF_edgeProb();
    else
        % load forestEdgeProb.mat
        forestEdgeProb = load(forestEdgeProbFileName);
        str1 = 'loaded pre-trained RF for edge activation probability inference.';
        disp(str1)
        fprintf(logFileH,str1);
    end

    edgeUnary = getEdgeProbabilitiesFromRFC...
                (forestEdgeProb,rawImg,OFR,edgepixels,edgePriors,...
                boundaryEdgeIDs,edgeListInds,numTrees,...
                psuedoEdgeIDs,psuedoEdges2nodes,edgeListInds,...
                 membraneProbMap,edgeListInds);
    edgeProbFileName = sprintf('%s.dat',rawImageIDstr);
    edgeProbFileName = fullfile(outputPathEdgeProbs,edgeProbFileName);
    save(edgeProbFileName,'edgeUnary');
    
end

