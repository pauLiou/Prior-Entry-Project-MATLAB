function [threshold_PTA,bestBINS,usedBINS] = threshold_PTA(participant)

addpath('D:\new_experiment\PTA\');

output = xlsread(['D:\new_experiment\PTA\participantData\' num2str(participant) '.xls'],num2str(participant));

% separate out the general information
gen_data = output(1,:);
output = output(4:end,:);


output = output((output(:,13) > 0.03),:);

intensity = round(output(:,13)/0.005)*0.005; % round the output results to the right number, checked manually and this only 
% differs by like 2ms maximum across all trials
response = output(:,8);


frequencies = unique(intensity); % finding the number of unique timings
[N,edges,bins] = histcounts(intensity,ceil(sqrt(length(frequencies)))); % setting the number of 
% bins to the square root of total analysis number 


for n = 1:max(bins)
    bin.means(:,n) = mean(intensity(bins==n,:));  % the average number in each bin
    bin.accuracy(:,n) = sum(bins(response == 1) == n);
end

bin.count = N;

for i = 1:max(bins)
    bin.count_per(:,i) = round(bin.count(i)*100/sum(bin.count)); % the percentage involved in each bin
    bin.accuracy_per(:,i) = round(bin.accuracy(i)*100/sum(bin.count(:,i))); % the percentage accuracy per bin
end

for i = 1:max(bins)
    bin.holder{i} = output(bins == i,:); % separating the analysis data into the bins
end
% trying to find the boost period
for i = 1:size(bin.holder,2)
    bin.percent{i} = sum(bin.holder{i}(:,8)); % take the sum of each bins accuracy
    bin.percent{i} = (bin.percent{i}/length(bin.holder{i}))*100; % find the percentage of that accuracy per bin
end

bin.percent = [bin.percent{1,:}];

% getting the bins of all the trials within a 70% threshold
for i = 1:size(bin.holder,2)
    if bin.percent(i) >= 70 % create a variable that only holds bins with a percentage above 70
        x{i} = bin.holder{i};
    else x{i} = [];
    end
end
bin.threshold = {};
if ~isempty(x)
    for i = 1:size(x,2)
        if ~isempty(x{i})
            bin.threshold{end+1} = x{i}; % create a new struct with just the remaining trials in it
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bin hack to find the best p value for the bin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% loop that finds the bin number that is most significant
bestBINS = probeTest(output);
usedBINS = length(N);
if ~isempty(x{1})
    threshold_PTA = [mode(bin.threshold{1}(:,18)),mode(bin.threshold{end}(:,18))];
else
    threshold_PTA = [min(frequencies)+diff(frequencies(1:2)),max(frequencies)];
end

clearvars -except bestBINS usedBINS threshold_PTA

end