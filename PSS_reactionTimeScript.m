% Lets have a look at the control data reaction times
% requires the AnalysisScript components to work

data = output_control.output.responses;

SOAs = data(:,8); % SOA for each trial
SOA_unique = unique(data(:,8)); % unique SOAs
RTs = data(:,3); % reaction time of each trial

% create some variables that show the reaction time means of each SOA
for i = 1:length(SOA_unique)
    id = (SOAs == SOA_unique(i));
    info.nTrials(i) = sum(id);
    info.RTs(i) = mean(RTs(id));
end

info.RTs = info.RTs';
info.nTrials = info.nTrials';
% load the SOAs into separate bins
[N,edges,bins] = histcounts(SOA_unique,ceil(sqrt(length(SOA_unique))));


for n = 1:max(bins)
    bin.means(:,n) = mean(info.RTs(bins==n,:));
    bin.total(:,n) = sum(info.nTrials(bins==n,:));
end

info.data_bin = [edges(1:end-1);bin.means;bin.total]';

scatter(info.data_bin(:,1),info.data_bin(:,2))

%%% correlation
x = info.data_bin(:,1); % SOAs binned
y = info.data_bin(:,2); % reaction time means of each bin

[R,P] = corrcoef(x,y)

clear x y id
