function [flip,totals] = flipTotals(flip)

for j = 1:length(3)
    for i = 1:length(flip)
        if mod(flip(i,1),2) == 0
            x = flip(i,7);
            y = flip(i,9);
            flip(i,7) = y;
            flip(i,9) = x;
        end
    end
end

for j = 1:length(3)
    for i = 1:4
        totals{j}(i) = sum(flip(:,7) == i);
    end
end

end