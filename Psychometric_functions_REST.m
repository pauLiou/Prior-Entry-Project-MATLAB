%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Different trial types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('C:\toolbox\psignifit-master');
% first for the control experiment
data1 = control_experiment;
trialtype1 = data1(mod(data1(:,1),2) == 1,:); % looking if there is a difference between choosing FIRST target and choosing SECOND
trialtype2 = data1(mod(data1(:,1),2) == 0,:);

data1 = [trialtype1(:,8),trialtype1(:,7)];
SOAs = round(data1(:,1),3); % the trials SOA
result = data1(:,2); % the responses


SOA_unique = unique(SOAs); % list of SOAs
nCorrect = zeros(1,length(SOA_unique)); % number of correct trials per SOA
nTrials = zeros(1,length(SOA_unique)); % number of trials at each SOA

% fills in the nCorrect and nTrials data based on the SOA and result data
for i = 1:length(SOA_unique)
    id = (SOAs == SOA_unique(i)) & ~isnan(result);
    nTrials(i) = sum(id);
    nCorrect(i) = sum(result(id));
end

% calculates the percentage correct
pCorrect = nCorrect./nTrials;

pCorrect = pCorrect';
nCorrect = nCorrect';
nTrials = nTrials';

% creating bins - set at the end of histcounts(SOA,bins)
[N,edges,bins] = histcounts(SOA_unique,5);

% generating the means of each bin
for n = 1:max(bins)
    bin.means(:,n) = mean(pCorrect(bins==n,:));
    bin.total(:,n) = sum(nTrials(bins==n,:));
end

for n = 1:max(bins)
    bin.correct(:,n) = mean(pCorrect(bins ==n,:));
end

data_bin = [edges(2:end);bin.correct;bin.total]';

% plot the psychometric function
options             = struct;
options.sigmoidName = 'norm';   % choose a cumulative Gaussian as the sigmoid
options.expType     = '2AFC'; 
result7 = psignifit(data_bin,options);
result7.Fit;
result7.conf_Intervals;

clear data SOAs result SOA_unique nCorrect nTrials bin bins edges N n data_bin


% first for the control experiment
data1 = control_experiment;
trialtype1 = data1(mod(data1(:,1),2) == 1,:); % looking if there is a difference between choosing FIRST target and choosing SECOND
trialtype2 = data1(mod(data1(:,1),2) == 0,:);

data1 = [trialtype2(:,8),trialtype2(:,7)];
SOAs = round(data1(:,1),3); % the trials SOA
result = data1(:,2); % the responses


SOA_unique = unique(SOAs); % list of SOAs
nCorrect = zeros(1,length(SOA_unique)); % number of correct trials per SOA
nTrials = zeros(1,length(SOA_unique)); % number of trials at each SOA

% fills in the nCorrect and nTrials data based on the SOA and result data
for i = 1:length(SOA_unique)
    id = (SOAs == SOA_unique(i)) & ~isnan(result);
    nTrials(i) = sum(id);
    nCorrect(i) = sum(result(id));
end

% calculates the percentage correct
pCorrect = nCorrect./nTrials;

pCorrect = pCorrect';
nCorrect = nCorrect';
nTrials = nTrials';

% creating bins - set at the end of histcounts(SOA,bins)
[N,edges,bins] = histcounts(SOA_unique,5);

% generating the means of each bin
for n = 1:max(bins)
    bin.means(:,n) = mean(pCorrect(bins==n,:));
    bin.total(:,n) = sum(nTrials(bins==n,:));
end

for n = 1:max(bins)
    bin.correct(:,n) = mean(pCorrect(bins ==n,:));
end

data_bin = [edges(2:end);bin.correct;bin.total]';

% plot the psychometric function
options             = struct;
options.sigmoidName = 'norm';   % choose a cumulative Gaussian as the sigmoid
options.expType     = '2AFC'; 
result8 = psignifit(data_bin,options);
result8.Fit;
result8.conf_Intervals;
plotOptions.lineColor = [1,0,0]
plotOptions.dataColor = [1,0,0]
[hline,hdata] = plotPsych(result7,plotOptions);
hold on
[hline2,hdata2] = plotPsych(result8);
legend([hline,hline2],'Low','High')

clear data SOAs result SOA_unique nCorrect nTrials bin bins edges N n
