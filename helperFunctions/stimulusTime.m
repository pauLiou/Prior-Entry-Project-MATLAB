function stimulusTime = stimulusTime(ifi,numberoftrials,numberofblocks,min,max);

for i = 1:numberofblocks
    idx = randperm(numberoftrials,numberoftrials);
     for j = 1:numberoftrials
        x(idx(j),i) = ifi * (mod(j, max - min + 1) + min);
        
    end
end

%x = randperm(length(x));

stimulusTime = x;

end