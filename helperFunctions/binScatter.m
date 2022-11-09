function [bin,edges,figure] = binScatter(t,reference)


x = t.Properties.VariableNames;
q = t.(reference);


frequencies = unique(round(q,3));

[N,edges,bins] = histcounts(q,ceil(sqrt(length(frequencies)))); % set the number of bins to sqrt of total trials

for n = 1:max(bins)
    bin.means(:,n) = mean(q(bins==n,:));  % the average number in each bin
    bin.accuracy(:,n) = sum(bins(t.(find(strcmp(x,'Accuracy'))) == 1) == n);
    bin.cue(:,n) = sum(bins(t.(find(strcmp(x,'CueHelp'))) == 1) == n);
end

bin.count = N;

% working out some of these bin results as percentages
for i = 1:max(bins)
    bin.count_per(:,i) = round(bin.count(i)*100/sum(bin.count)); % the percentage involved in each bin
    bin.accuracy_per(:,i) = round(bin.accuracy(i)*100/sum(bin.count(:,i))); % the percentage accuracy per bin
end
bin.count = N;
clear i N frequencies



q = t.(reference);

frequencies = unique(round(q,3));

[N,edges,bins] = histcounts(q,ceil(sqrt(length(frequencies)))); % set the number of bins to sqrt of total trials

for n = 1:max(bins)
    bin.means(:,n) = mean(q(bins==n,:));  % the average number in each bin
    bin.accuracy(:,n) = sum(bins(t.(find(strcmp(x,'Accuracy'))) == 1) == n);
    bin.cue(:,n) = sum(bins(t.(find(strcmp(x,'CueHelp'))) == 1) == n);
end

bin.count = N;

% working out some of these bin results as percentages
for i = 1:max(bins)
    bin.count_per(:,i) = round(bin.count(i)*100/sum(bin.count)); % the percentage involved in each bin
    bin.accuracy_per(:,i) = round(bin.accuracy(i)*100/sum(bin.count(:,i))); % the percentage accuracy per bin
end
bin.count = N;
clear i N frequencies

figure = scatter(edges(2:end),bin.accuracy_per,bin.count_per);

end