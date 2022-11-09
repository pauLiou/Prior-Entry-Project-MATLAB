function bestProbe = Probetest(output)

for i = 1:ceil(sqrt(length(output)))
    clear bin edges N bins
    intensity = output(:,13);
    [N,edges,bins] = histcounts(intensity,i);
    for n = 1:max(bins)
        bin.accuracy(:,n) = sum(bins(output(:,8) == 1) == n);
    end
    for i = 1:max(bins)
        bin.accuracy_per(:,i) = round(bin.accuracy(i)*100/sum(N(:,i))); % the percentage accuracy per bin
    end
    [r p] = corrcoef(edges(2:end),bin.accuracy_per);
    
    x{i} = p;
end

for i = 2:size(x,2)
    x{i} = x{i}(2);
end

x = [x{:}];
bestProbe = min(x);
bestProbe = find(x == bestProbe);

clear x r p bin intensity

end