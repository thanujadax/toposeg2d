function featureMat = writeFeaturesFile3DILP(f,ends,continuations,branches,...
    numFeatures,outputPath)

% features.txt
% 
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

% end costs

% continuation costs

% branch costs

numRows = numel(f);

featureMat = zeros(numRows,numFeatures);

filename = 'features.txt';
filename = fullfile(outputPath,filename);
fileID = fopen(filename,'w');

numVar = numel(f);

