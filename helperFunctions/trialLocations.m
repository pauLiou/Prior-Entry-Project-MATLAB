function [targetFirst,firstProbe,targetLoop,targetBothNot] = trialLocations(left,right,trialnr,block,positionChoices,leftTarget,rightTarget,matrix)

if matrix(trialnr,block) <= 2 && left(trialnr,block) == 1
    firstProbe = 'left';
elseif matrix(trialnr,block) > 2 && right(trialnr,block) == 1
    firstProbe = 'right';
elseif left(trialnr,block) == 0 && right(trialnr,block) == 0
    firstProbe = 'random';
else
    fprintf('matrixMt exceeds boundries or this script sucks');
end

% amends the default stimulus so that it doesnt need to overwrite previous 8s
if strcmp(firstProbe, 'left')
    targetLoop = positionChoices(positionChoices~= leftTarget);
elseif strcmp(firstProbe, 'right')
    targetLoop = positionChoices(positionChoices~= rightTarget);
elseif strcmp(firstProbe, 'random')
    targetLoop = positionChoices(positionChoices~= matrix(trialnr,block));
end

targetBothNot = positionChoices(positionChoices~= leftTarget);
targetBothNot = targetBothNot(targetBothNot~= rightTarget);

for i = 1:length(targetLoop)
    if i == 1
        targetFirst = positionChoices(positionChoices ~= targetLoop(i));
    else
        targetFirst = targetFirst(targetFirst ~= targetLoop(i));
    end
end

end
