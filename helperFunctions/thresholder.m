function [thresholdPSS,thresholdPSS_raw,thresholdJND] = thresholder(participant)

% Input the participant number (VPN) after the PSS dataset has been
% collected and it will automatically generate a threshold for PSS in the
% main experiment based on a 75% Point of Subjective Simultinaety score.

% It's recommended to use the binned score, but it is also possible to
% extract the exact number (raw)

addpath('helperFunctions/');
% read in the specific participant datafile from experiment
data1 = xlsread(['D:\new_experiment\PSS\participantData\' num2str(participant) '.xls'],num2str(participant));

% separate out the general information
gen_data = data1(1,:);
data1 = data1(4:end,:);

data2 = data1(:,7:8);
% The columns represent:

SOAs = round(data2(:,2),3); % the trials SOA
result = data2(:,1); % the responses
trialtype1 = data1(mod(data1(:,1),2) == 1,:);
trialtype2 = data1(mod(data1(:,1),2) == 0,:);

SOA_unique = unique(SOAs); % list of SOAs
nCorrect = zeros(1,length(SOA_unique)); % number of correct trials per SOA
nTrials = zeros(1,length(SOA_unique)); % number of trials at each SOA

% fills in the nCorrect and nTrials data based on the SOA and result data
for i = 1:length(SOA_unique)
    id = (SOAs == SOA_unique(i)) & ~isnan(result(i));
    nTrials(i) = sum(id);
    nCorrect(i) = sum(result(id));
end

% calculates the percentage correct
pCorrect = nCorrect./nTrials;
pCorrect = pCorrect';
nCorrect = nCorrect';
nTrials = nTrials';

% the percentage correct with the SOAs
pCorrect_data = [pCorrect,SOA_unique];
data = [SOA_unique,pCorrect,nTrials];



% creating bins - set at the end of histcounts(SOA,bins)
[N,edges,bins] = histcounts(SOA_unique,ceil(sqrt(length(SOA_unique))));

% generating the means of each bin
for n = 1:max(bins)
    bin.means(:,n) = mean(pCorrect(bins==n,:));
    bin.total(:,n) = sum(nTrials(bins==n,:));
end

for n = 1:max(bins)
    bin.correct(:,n) = mean(pCorrect(bins ==n,:));
end

data = [edges(1:end-1);bin.correct;bin.total];
%plot(edges(:,(1:end-1)),bin.correct)

% creating the 75% threshold with the bins
threshold.bin = min(edges(bin.means > 0.75));
threshold.JND = threshold.bin/1000;

% creating the 75% threshold with no bin - raw number
threshold.raw = min(SOA_unique(pCorrect > 0.75));
threshold.JNDraw = threshold.raw/1000;

threshold.PSS = min(edges(bin.means > 0.55));
threshold.PSS = threshold.PSS/1000;
threshold.PSS_raw = min(SOA_unique(pCorrect > 0.55));
threshold.PSS_raw = threshold.PSS_raw/1000;

thresholdJND = threshold.JND;
thresholdPSS = threshold.PSS;
thresholdPSS_raw = threshold.PSS_raw;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SOAs2 = round(cuedData(:,6),3);
cuedSOA = unique(SOAs2);
result2 = cuedData(:,7);
for i = 1:length(cuedSOA)
    id = (SOAs2 == cuedSOA(i)) & ~isnan(result2(i));
    nTrials(i) = sum(id);
    nCorrect(i) = sum(result2(id));
end

pCorrect = nCorrect./nTrials;
pCorrect = pCorrect';
nCorrect = nCorrect';
nTrials = nTrials';

% the percentage correct with the SOAs
pCorrect_data = [pCorrect,cuedSOA];
data = [cuedSOA,pCorrect,nTrials];

[N,edges,bins] = histcounts(cuedSOA,ceil(sqrt(length(cuedSOA))));


for n = 1:max(bins)
    bin.means(:,n) = mean(pCorrect(bins==n,:));
    bin.total(:,n) = sum(nTrials(bins==n,:));
end

for n = 1:max(bins)
    bin.correct(:,n) = mean(pCorrect(bins ==n,:));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
secondProbe = data1(:,12:13);
secondProbe = secondProbe(:,1)|secondProbe(:,2);
secondProbe = secondProbe ~= data1(:,14);


cuedsecondData = data1(secondProbe,:);
SOAs3 = round(cuedsecondData(:,6),3);
cuedSOA = unique(SOAs3);
result3 = cuedsecondData(:,7);
for i = 1:length(cuedSOA)
    id = (SOAs3 == cuedSOA(i)) & ~isnan(result3(i));
    nTrials(i) = sum(id);
    nCorrect(i) = sum(result3(id));
end

pCorrect = nCorrect./nTrials;
pCorrect = pCorrect';
nCorrect = nCorrect';
nTrials = nTrials';

pCorrect_data = [pCorrect,cuedSOA];
data = [cuedSOA,pCorrect,nTrials];

[N,edges,bins] = histcounts(cuedSOA,ceil(sqrt(length(cuedSOA))));

for n = 1:max(bins)
    bin.means(:,n) = mean(pCorrect(bins==n,:));
    bin.total(:,n) = sum(nTrials(bins==n,:));
end

for n = 1:max(bins)
    bin.correct(:,n) = mean(pCorrect(bins ==n,:));
end


