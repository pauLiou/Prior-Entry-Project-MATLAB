%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function for the output of trial data      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SOAs,result,SOA_unique,info,bin] = trial_output(data,control,uncued,threshold)
main = [];
% get the SOAs and accuracy of the trials in question (normal data,
% control, or uncued)
if isempty(control) && isempty(uncued)
    x = [data(:,14) data(:,5)];
    main = 1;
elseif isempty(uncued)
    x = [data(:,8),data(:,5)];
    main = 0;
else
    x = [data(data(:,6) ~= (data(:,18) & data(:,6) ~= (data(:,19))),:)];
    x = [x(:,16) x(:,7)];
    main = 0;
end

SOAs = round(x(:,1),3); % the trials SOA
result = x(:,2); % response
if main == 0
    SOA_unique = unique(SOAs);
else
    SOA_unique = [0;threshold;0.080];
    for i = 1:length(SOAs)
        if SOAs(i) < 0.003
            SOAs(i) = 0;
        elseif SOAs(i) > 0.003 && SOAs(i) < 0.045
            SOAs(i) = threshold;
        else
            SOAs(i) = 0.080;
        end
    end
end



info.nCorrect = zeros(1,length(SOA_unique));% number of correct trials per SOA
info.nTrials = zeros(1,length(SOA_unique));% number of trials at each SOA

% fills in the nCorrect and nTrials data based on the SOA and result data
for i = 1:length(SOA_unique)
    id = (SOAs == SOA_unique(i)) & ~isnan(result);
    info.nTrials(i) = sum(id);
    info.nCorrect(i) = sum(result(id));
end

% calculates the percentage correct
info.pCorrect = info.nCorrect./info.nTrials;

info.pCorrect = info.pCorrect';
info.nCorrect = info.nCorrect';
info.nTrials = info.nTrials';


% the percentage correct with the SOAs
info.pCorrect_data = [info.pCorrect,SOA_unique];

info.data_raw = [SOA_unique,info.nCorrect,info.nTrials];

% creating bins - set at the end of histcounts(SOA,bins)
if main == 0
    [N,edges,bins] = histcounts(SOA_unique,ceil(sqrt(length(SOA_unique))));
else
    N = length(SOA_unique);
    edges = SOA_unique';
    bins = 1:length(SOA_unique);
end


% generating the means of each bin
for n = 1:max(bins)
    bin.means(:,n) = sum(info.nCorrect(bins==n,:));
    bin.total(:,n) = sum(info.nTrials(bins==n,:));
end

for n = 1:max(bins)
    bin.correct(:,n) = sum(info.nCorrect(bins ==n,:));
end

bin.edges = edges;

if main == 0
    edges = ceil(edges*100)/100;
    info.data_bin = [edges(1:end-1);bin.correct;bin.total]';
else
    info.data_bin = [edges;bin.correct;bin.total]';
end

end