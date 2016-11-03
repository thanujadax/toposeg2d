function segmentationOut = doILP_w_dir(rawImg,rawImageIDstr,...
    membraneProbMap,mitoProbMapFullFileName,forestEdgeProbFileName,...
    edgeUnary,linearWeights,...
    barLength,barWidth,threshFrac,...
    saveIntermediateImages,saveIntermediateImagesPath,showIntermediateImages,...
    outputPath,produceBMRMfiles,labelImage,sbmrmOutputDir,...
    saveOutputFormat,logFileH,noDisplay,precomputedEdgeUnary)

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

% old weights: OFR from raw image. older verision of edgeProbRFC
% linearWeights = [-10, -7.38296, 0.468054, 0.403942, -7.79221, -18]

% weights learned with regionThresholding 20160510
% and edgeRFC learned with RFC membrane probmap for OFR
% linearWeights =  [-10.2536, -8.18983, 3.3004, -0.0163147, -4.44784, -13.724]

% without region thresholding 20160510. gsig= 4.5
% RFC probmap for OFR
% linearWeights = [-9.66278, -7.77851, 3.16516, -0.0328264, -4.84211, -14.7709];

% without region thresholding 20160510. gsig= 55
% RFC probmap for OFR
% linearWeights = [-10.2536, -8.18983, 3.3004, -0.0163147, -4.44784, -13.724];

% experimental weights, increasing w_r_off reward
% linearWeights = [-10.2536, -8.18983, 3.3004, -0.0163147, -4.44784, -25];

% weights trained after region continuity constraint 20160528
%linearWeights = [-9.1695, -8.52036, 1.55449, 0.159125, -5.41935, -11.6639];
% increasing reward for membranes w_off_r! (w(5))
% linearWeights = [-9.1695, -8.52036, 1.55449, 0.159125, -5.41935, -20];

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

if(precomputedEdgeUnary)
    
    str1 = 'using precomputed edge probabilities';
    disp(str1)
    fprintf(logFileH,str1);
    
else
        % load forestEdgeProb.mat
    forestEdgeProb = importdata(forestEdgeProbFileName);
    str1 = 'loaded pre-trained RF for edge activation probability inference.';
    disp(str1)
    fprintf(logFileH,str1);


    edgeUnary = getEdgeProbabilitiesFromRFC...
                (forestEdgeProb,rawImg,OFR,edgepixels,edgePriors,...
                boundaryEdgeIDs,edgeListInds,numTrees,...
                psuedoEdgeIDs,psuedoEdges2nodes,edgeListInds,...
                 membraneProbMap,edgeListInds);

end

% assigning predetermined edgePriors for boundaryEdges before nodeAngleCost
% calculation
% edgePriors(boundaryEdgeListInds) = boundaryEdgeReward;

% visualize edge unaries
edgeUnaryMat = visualizeEdgeUnaries(edgepixels,edgeUnary,sizeR,sizeC);
if(saveIntermediateImages)
    intermediateImgDescription = 'edgeUnary';
    saveIntermediateImage(edgeUnaryMat,rawImageIDstr,intermediateImgDescription,...
    saveIntermediateImagesPath,saveOutputFormat);
% h = overlayLabelOnImage(imgInNormal,edgeUnaryMat);
% set(gca,'position',[0 0 1 1],'units','normalized');
% outputFileName = sprintf('%s_%s.png',rawImageID,intermediateImgDescription);
% outputFileName = fullfile(saveIntermediateImagesPath,outputFileName);
% saveas(gcf,outputFileName);
end

%% Edge pairs - Junction costs
[maxNodesPerJtype, numJtypes] = size(junctionTypeListInds);

jEdges = getEdgesForAllNodeTypes(nodeEdges,junctionTypeListInds);
% jEdges{i} - cell array. each cell corresponds to the set of edgeIDs for the
% junction of type i (type1 = J2). A row of a cell corresponds to a node of
% that type of junction.
jAnglesAll = getNodeAnglesForAllJtypes(junctionTypeListInds,...
    nodeInds,jEdges,edges2pixels,OFR,sizeR,sizeC,orientationStepSize,...
    psuedoEdges2nodes,psuedoEdgeIDs);
% jAnglesAll{i} - cell array. each row of a cell corresponds to the set of angles for each
% edge at each junction of type 1 (= J2)

