function [firstProbe, secondProbe, targetLoop, targetBothNot] = trialLocations_new(left,right,trialnr,block,positionChoices,leftTarget,rightTarget,matrix)

if matrix(trialnr,block) <= 2 && left(trialnr,block) == 1
    firstProbe = leftTarget;
    secondProbe = rightTarget;
    targetLoop = positionChoices(positionChoices~= firstProbe);
elseif matrix(trialnr,block) > 2 && right(trialnr,block) == 1
    firstProbe = rightTarget;
    secondProbe = leftTarget;
    targetLoop = positionChoices(positionChoices~= firstProbe);
elseif left(trialnr,block) == 0 && right(trialnr,block) == 0
    %firstProbe = positionChoices(datasample(positionChoices(positionChoices ~= leftTarget & positionChoices ~= rightTarget & positionChoices ~= matrix(trialnr,block)),1));
    firstProbe = datasample([leftTarget,rightTarget],1);
    %secondProbe = positionChoices(positionChoices ~= leftTarget & positionChoices ~= rightTarget & positionChoices ~= firstProbe);
    secondProbe = [leftTarget,rightTarget];
    secondProbe = secondProbe(secondProbe ~= firstProbe);
    targetLoop = positionChoices(positionChoices~= firstProbe);
end

targetBothNot = positionChoices(positionChoices~= firstProbe);
targetBothNot = targetBothNot(targetBothNot~= secondProbe);
