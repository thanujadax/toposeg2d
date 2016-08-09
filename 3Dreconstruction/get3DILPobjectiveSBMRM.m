function f = ...
        get3DILPobjectiveSBMRM(ends,continuations,branches,...
        endSizeCostOffset)
            
% objective function for sbmrm input generation. Creates gold standard
% solution vector when used in ILP. Costs are based on the ground truth
% data provided ind labelDir

numEnds = length(ends);
numContinuations = length(continuations);
numBranches = length(branches);
numStates = numEnds + numContinuations + numBranches;

f = zeros(numStates,1);

% ends
for i = 1:numEnds
    j = ends(i).variableID;
    f(j) = ends(i).numPixels + endSizeCostOffset;
end

% continuations
for i = 1:numContinuations
    j = continuations(i).variableID;
    % f(j) = weights(2) * continuations(i).minOverlap;
    %f(j) = costOfContinuation(continuations,i,cMinOverlapW,cMaxOverlapW,cSizeDiffW);
    if(continuations(i).isSameLabel)
        f(j) = -25000;
    else
        f(j) = 0;
    end
end

% branches
for i = 1:numBranches
    j = branches(i).variableID;
    % f(j) = weights(3) * branches(i).minOverlap;
    % f(j) = costOfContinuation(continuations,i,bMinOverlapW,bMaxOverlapW,bSizeDiffW);
    if(branches(i).isSameLabel)
        f(j) = -30000;
    else
        f(j) = 0;
    end
end