% get the angles for the edges based on its position in the graph
jAnglesAll_alpha = getNodeAngles_fromGraph_allJtypes(junctionTypeListInds,...
    nodeInds,jEdges,edges2pixels,sizeR,sizeC,edges2nodes,connectedJunctionIDs,...
    psuedoEdges2nodes,psuedoEdgeIDs);

% angle costs
nodeAngleCosts = cell(1,numJtypes);
for i=1:numJtypes
    theta_i = jAnglesAll{i};
    alpha_i = jAnglesAll_alpha{i};
    if(theta_i<0)
        % no such angles for this type of junction
    else
%         edgePriors_i = getOrderedEdgePriorsForJ(i,junctionTypeListInds,...
%                     nodeEdges,edgeUnary,edgeListInds);
%         nodeAngleCosts{i} = getNodeAngleCost_directional(theta_i,alpha_i,...
%                                 edgePriors_i,w_on_n);
        nodeAngleCosts{i} = getNodeAngleCost_smooth(alpha_i,gsigma);
    end
end
%% Faces of wsgraph -> region types (between pairs of regions)
str1 = 'calculating adjacency graph of regions';
disp(str1)
fprintf(logFileH,str1);
[faceAdj,edges2regions,setOfRegions,twoRegionEdges,wsIDsForRegions] ...
    = getFaceAdjFromWS(ws,edges2pixels,b_imWithBorder,boundaryEdgeIDs);

[~,edgeOrientationsInds] = getEdgePriors(OFR,edges2pixels);
% clear OFR
edgeOrientations = (edgeOrientationsInds-1).*orientationStepSize;

% normalize input image
% normalizedInputImage = imgIn./(max(max(imgIn)));

%% get region unaries

regionUnary = getRegionScoreFromProbImage(...
membraneProbMap,mitochondriaProbabilityImage,...
useMitochondriaDetection,marginSize,marginPixValRaw,...
setOfRegions,sizeR,sizeC,wsIDsForRegions,ws,showIntermediateImages,...
saveIntermediateImages,...
saveIntermediateImagesPath,rawImageIDstr,saveOutputFormat);
    
numRegions = numel(regionUnary);
%% Boundary edges
% we have already obtained boundaryEdgeIDs above. The following is
% obsolete?
% assigning predetermined edge priors for boundary edges after
% nodeAngleCost calculation

edgePriors(boundaryEdgeListInds) = boundaryEdgeReward;

% boundaryNodeEdges = all edges that has at least one end connected to the boundary
boundaryNodeListInds = edges2nodes(boundaryEdgeListInds,:);
boundaryNodeListInds = unique(boundaryNodeListInds);
boundaryNodeEdges = nodeEdges(boundaryNodeListInds,:);
boundaryNodeEdges(:,1)=[];
boundaryNodeEdges = unique(boundaryNodeEdges);
boundaryNodeEdges = boundaryNodeEdges(boundaryNodeEdges>0);
boundaryNodeEdgeListIDs = numel(boundaryNodeEdges);
for i=1:numel(boundaryNodeEdges)
    boundaryNodeEdgeListIDs(i) = find(edgeListInds==boundaryNodeEdges(i));
end

%% Removing misoriented edges
% used in the objective function
% uses the compatibility of the orientation of the adjoining pixels of each
% edge


offEdgeListIDs = getUnOrientedEdgeIDs(edgepixels,...
                lenThresh,OFR_hue,sizeR,sizeC);
            
% remove boundaryNodeEdgeListIDs from the offEdgeListIDs
offEdgeListIDs = setdiff(offEdgeListIDs,boundaryNodeEdgeListIDs);
          
% setting edgePriors
edgePriors(offEdgeListIDs) = offEdgeReward;
% visualize off edges
imgOffEdges = visualizeOffEdges(offEdgeListIDs,edgepixels,nodeInds,sizeR,sizeC);


%% ILP
% cost function to minimize
% state vector x: {edges*2}{J3*4}{J4*7}

% numJunctions = numel(nodeInds);
% tot num of int variables = 2*numEdges + 4*numJ3 + 7*numJ4
% coeff (unary prior) for turning off each edge = +edgePriors (col vector)
% coeff (unary prior) for turning on each edge = -edgePriors (col vector)
% coeff for turning off J3s: min(j3NodeAngleCost): max(j3NodeAngleCost)
% coeff for turning on J3-config(1 to 3): j3NodeAngleCost
% coeff for turning off J4s: max(j3NodeAngleCost)
% coeff for turning on J4-config(1 to 6): j4NodeAngleCost


