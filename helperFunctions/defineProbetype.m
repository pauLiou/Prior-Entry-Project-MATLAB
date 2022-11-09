function Probetype = defineProbetype(numberoftrials, numberofblocks, percentE)
%returns a vector with 1s or 2s for each trial representing the type of Probe

Probetype = zeros(numberoftrials, numberofblocks);

for i = 1:numberofblocks
    
    vecProbeloc=zeros(numberoftrials,1);
    % calculate which number of elements should be 1s in the finished array
    numProbe = ceil(percentE * numberoftrials);
    vecProbeloc(1:numProbe, 1) = 1;
    vecProbeloc((numProbe + 1):numberoftrials, 1) = 2;
    
    % Permute the order of entries in vecProbeloc
    temp = randperm(numberoftrials);
    Probetype(:, i) = vecProbeloc(temp,1);
    
end
