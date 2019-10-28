% bodyGestureTraining.m
% ���� ���� �н��Ͽ� netLSTM���� ����

% ���� ���� ����
clear;
clc;
netCNN = googlenet;
%���� ���� ���� ����
dataFolder = "��ȭ��������";
%���� ��ó��
[files, labels] = hmdb51Files(dataFolder);

%������ �н��� ���� ����
inputSize = netCNN.Layers(1).InputSize(1:2);
layerName = "pool5-7x7_s1";

%�̸� ������ ó���� ������ ���� �� ȣ��
tempFile = fullfile(tempdir,"kinect.mat");

%����->������ ó��
for i = 1:numFiles
    fprintf("Reading file %d of %d...\n", i, numFiles)
    
    video = readVideo(files(i));
    video = centerCrop(video,inputSize);
    sequences{i,1} = activations(netCNN,video,layerName,'OutputAs','columns');
end

%��ó�� ���� ����
save(tempFile,"sequences","-v7.3");

%�н� ����
numObservations = numel(sequences);
idx = randperm(numObservations);
%�н��� �����ͷ� ����
N = floor(0.7 * numObservations);

%������ ��ó��
idxTrain = idx(1:N);
sequencesTrain = sequences(idxTrain);
labelsTrain = labels(idxTrain);
idxValidation = idx(N+1:end);
sequencesValidation = sequences(idxValidation);
labelsValidation = labels(idxValidation);
numObservationsTrain = numel(sequencesTrain);
sequenceLengths = zeros(1,numObservationsTrain);

for i = 1:numObservationsTrain
    sequence = sequencesTrain{i};
    sequenceLengths(i) = size(sequence,2);
end

figure
histogram(sequenceLengths)
title("Sequence Lengths")
xlabel("Sequence Length")
ylabel("Frequency")

maxLength = 400;
idx = sequenceLengths > maxLength;
sequencesTrain(idx) = [];
labelsTrain(idx) = [];

numFeatures = size(sequencesTrain{1},1);
numClasses = numel(categories(labelsTrain));

%���۳� ���̾� ����
layers = [
    sequenceInputLayer(numFeatures,'Name','sequence')
    bilstmLayer(2000,'OutputMode','last','Name','bilstm')
    dropoutLayer(0.5,'Name','drop')
    fullyConnectedLayer(numClasses,'Name','fc')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classification')];

%��ġ ������ ����
miniBatchSize = 16;
numObservations = numel(sequencesTrain);
numIterationsPerEpoch = floor(numObservations / miniBatchSize);
numObservations
numIterationsPerEpoch

%���� �н� ����
options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',1e-4, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{sequencesValidation,labelsValidation}, ...
    'ValidationFrequency',numIterationsPerEpoch, ...
    'Plots','training-progress', ...
    'Verbose',false);

%������ �н�
[netLSTM,info] = trainNetwork(sequencesTrain,labelsTrain,layers,options);
%�н��� �����͸� netLSTM ���Ͽ� ����
save('../netLSTM','netLSTM');

%������ �н����� ���� �����ͷ� ���� 
YPred = classify(netLSTM,sequencesValidation,'MiniBatchSize',miniBatchSize);
YValidation = labelsValidation;
accuracy = mean(YPred == YValidation)

%���� �ҷ����� �Լ�
function video = readVideo(filename)

vr = VideoReader(filename);
H = vr.Height;
W = vr.Width;
C = 3;

% Preallocate video array
numFrames = floor(vr.Duration * vr.FrameRate);
video = zeros(H,W,C,numFrames);

% Read frames
i = 0;
while hasFrame(vr)
    i = i + 1;
    video(:,:,:,i) = readFrame(vr);
end

% Remove unallocated frames
if size(video,4) > i
    video(:,:,:,i+1:end) = [];
end

end


