function stimulusTime = stimulusTimePTA_new(numberoftrials,numberofblocks,probeMatrix)

sigma = diff(probeMatrix);
sigma = sigma(1);

mu = mean(probeMatrix);


stimulusTime = round(normrnd(mu,sigma,numberoftrials,numberofblocks)/sigma)*sigma;100;

end