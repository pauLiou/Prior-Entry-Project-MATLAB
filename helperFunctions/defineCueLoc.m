function [matrixProbe,probeTypeLeft,probeTypeRight] = defineCueLoc(numberoftrials, numberofblocks, positionChoices,left,right)
% Function that makes the arrow cue appear 50% at either left or right
% probe location and 50% randomly at the other 2 locations

matrixProbe = zeros(numberoftrials, numberofblocks); % generated to optimize
probeTypeLeft = zeros(numberoftrials,numberofblocks);
probeTypeRight = zeros(numberoftrials,numberofblocks);


%changed now so that it's proportional to number of locations
probeType = zeros(numberoftrials, numberofblocks);
nHalf = numberoftrials/2;


probeType(1:nHalf,:) = 1;
for i = 1:numberofblocks
    temp = Shuffle(1:numberoftrials);
    for j = 1:numberoftrials
        if temp(j) >= numberoftrials/4+1 && temp(j) <= numberoftrials/2  %mod(j,2) == 1
            probeTypeLeft(j, i) = probeType(temp(j), i);
        elseif temp(j) >= numberoftrials/4*3+1 && temp(j) <= numberoftrials
            probeTypeLeft(j, i) = probeType(temp(j), i);
        else
            probeTypeRight(j,i) = probeType(temp(j), i);
        end
    end
end

% probeType(1:nHalf,:) = 1;
% for i = 1:numberofblocks
%     temp = randperm(numberoftrials);
%     for j = 1:numberoftrials
%         if mod(j,2) == 1
%             probeTypeLeft(j, i) = probeType(temp(j), i);
%         else
%             probeTypeRight(j,i) = probeType(temp(j), i);
%         end
%     end
% end

for i = 1:numberofblocks
    for j = 1:numberoftrials
       if probeTypeLeft(j,i) == 1
           matrixProbe(j,i) = left(j,i);
       elseif probeTypeRight(j,i) == 1
           matrixProbe(j,i) = right(j,i);
       else
           matrixProbe(j,i) = positionChoices(datasample(positionChoices(positionChoices ~= left(j,i) & positionChoices ~= right(j,i)),1));
       end
    end
end

end
        