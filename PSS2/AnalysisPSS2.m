function AnalysisPSS(participant);

%participant = inputdlg('participant number');participant = participant{1,1};

%load(['E:\Analysis\PSS2\participantData\participant_',num2str(participant),'.mat']);
%load(['E:\Analysis\PSS2\participantData\correct_',num2str(participant),'.mat']);
thresholdPSS = struct2array(load(['E:\Analysis\PSS\participantData\prelimresults_PSS_',num2str(participant),'.mat'],'threshold'));

% load in the data from directory
data = output.responses;
% create a single column array with a boolean showing correct fixation
correctArray = vertcat(correct(:,1),correct(:,2),correct(:,3),correct(:,4),correct(:,5),correct(:,6));
% remove trials with bad fixation
data = output.responses((correctArray == 1),:);

% separate data into the two different phases (cue vs no cue)
numberofblocks = [min(data(:,1)):max(data(:,1))];
phase = numberofblocks(exp.phase == 1); % cue = 1, no cue = 0

data_cue = data((ismember(data(:,1),phase)),:);
data_nocue = data((~ismember(data(:,1),phase)),:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No cue analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[SOAs, result_control,SOA_control,info_data_nocue,bin] = trial_output(data_nocue,1,[],1,thresholdPSS);

result.bin.data_nocue = psychofunc(info_data_nocue.data_bin);
result.raw.data_nocue = psychofunc(info_data_nocue.data_raw);
plotPsych(result.bin.data_nocue)

clear ans SOAs SOA_unique x y info bin

nocueThreshold_raw = getThreshold(result.raw.data_nocue,0.5,1);
nocueThreshold_bin = getThreshold(result.bin.data_nocue,0.5,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cue analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[SOAs,result_control,SOA_control,info_data_cue,bin] = trial_output(data_cue,1,[],1,thresholdPSS);

result.bin.data_cue = psychofunc(info_data_cue.data_bin);
result.raw.data_cue = psychofunc(info_data_cue.data_raw);
plotPsych(result.bin.data_cue)

clear ans SOAs SOA_unique x y info bin

cueThreshold_raw = getThreshold(result.raw.data_cue,0.5,1);
cueThreshold_bin = getThreshold(result.bin.data_cue,0.5,1);

% separate the cued data into the three conditions (low,high,uncued)

data_low = data_cue((data_cue(:,12) == 1),:); % low interference condition
data_high = data_cue((data_cue(:,13) == 1),:); % high interferece condition
data_uncued = data_cue(find(all([data_cue(:,12),data_cue(:,13)] == 0,2)),:); % uncued condition

%%%%%%%%
% psychometric function for low interference condition
%%%%%%%%

[SOAs,result_control,SOA_control,info_data_low,bin] = trial_output(data_low,1,[],1,thresholdPSS);

result.bin.data_low = psychofunc(info_data_low.data_bin);
result.raw.data_low = psychofunc(info_data_low.data_raw);
%plotPsych(result.bin.data_low)

clear ans SOAs SOA_unique x y info bin

%%%%%%%%
% psychometric function for high interference condition
%%%%%%%%

[SOAs,result_control,SOA_control,info_data_high,bin] = trial_output(data_high,1,[],1,thresholdPSS);

result.bin.data_high = psychofunc(info_data_high.data_bin);
result.raw.data_high = psychofunc(info_data_high.data_raw);
%plotPsych(result.bin.data_high)

clear ans SOAs SOA_unique x y info bin

%%%%%%%%
% psychometric function for uncued condition
%%%%%%%%

[SOAs,result_control,SOA_control,info_data_uncued,bin] = trial_output(data_uncued,1,[],1,thresholdPSS);

result.bin.data_uncued = psychofunc(info_data_uncued.data_bin);
result.raw.data_uncued = psychofunc(info_data_uncued.data_raw);
%plotPsych(result.bin.data_uncued)

clear ans SOAs SOA_unique x y info bin

figure(1)
plotOptions.lineColor = [1,0,0];
plotOptions.dataColor = [1,0,0];
plotOptions.plotData = false;
[hline,hdata] = plotPsych(result.bin.data_low,plotOptions);
hold on
plotOptions.plotData = false;
plotOptions.lineColor = [1,1,0];
plotOptions.dataColor = [1,1,0];
[hline2,hdata2] = plotPsych(result.bin.data_high,plotOptions);
plotOptions.lineColor = [0,1,0];
plotOptions.dataColor = [0,1,0];
plotOptions.plotData = false;
[hline3,hdata3] = plotPsych(result.bin.data_uncued,plotOptions);
legend([hline,hline2,hline3],'Low','High','Uncued')
hold off

thresholdcue.low_raw = getThreshold(result.raw.data_low,0.5,1);
thresholdcue.low_bin = getThreshold(result.bin.data_low,0.5,1);
thresholdcue.high_raw = getThreshold(result.raw.data_high,0.5,1);
thresholdcue.high_bin = getThreshold(result.bin.data_high,0.5,1);
thresholdcue.uncued_raw = getThreshold(result.raw.data_uncued,0.5,1);
thresholdcue.uncued_bin = getThreshold(result.bin.data_uncued,0.5,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
plotOptions.lineColor = [1,1,0];
plotOptions.dataColor = [1,1,0];
[nocue1,nocue2] = plotPsych(result.bin.data_nocue,plotOptions);
hold on
plotOptions.lineColor = [1,0,1];
plotOptions.dataColor = [1,0,1];
[cue1,cue2] = plotPsych(result.bin.data_cue,plotOptions);
legend([nocue1,cue1],'No Cue','Cue')
hold off

[R,P,info] = reactionTimePSS(data);

SOA.low{1} = data_low((data_low(:,7) == 0),:);
SOA.low{2} = data_low((data_low(:,7) == thresholdPSS),:);
SOA.low{3} = data_low((data_low(:,7) == 0.060),:);

SOA.high{1} = data_high((data_high(:,7) == 0),:);
SOA.high{2} = data_high((data_high(:,7) == thresholdPSS),:);
SOA.high{3} = data_high((data_high(:,7) == 0.060),:);

SOA.uncued{1} = data_uncued((data_uncued(:,7) == 0),:);
SOA.uncued{2} = data_uncued((data_uncued(:,7) == thresholdPSS),:);
SOA.uncued{3} = data_uncued((data_uncued(:,7) == 0.060),:);

for i = 1:3
    percentage{1,i} = sum(SOA.low{i}(:,5))/length(SOA.low{i})*100;
    percentage{2,i} = sum(SOA.high{i}(:,5))/length(SOA.high{i})*100;
    percentage{3,i} = sum(SOA.uncued{i}(:,5))/length(SOA.uncued{i})*100;
end




cd('E:\Analysis\PSS2\participantData');
save(['prelimresults_PSS2_',num2str(participant),'.mat']);

end




