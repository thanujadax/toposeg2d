% read probability map
inputFileName = '/home/thanuja/projects/data/toyData/set8/membranes/08_schmidhuber_membrane.tiff';
inputImage = readTiffStackToArray(inputFileName);
figure;imagesc(inputImage)
% ws
ws_input = watershed(inputImage);
ws_rgb_0 = indexImg2rgbImg(ws_input);
figure;imagesc(ws_input);
% gaussian filter
sigma = 0.5;
maskSize = 5;
smoothProbMap = gaussianFilter(inputImage,sigma,maskSize);
figure;imagesc(smoothProbMap)
% ws
ws_smooth = watershed(smoothProbMap);
ws_smooth_r = assignRandomIndicesToWatershedTransform(ws_smooth);
ws_rgb = indexImg2rgbImg(ws_smooth_r);
figure;imagesc(ws_rgb);

imwrite(ws_rgb_0,'watershedSegments_0.png','png');