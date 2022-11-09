%%% Paul edit version, swapped a couple things that I couldn't make sense
%%% of:
% changed randperm from randperm(numberoftrials) to curret
% changed timeMat(idx(j),i) to current
% changed mod(j, max to current

function timeMat = createTimeVec (numberoftrials, numberofblocks, min, max)
    

timeMat = zeros(numberoftrials, numberofblocks);

for i = 1:numberofblocks
    % create a random permutation for indexing
    idx = randperm(numberoftrials);
    for j = 1:numberoftrials
        timeMat(idx(j), i) = mod(j, max - min + 1) + min;
    end
end

end

 