function probeType = equalProbe(numberoftrials,numberofblocks,positionChoices)

probeType = zeros(numberoftrials, numberofblocks);
nHalf = floor(numberoftrials / length(positionChoices));
probeType(1:nHalf,:) = 1;
for i = 1:numberofblocks
    temp = randperm(numberoftrials);
    probeType(:, i) = probeType(temp, i);
end

end