% constraints
% equality constraints and closedness constrains in Aeq matrix
% [Aeq,beq,numEq,numLt,numRegionVars] = getConstraints(numEdges,jEdges,edges2pixels,nodeAngleCosts,...
%             offEdgeListIDs,onEdgeListIDs,minNumActEdgesPercentage,...
%             twoRegionEdges,edges2regions,setOfRegions,edgeOrientations,jAnglesAll_alpha,...
%             nodeEdges,junctionTypeListInds,edges2nodes,sizeR,sizeC);

% commenting out the following two methods : 20150518
[c_edgeLIDsForRegions_dir_cw,setOfRegions_edgeLIDs,edgeLIDs2nodes_directional] ...
        = getOrderedRegionEdgeListIndsDir...
        (setOfRegions,edges2nodes,jAnglesAll_alpha,...
        junctionTypeListInds,nodeEdges,edgeListInds,edges2pixels,sizeR,sizeC);

dirEdges2regionsOnOff = getRegionsForDirectedEdges...
            (c_edgeLIDsForRegions_dir_cw,edgeLIDs2nodes_directional,...
            setOfRegions_edgeLIDs,numEdges);
% dEdges2regionsOnOff = edgeListInd_dir (=rowID) | onRegion | offRegion  : dir N1->N2
%   regionID = 0 is for the image border.

% TODO : unfinished implementation 20150518
% dirEdges2regionsOnOff ...
%         = getDirectedEdgeOnOffRegions...
%         (setOfRegions,edges2nodes,jAnglesAll_alpha,...
%         junctionTypeListInds,nodeEdgeIDs,edgeListIndsAll,...
%         edges2pixels,sizeR,sizeC);

if(produceBMRMfiles)
    [labelImg_indexed,numLabels] = getLabelIndexImg(labelImage);
    [c_cells2WSregions,c_internalEdgeIDs,c_extEdgeIDs,c_internalNodeInds,c_extNodeInds]...
                = getCells2WSregions(labelImg_indexed,ws,numLabels,setOfRegions,...
                edgeListInds,edges2nodes);
    activeWSregionListInds_tr = getElementsFromCell(c_cells2WSregions);  
else
    activeWSregionListInds_tr = [];
end

[model.A,b,senseArray,numEdges,numNodeConf,numRegions,nodeTypeStats]...
    = getILPConstraints(edgeListInds,edges2nodes,nodeEdges,junctionTypeListInds,...
        jEdges,dirEdges2regionsOnOff,setOfRegions,activeWSregionListInds_tr);
        

% last 7 variables are continuous RVs corresponding to the parameters to be
% learned.
%   1. w_off_e
%   2. w_on_e
%   3. w_off_n
%   4. w_on_n_neg
%   5. w_on_n_pos
%   6. w_off_r
%   7. w_on_r

% qsparse = getQuadraticObjective_PE(edgePriors,nodeAngleCosts,regionPriors,numParam);
        
% f = getILPcoefficientVector2(scaledEdgePriors,nodeAngleCosts,...
%     bbNodeListInds,junctionTypeListInds,bbJunctionReward,regionPriors);
% numAcols = size(Aeq,2);
% f = zeros(1,numAcols);
% bbJunctionCost = bbJunctionReward;

% f = getILPObjectiveVectorParametric(edgeUnary,nodeAngleCosts,...
%             regionUnary,w_off_e,w_on_e,w_off_n,w_on_n,w_off_r,w_on_r);

% f = getILPObjectiveVectorParametric2(edgeUnary_directed,nodeAngleCosts,...
%             regionUnary,w_on_e,w_off_n,w_on_n,w_on_r,...
%             nodeTypeStats);
        
if(produceBMRMfiles)
    f = getILPObjVect_Tr(labelImage,ws,edgeListInds,...
                setOfRegions,edges2nodes,numEdges,numNodeConf,numRegions,...
                edgeUnary);
