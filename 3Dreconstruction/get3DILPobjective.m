function f =  get3DILPobjective(weights,ends,continuations,branches,...
    endSizeCostOffset,writeToFile,outputPath)

% stateVector f: [ends continuations branches] - not in this order. The
% order is determined by the indivicual variableIDs assigned at the time of
% extracting the link variables

%  ends.variableID
%  ends.startSliceID
%  ends.numPixels

%  continuations.variableID
%  continuations.startSliceID
%  continuations.stopSliceID
%  continuations.minOverlap

%  branches.variableID
%  branches.startSliceID
%  branches.stopSlice1ID
%  branches.stopSlice2ID
%  branches.minOverlap

% weights = [10; -10; -5];
% variables are not in the order of ends,continuations,branches
% each of ends, continuations and branches have a field .variableID
% arrange them in that order in the objective

% output file format: features.txt for sbmrm
% # contains the feature vectors for the variables, one per row
% #
% # x x x x x 0 0 0 0 0 0 0 0
% # x x x x x 0 0 0 0 0 0 0 0
% # x x x x x 0 0 0 0 0 0 0 0
% # 0 0 0 0 0 x x x x x 0 0 0 |
% # 0 0 0 0 0 x x x x x 0 0 0 | one category of variables
% # 0 0 0 0 0 x x x x x 0 0 0 |
% # 0 0 0 0 0 x x x x x 0 0 0 |
% # 0 0 0 0 0 0 0 0 0 0 x x x
% # 0 0 0 0 0 0 0 0 0 0 x x x
% # 0 0 0 0 0 0 0 0 0 0 x x x
% #
% # different training sets can just be concatenated

numEnds = length(ends);
numContinuations = length(continuations);
numBranches = length(branches);
numStates = numEnds + numContinuations + numBranches;

f = zeros(numStates,1);

eSizeW = weights(1);
cMinOverlapW = weights(2);
cMaxOverlapW = weights(3);
cSizeDiffW = weights(4);
bMinOverlapW = weights(5);
bMaxOverlapW = weights(6);
bSizeDiffW = weights(7);

if(writeToFile)
    featureMat = zeros(numStates,numel(weights));
    filename = 'features.txt';
    filename = fullfile(outputPath,filename);
    fileID = fopen(filename,'w');    
end

% ends
for i = 1:numEnds
    j = ends(i).variableID;
    % featureID = 1;
    f(j) = eSizeW * (ends(i).numPixels + endSizeCostOffset);
    if(writeToFile)
        featureMat(j,1) = f(j);
    end
end

% continuations
for i = 1:numContinuations
    j = continuations(i).variableID;
    % f(j) = weights(2) * continuations(i).minOverlap;
    % 3 features: fIDs: 2,3,4
    ccosts = costOfContinuation(continuations,i,cMinOverlapW,cMaxOverlapW,cSizeDiffW);
    f(j) = sum(ccosts);
    if(writeToFile)
        featureMat(j,2:4) = ccosts;
    end
end

% branches
for i = 1:numBranches
    j = branches(i).variableID;
    % f(j) = weights(3) * branches(i).minOverlap;
    % 3 features: fIDs: 5,6,7
    bcosts = costOfContinuation(continuations,i,bMinOverlapW,bMaxOverlapW,bSizeDiffW);
    f(j) = sum(bcosts);
    if(writeToFile)
        featureMat(j,5:7) = bcosts;
    end
end

% write to file
if(writeToFile)
    disp('Writing features.txt ...')
    for i=1:numStates
        fprintf(fileID, '%4.6f ', featureMat(i,:));
        fprintf(fileID, '\n');
    end
fclose(fileID);
disp('done!')
end