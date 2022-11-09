% PSS value from experiment 1

function MAINthreshold = MAINthreshold(data,thresholdPSS)
addpath('D:\new_experiment\helperFunctions');
addpath('C:\toolbox\psignifit-master');

[SOAs,result_uncued,SOA_unique,info,bin] = trial_output(data,[],[],thresholdPSS);

result.raw.control = psychofunc(info.data_raw);
plotPsych(result.raw.control);

result.bin.control = psychofunc(info.data_bin);
plotPsych(result.bin.control);

[threshold,CI] = getThreshold(result.raw.control,0.5,1);

MAINthreshold = threshold;