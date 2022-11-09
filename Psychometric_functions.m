%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Running Psychometric functions on the data and creating bins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import the data from Analysis_MAIN (trialsRemovedFULL, cue)
% Import the data from Experiment 1 (call it control_experiment)

addpath('D:\new_experiment\helperFunctions');
addpath('C:\toolbox\psignifit-master');
clearvars -except analysis analysisFULL analysisFULLTAB control_experiment cue trialsRemovedFULL trialsRemoved Eye

participant = inputdlg('participant number');participant = participant{1,1};

data = trialsRemovedFULL((trialsRemovedFULL(:,22) ~= 1),:);

[SOAs,result,SOA_unique,info,bin] = trial_output(data,[],[]); % function to obtain the requisit info for plotting graphs
x = info.pCorrect;y = SOA_unique;
plot(y,smooth(x),'r');

result.raw = psychofunc(info.data_raw);
plotPsych(result.raw); % plot the psychometric function of these results in raw form

result.bin = psychofunc(info.data_bin);
plotPsych(result.bin); % plot the psychometric function of these results in binned form


clear ans SOAs SOA_unique x y info bin

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the functions of the different conditions (binned for now)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% High Interference
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

highInterference = cue.HighInterference((cue.HighInterference(:,22) ~= 1),:);

[SOAs,result_high,SOA_unique,info,bin] = trial_output(highInterference,[],[]);

result.raw.high = psychofunc(info.data_raw);
plotPsych(result.raw.high);

result.bin.high = psychofunc(info.data_bin);
plotPsych(result.bin.high);

clear ans SOAs SOA_unique x y info bin

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Low Interference
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

lowInterference = cue.LowInterference((cue.LowInterference(:,22) ~= 1),:);


[SOAs,result_low,SOA_unique,info,bin] = trial_output(lowInterference,[],[]);

result.raw.low = psychofunc(info.data_raw);
plotPsych(result.raw.low);

result.bin.low = psychofunc(info.data_bin);
plotPsych(result.bin.low);

clear ans SOAs SOA_unique x y info bin


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add in the uncued trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[SOAs,result_uncued,SOA_unique,info,bin] = trial_output(data,[],1);

result.raw.uncued = psychofunc(info.data_raw);
plotPsych(result.raw.uncued);

result.bin.uncued = psychofunc(info.data_bin);
plotPsych(result.bin.uncued);

clear ans SOAs SOA_unique x y info bin



plotOptions.lineColor = [1,0,0];
plotOptions.dataColor = [1,0,0];
plotOptions.plotData = false;
[hline,hdata] = plotPsych(result.bin.low,plotOptions);
hold on
plotOptions.plotData = false;
plotOptions.lineColor = [1,1,0];
plotOptions.dataColor = [1,1,0];
[hline2,hdata2] = plotPsych(result.bin.high,plotOptions);
plotOptions.lineColor = [0,1,0];
plotOptions.dataColor = [0,1,0];
plotOptions.plotData = false;
[hline3,hdata3] = plotPsych(result.bin.uncued,plotOptions);
legend([hline,hline2,hline3],'Low','High','Uncued')
hold off

clear ans SOAs SOA_unique x y info bin

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add in experiment 1 stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[SOAs,result_uncued,SOA_unique,info,bin] = trial_output(control_experiment,1,[]);

result.raw.control = psychofunc(info.data_raw(1:end-2,:));
plotPsych(result.raw.control);

result.bin.control = psychofunc(info.data_bin(1:end-1,:));
plotPsych(result.bin.control);

plotOptions.plotData = false; % decide whether or not to plot the data points
plotOptions.lineColor = [1,0,0];
plotOptions.dataColor = [1,0,0];
[hline,hdata] = plotPsych(result.bin.low,plotOptions);
hold on
plotOptions.plotData = false;
plotOptions.lineColor = [1,1,0];
plotOptions.dataColor = [1,1,0];
[hline2,hdata2] = plotPsych(result.bin.high,plotOptions);
plotOptions.plotData = false;
plotOptions.lineColor = [0,1,0];
plotOptions.dataColor = [0,1,0];
[hline3,hdata3] = plotPsych(result.bin.control,plotOptions);
plotOptions.plotData = false;
plotOptions.lineColor = [0,0,1];
plotOptions.dataColor = [0,0,1];
plotOptions.xLabel = 'Stimulus Onset Asynchrony';
[hline4,hdata4] = plotPsych(result.bin.uncued,plotOptions);
 
legend([hline,hline2,hline3,hline4],'Low','High','Control','Uncued')

cd(['D:\new_experiment\participantData'])
save(['results' num2str(participant) '.mat'])


plot(SOA_unique,smooth(test.uncued));
hold on; 
plot(SOA_unique,smooth(test.high),'r');
plot(SOA_unique,smooth(test.low),'c');
plot(SOA_unique,smooth(test.control),'g');
legend('uncued','high','low','control');
hold off

plot(SOA_unique,smooth(test.uncued));
hold on;
plot(SOA_unique,smooth(test.control),'g');