%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function for psychometric function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = psychofunc(data_bin)

options = struct;
options.sigmoidName    = 'logistic';%'norm';%'weibull';
options.expType = '2AFC';
options.threshPC = 0.50;
%options.confP          = .90;
%options.stimulusRange = [0.01,0.6];
result = psignifit(data_bin,options);
result.Fit;
result.conf_Intervals;

end