else            
    f = getILPObjectiveVectorParametric2(edgeUnary,nodeAngleCosts,...
            regionUnary,w_on_e,w_off_e,w_off_n,w_on_n,w_on_r,w_off_r,...
            nodeTypeStats,offEdgeListIDs,regionOffThreshold,numNodeConf);
end

% senseArray(1:numEq) = '=';
% if(numLt>0)
%     senseArray((numEq+1):(numEq+numLt)) = '<';
% end
% if(numel(gt_rowID)>0)
%    senseArray(gt_rowID) = '>'; 
% end
% variable types
% vtypeArray(1:numBinaryVar) = 'B'; % binary
% vtypeArray((numBinaryVar+1):(numBinaryVar+numParam)) = 'C'; % continuous
% lower bounds
% lbArray(1:(numBinaryVar+numParam)) = 0;
% upper bounds
% ubArray(1:(numBinaryVar+numParam)) = 1;
%% log stats
fprintf(logFileH,'********************************** \n');
fprintf(logFileH,'Number of edges: %d \n',numel(edgeListInds));
fprintf(logFileH,'Number of regions: %d \n',numel(regionUnary));
fprintf(logFileH,'Number of nodes: %d \n',size(nodeEdges,1));
fprintf(logFileH,'Total number of ILP variables: %d \n',numel(f));
fprintf(logFileH,'Number of ILP constraints: %d \n',numel(b));


%% solver
if(useGurobi)
    disp('using Gurobi ILP solver...');
    % model.A = sparse(double(A));
    model.rhs = b;
    % TODO: check if f contains nan. replace with zero
    fnan = isnan(f);
    if(sum(fnan)>0)
        f(fnan==1) = 0;
        disp('Warning! : Nan found in objective function f.')
        disp('Replacing Nan with zero for f(i), where i = ')
        find(fnan==1)
    end
    model.obj = f';
    model.sense = senseArray;
    % model.vtype = vtypeArray;
    model.vtype = 'B';
    % model.lb = lbArray;
    % model.ub = ubArray;
    model.modelname = 'contourDetectionILP1';
    % initial guess
    % model.start = labelVector;
        
    params.LogFile = 'gurobi.log';
    params.Presolve = 0;
    params.ResultFile = 'modelfile.mps';
    params.InfUnbdInfo = 1;

    resultGurobi = gurobi(model,params);
    x = resultGurobi.x;
        
else
    % Matlab ILP solver
    disp('using MATLAB ILP solver...');
    Initial values for the state variables
    x0 = getInitValues(numEdges,numJ3,numJ4);  % TODO: infeasible. fix it!!
    numStates = size(f,1);
    maxIterationsILP = numStates * 1000000;
    options = optimset('MaxIter',maxIterationsILP,...
                    'MaxTime',5000000);
    options = struct('MaxTime', 5000000);
    disp('running ILP...');
    t1 = cputime;
    [x,fval,exitflag,optOutput] = bintprog(f,[],[],Aeq,beq,[],options);
    t2 = cputime;
    timetaken = t2-t1
end
%% write BMRM files
if (produceBMRMfiles)
    f = getILPObjectiveVectorParametric2(edgeUnary,nodeAngleCosts,...
            regionUnary,w_on_e,w_off_e,w_off_n,w_on_n,w_on_r,w_off_r,...
            nodeTypeStats,offEdgeListIDs,regionOffThreshold,numNodeConf); % w's are set to 1.
    featureMat = writeFeaturesFile2(f,jEdges,numEdges,numRegions,sbmrmOutputDir);
    constraints = writeConstraintsFile(model.A,b,senseArray,sbmrmOutputDir);
    labels = writeLabelsFile(x,sbmrmOutputDir);
end

%% visualize
segmentationOut = visualizeX2(x,sizeR,sizeC,numEdges,numRegions,edgepixels,...
            junctionTypeListInds,nodeInds,connectedJunctionIDs,edges2nodes,...
            nodeEdges,edgeListInds,faceAdj,setOfRegions,wsIDsForRegions,ws,...
            marginSize,showIntermediateImages,fillSpaces);
if(saveIntermediateImages)
    intermediateImgDescription = 'segmentationOutput';
    saveIntermediateImage(segmentationOut,rawImageIDstr,intermediateImgDescription,...
    saveIntermediateImagesPath,saveOutputFormat);
end
fprintf(logFileH,'ILP is done! \n');
