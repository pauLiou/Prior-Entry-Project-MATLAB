function matrixProbe(numberofblocks,numberoftrials, positionChoices, movementCue)
matrixProbe = zeros(numberoftrials,numberofblocks);
dog = randperm(numberoftrials,numberofblocks)';
for i = 1:numberoftrials
    for j = 1:numberofblocks
        if dog(i,j) <= numberoftrials/length(positionChoices)
            matrixProbe(i, j) = movementCue(i ,j);
        elseif dog(i,j) < numberoftrials/2 && dog(i) > numberoftrials/length(positionChoices)
            matrixProbe(i, j) = 2;
            if movementCue(i,j) == matrixProbe(i,j)
                matrixProbe(i,j) = 3;
            end
        elseif dog(i,j) >= numberoftrials/2 && dog(i) < (numberoftrials/length(positionChoices))*3
            matrixProbe(i,j) = 3;
            if movementCue(i,j) == matrixProbe(i,j)
                matrixProbe(i,j) = 1;
            end
        else
            matrixProbe(i,j) = 4;
            if movementCue(i,j) == matrixProbe(i,j)
                matrixProbe(i,j) = 2;
            end
        end
    end
end

end
    
        
        
