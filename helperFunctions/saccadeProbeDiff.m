function [stim,timeDiff] = saccadeProbeDiff(saccadeOnset,output,stimTime,probeMatrix,block)
% Script that extracts the time couse for the current block with the
% saccade time taken into account vs the target onset. It tries to adjust
% the target onset so that the window between saccade and 2nd probe
% appearing is between 60ms and 100ms
% also extracts the (timeDiff) time from GO signal to saccade of every
% trial (adjusted for the saccadic suppression window ~30ms)

output.responses = output.responses(any(output.responses,2),:);

data = output.responses((output.responses(:,22) ~= 1),:); % remove synchronous trials
data = data(data(:,1) == block-1,:);
SOA = round(data(:,14),3); % get the probe length times
saccade = cell2mat(saccadeOnset(block-1))';% get the saccade onset times
saccade = saccade((data(:,22) ~= 1),:); 
GOsignalLength = data(:,15); % get the length of the GO signal (E.g. length of time until probe onset)


maxTime = SOA + GOsignalLength; % the length of time from the onset of GO signal, until the 2nd probe has appeared

timeDiff = (saccade-maxTime); % counting backwards to the point that the saccade occured - therefore this number  
% is the difference between the end of the probe and the saccade onset.

%timeDiff = timeDiff-0.03; % take away 30 milliseconds to account for saccadic supression

% depending on what we want to achieve, time-wise, this can be adjusted.
count = 0;
if trimmean(timeDiff,10) > 0.03 & trimmean(timeDiff,10) < 0.4 % if the mean time difference is already greater than 60ms/less than 0.4sec, continue as always
    stim = stimTime(:,block);
else
    if mean(timeDiff) < 0.03
        while mean(timeDiff) < 0.03 % if the mean time is less than 60ms, keep adding to it until the average exceeds 60ms
            timeDiff = timeDiff + 0.01;
            count = count+1; % make a note of this calc
        end
        stim = stimTime(:,block)-(count/100);
    elseif trimmean(timeDiff,10) > 0.4;
        while trimmean(timeDiff,10) > 0.4
            timeDiff = timeDiff - 0.01;
            count = count+1;
        end
        stim = stimTime(:,block)+(count/100); % add the amount onto the stimulus time for the next block
        if stim < 0
            stim = 0;
        end
    end
end

timeDiff = trimmean(timeDiff,10);

