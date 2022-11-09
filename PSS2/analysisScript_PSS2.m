function PSSdatacheck(participant)
addpath(genpath('E:\'));

loadVars = 0;
%participant = inputdlg('participant number');participant = participant{1,1};
% import the participant behavioural data as 'output'
load(['E:\Analysis\PSS2\participantData\participant_' num2str(participant)]);
Eye = eyeTrackerRead2(participant);

% adding in some important trial information that will help with the
% extraction including screen resolution, threshold radius of allowed
% saccade accuracy, number of trials etc
numberoftrials = max(output.responses(:,2));
numberofblocks = max(output.responses(:,1));
probeMatrix = [min(output.responses(:,4)):0.005:max(output.responses(:,4))];
threshold_radius = 2;
numStimuli = max(output.responses(:,6));
positionChoices = [1:max(output.responses(:,4))];


threshold_radius = 72.1706;

% create the different blocks for the behavioural output (into a cell
% structure)
for i = 1:max(output.responses(:,1))
    block{i} = output.responses((output.responses(:,1) == i),:);
end

% create the different blocks for the eyetracker data (as a variable called
% Blocks)
Eye.Blocks = ones(size(Eye,1),1);
for i = 1:length(block)
    k = ['Trial: ',num2str(numberoftrials)];
    w = contains(Eye.Content,k);
    
    c = find(w == 1)+1;
    c = [ones(1); c];
    Eye.Blocks(c(i):end) = i;
end
clear i j z c


for i = 1:size(Eye)
    if(strcmp(Eye.CategoryLeft(i),'Saccade')) && (strcmp(Eye.CategoryRight(i),'Saccade'))
        Eye.NewIndex(i) = 1;
    else
        Eye.NewIndex(i) = 0;
    end
end

% Get the screen center
[x,y] = RectCenter([0,0,exp.res]);
xyCenter = [x,y];



if sum(Eye.NewIndex) > 0
    [correct] = analysisResultsPSS(block,Eye,xyCenter,threshold_radius,numberoftrials);
end

correct = correct';
cd('E:\Analysis\PSS2\participantData');
save(['correct_', num2str(participant),'.mat'],'correct');

end