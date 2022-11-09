function stimulusTime = stimulusTime(denom,numberoftrials,numberofblocks,mn,mX);


a = [mn:denom:mX];

mXX = length(a);
for i = 1:numberofblocks
    idx = randperm(numberoftrials,numberoftrials);
    for j = 1:numberoftrials
        %x(idx(j),i) = mod(j, max - min + 1) + min;
        d(idx(j),i) = a(mod(j,mXX-1+1)+1);
        
    end
end

%x = randperm(length(x));

stimulusTime = d;

end