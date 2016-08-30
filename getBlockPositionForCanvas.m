function [rStart,rStop,cStart,cStop] = getBlockPositionForCanvas(blockFileName)

blockName = strtok(blockFileName,'.');
cc = strsplit(blockName,'c')
blockColID = cc{2};
dd = strsplit(cc{1},'r');
blockRowID = dd{2};

