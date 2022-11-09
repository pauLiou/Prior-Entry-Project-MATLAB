function matrixProbe = defineProbeloc(numberoftrials, numberofblocks, startStimuli, endStimuli, movementCue, probePos, positionChoices)
%Saves the Movement target locations (1-4 bzw. 1-9)

matrixProbe = zeros(numberoftrials, numberofblocks);
% get random 50/50 distribution over all trials correlating to 0 = probe =
% MT, 1 = probe != MT

%changed now so that it's proportional to number of locations
probeType = zeros(numberoftrials, numberofblocks);
if range(startStimuli:endStimuli) >= 3
    nHalf = floor(numberoftrials / length(positionChoices));
else
    nHalf = numberoftrials/2;
end

probeType(1:nHalf,:) = 1;
for i = 1:numberofblocks
    temp = randperm(numberoftrials);
    probeType(:, i) = probeType(temp, i);
end

for i = 1:numberoftrials
    for j = 1:numberofblocks
        
        % movementcue lies in this half of the matrix -> probe is set
        % vector with all positions in the current half
        % neighbor positions possible
        % availablePositions is all the positions in the current half
        % of the half circle
        availablePositions = (positionChoices >= startStimuli & positionChoices <= endStimuli) .* positionChoices;
        availablePositions(availablePositions == 0) = [];
        
        if (movementCue(i, j) >= startStimuli && movementCue(i, j) <= endStimuli)
            % according to probeType -> 'MT location' - 0,'non MT location' - 1
            if (probeType(i,j) == 1) % Probe equals movement cue
                matrixProbe(i, j) = movementCue(i ,j);
            else % Probe not on movement cue
               % option 1: neighbors not possible
               if (probePos == 0)
                   targetID = find(availablePositions == movementCue(i, j));
                   leftBoundary = max(1, targetID - 1);
                   rightBoundary = min(size(availablePositions, 2), targetID + 1);
                   availablePositions(leftBoundary:rightBoundary) = [];
                   matrixProbe(i, j) = availablePositions(ceil(rand*length(availablePositions)));
               % option 2: neighbors are possible    
               else
                   if i == 1 
                       stimuli = availablePositions(availablePositions~=movementCue(i, j));
                   else
                       stimuli = availablePositions(availablePositions~=movementCue(i, j));
                       if range(startStimuli,endStimuli) >= 3
                        stimuli = stimuli(stimuli~=matrixProbe(i-1,j));
                       end
                   end
                   matrixProbe(i, j) = stimuli(ceil(rand*length(stimuli)));
                   
               end
                   
            end
        % movement cue lies in the other half -> random choice for probe
        % location
        else
            matrixProbe(i, j) = availablePositions(ceil(rand*length(availablePositions)));
        end
    end
end

end