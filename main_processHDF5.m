% h5FileName = '/home/thanuja/DATA/cremi/train/hdf/sample_A_20160501.hdf';
% dataSet = '/volumes/raw';

h5FileName = '/home/thanuja/projects/classifiers/greentea/caffe_neural_models/pygt_uvisual_cremi/sampla_A_20160501.h5';
dataSet = '/main';

rawData = h5read(h5FileName,dataSet);
rawData = shiftdim(rawData,3);
membraneProbMaps = rawData(:,:,:,1);
membraneProbMaps = shiftdim(membraneProbMaps,1);
clear rawData

startImageID = 1;
endImageID = 1;

