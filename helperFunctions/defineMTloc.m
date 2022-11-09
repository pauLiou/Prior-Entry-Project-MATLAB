function matrixMT = defineMTloc(numberoftrials, numberofblocks, positionChoices)
%Saves the Movement target locations (1-4 bzw. 1-9)

matrixMT = zeros(numberoftrials, numberofblocks);

% Random distribution between 1 and number of stimuli
for i = 1:numberoftrials
    for j = 1:numberofblocks
        matrixMT(i, j) = positionChoices(ceil(rand*length(positionChoices)));
    end
end
end