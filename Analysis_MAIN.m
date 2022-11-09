% Analysis script for PTA - Main conversion
%clear all
 
% create a variable (accurateSaccade) that stores the accuracy of each trial - in that the
% saccade lands in the target during the endpoint of the saccade and that
% this endpoint is within 200ms of the saccade onset. 
for i = 1:length(block)
    for j = 1:length(results{i}.saccadeRow)
        if isempty(results{i}.endPointSaccadeRow{j})
            x{i}(j) = NaN;
        else
            x{i}(j) = results{i}.endPointSaccadeRow{j} - results{i}.saccadeRow(j);
        end

        if ~isnan(x{i}(j)) && x{i}(j) < 12 && results{i}.correct(j) == 1;
            y{i}(j) = 1;
        else
            y{i}(j) = 0;
        end
    end
end
accurateSaccade = y;
% Create a analysis output file

% output timings:
% 11) = fixation
% 12) = cueTime
% 13) = Gosignal onset
% 14) = targetOnset
% 15) = full_trial
%         
% 16) = jitterCue
% 17) = jitterCue
% 18) = stim
% 19) = round(probeDisplayTime

% the full trial length (15) is from the exact onset of the trial until the
% moment the GO signal appears - after this point there are a few moments
% of interest.
for i = 1:length(block)
    analysis{i} = block{i};
    x = analysis{i};
    analysis{i} = x(:,15); % full trial length up to GO signal in ms
    x = results{i}.Diff/1000;x = x';
    analysis{i}(:,2) = x; % exact point saccade occurs after GO signal
    analysis{i}(:,3) = results{i}.GOFromZero'+ block{i}(:,11)*1000; % exact moment probe appears
    analysis{i}(:,4) = results{i}.saccadeFromZero' - analysis{i}(:,3); % the probe appearing vs saccade timing
    analysis{i}(:,5) = block{i}(:,7); % trial accuracy
    analysis{i}(:,6) = block{i}(:,3); % trial reaction time
    analysis{i}(:,7) = block{i}(:,2); % trial number
    analysis{i}(:,8) = block{i}(:,4); % left or right first
    analysis{i}(:,9) = accurateSaccade{i}'; % whether or not the saccade was accurate
    analysis{i}(:,10) = block{i}(:,11); % the time between GO signal and Probe
    analysis{i}(:,11) = analysis{i}(:,2) - block{i}(:,12); % the difference between probe DISAPPEARING and saccade ARRIVING
    analysis{i}(:,12) = block{i}(:,10); % length of arrow cue (ms)
 
end

% clear out the trials where the saccade coords didn't match the required
% location within 0.2s
for i = 1:length(block)
    analysis{i} = analysis{i}((analysis{i}(:,9) == 1),:);
end

clear x i y j


% remove rows with NaN
% add in functionality to save which trial has been removed - meaning
% analysis array table needs a vector showing trial number
for i = 1:length(block)
    analysis{i}(any(isnan(analysis{i}), 2), :) = [];
end

% remove outlier trials with numbers too large (experiment lag etc) for
% Saccade after the GO signal
for i = 1:length(block)
    m = mean(analysis{i}(:,2));% calculate standard deviation
    m2 = mean(analysis{i}(:,4));
    s = std(analysis{i}(:,2)); % calculate standard deviation
    s2 = std(analysis{i}(:,4));
    analysis{i} = analysis{i}((analysis{i}(:,2) < m+s*3),:);
    analysis{i} = analysis{i}((analysis{i}(:,2) > m-s*3),:);
    analysis{i} = analysis{i}((analysis{i}(:,4) < m2+s2*2),:);
    analysis{i} = analysis{i}((analysis{i}(:,4) > m2-s2*2),:);
end
clear s m s2 m2

% remove trials where saccadic supression would occur (within a
% 40ms window of the probe)
for i = 1:length(block)
    g1 = analysis{i}((analysis{i}(:,4) > 0.03),:);
    analysis{i} = g1;
    analysis{i} = sortrows(analysis{i},7);
end

% remove trials where saccade and probe occur within the same window
for i = 1:length(block)
    analysis{i} = analysis{i}((analysis{i}(:,11) > 0.03),:);
end

% turn into tables incase it gets confusing with no descriptions
for i = 1:length(block)
    x = analysis{i};
    analysisTAB{1,i} = array2table(x,'VariableNames',{'TimeUntilGO' 'SaccadeAfterGO' 'ProbeAppears'...
        'ProbeSaccadeDifference','Accuracy','RT','Trial','CueHelp','SaccadeAccuracy','GOSignalLength','NewDiff','JitterCue'});
end
clear x i

% create a full table of all trials
analysisFULLTAB = cat(1,analysisTAB{:});
analysisFULL = cat(1,analysis{:});

for i = 1:length(output)
    
end
for i = 1:length(block)
    for j = 1:length(block{i})
        block{i}(j,22) = isequal((block{i}(j,6)),block{i}(j,21));
    end
end
        

% remove these trials from the behavioural data
for i = 1:length(block)
    x = block{i};
    y = analysis{i};
    diff = setdiff(x(:,2),y(:,7));
    trialsRemoved{i} = x((~ismember(x(:,2),diff)),:);
end
trialsRemovedFULL = cat(1,trialsRemoved{:});
clear x y diff i


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Separating Cued from Uncued Targets and doing analysis again
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cue.Simultaneous = trialsRemovedFULL((trialsRemovedFULL(:,17) == 1),:);
cue.Help = trialsRemovedFULL((trialsRemovedFULL(:,23) == 1),:); % all trials where the cue pointed at the probe
cue.NoHelp = trialsRemovedFULL((trialsRemovedFULL(:,23) == 0 & trialsRemovedFULL(:,24) == 0),:); % all trials where the cue pointed away from the probe
cue.Diff = [sum(cue.Help(:,7)) sum(cue.NoHelp(:,7))]; % difference between accuracy of cueHelp and cueNoHelp
cue.Diffper = round([cue.Diff(1)*100/length(cue.Help) cue.Diff(2)*100/length(cue.NoHelp)]); % difference as a percentage
cue.HighInterference = trialsRemovedFULL((trialsRemovedFULL(:,24) == 1),:);
cue.LowInterference = trialsRemovedFULL((trialsRemovedFULL(:,23) == 1),:);
cue.InterferenceDiff = [sum(cue.LowInterference(:,7)) sum(cue.HighInterference(:,7))];
cue.InterferenceDiffpre = round([cue.InterferenceDiff(1)*100/length(cue.LowInterference) cue.InterferenceDiff(2)*100/length(cue.HighInterference)]);

