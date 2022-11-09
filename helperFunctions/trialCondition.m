function trialConditionMatrix = trialCondition(numberoftrials,positionChoices)

leftProbe = zeros(numberoftrials,1);
rightProbe = zeros(numberoftrials,1);
arrowCue = zeros(numberoftrials,1);
firstProbe = zeros(numberoftrials,1);
equalTrial = zeros(numberoftrials,1);

%optimise by creating the matrices first

for i = 1:numberoftrials
    leftProbe(i) = mod(i,length(positionChoices)/2)+1;
    if mod(i,2) == 1
        rightProbe(i) = length(positionChoices);
    else 
        rightProbe(i) = length(positionChoices)/4*3;
    end
    arrowCue(i) = mod(i,4)+1;
    firstProbe(i) = mod(i,length(positionChoices)/2)+1;
    if i <= numberoftrials/5
        equalTrial(i) = 1;
    end
end
%extract the different trial types, e.g. leftProbe can equal 1 or 2 and
%right probe can equal 3 or 4

leftProbe = sort(leftProbe); % sort the order of left probe
rightProbe = rightProbe(1:end/2);
rightProbe = vertcat(sort(rightProbe),sort(rightProbe));
% sort the order of right probe so that it covers all trial types next to
% left probe

firstProbe = firstProbe(1:end/4);
firstProbe = vertcat(sort(firstProbe),sort(firstProbe),sort(firstProbe),sort(firstProbe));

trialConditionMatrix = [leftProbe,rightProbe,firstProbe,arrowCue,equalTrial];

trialConditionMatrix = Shuffle(trialConditionMatrix,2);