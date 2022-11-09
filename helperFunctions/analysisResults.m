function [results,currBlock,trial] = analysisResults(block,Eye,allTargetX,threshold_radius)
% This function extracts a results table for the experiment, inside this
% results table is the following information:
% Saccade = time that saccade happened in trial
% GOsignal = time that the GO signal occured in trial
% Diff = time difference between saccade and GO signal
% GOsignalRow = the index of the row that the GO signal occured in trial
%           (requires extracting the trial as it begins the trial at position 1)
% saccadeRow = the index of the row the saccade occured in trial
% saccadeCoords = the saccade coordinates of that trial
% saccadeCoordsRow = the index of the row the coordinates are taken from

for j = 1:length(block)
    currBlock = Eye(Eye.Blocks == j,:); % create the current block table for the eyetracker data
    for i = 1:72%max(currBlock.Trial)
        trial = currBlock(currBlock.Trial == i,:); % take an individual trial from the data
        GO = trial.RecordingTimems(1,1) + (sum(block{j}(i,10:13))-(block{j}(i,15)-0.02))*1000; % calculate the recorded time for the GO signal
        a = trial.NewIndex == 1; % generate a vector of the points that saccades happened
        [~,b] = min(abs(bsxfun(@minus,trial.RecordingTimems,GO))); % locate the closest time/row to the GO signal
        
        c = find(cumsum(a) == 1 & a); % row that the saccade happens
        
        Saccade = trial.RecordingTimems(c,1); % saccade time for current trial
        
        
        % finding the saccade that occurs AFTER the GO signal
        breakpoint = 0;
        x = trial.NewIndex;
        while c < b
            x(c) = 0;
            c = find(cumsum(x) == 1 & x);
            if isempty(c)
                c = NaN;
                Saccade = NaN;
                break
            end
            if ~isnan(c)
                Saccade = trial.RecordingTimems(c,1);
                breakpoint = breakpoint +1;
            end
            if breakpoint == 12
                Saccade = NaN;
                break
            end
        end
        
        results{j}.trialBegin(i) = trial.RecordingTimems(1,1);
        results{j}.GOFromZero(i) = (GO - trial.RecordingTimems(1,1))/1000;
        if isnan(Saccade)
            results{j}.saccadeFromZero(i) = NaN;
        elseif isempty(Saccade)
            results{j}.saccadeFromZero(i) = NaN;
        else
            results{j}.saccadeFromZero(i) = (Saccade - trial.RecordingTimems(1,1))/1000;
        end
        % Create a struct with the results for output
        if isempty(Saccade)
            results{j}.Saccade(i) = NaN;
            results{j}.GOsignal(i) = GO;
            results{j}.Diff(i) = NaN;
        else
            results{j}.Saccade(i) = Saccade;
            results{j}.GOsignal(i) = GO/10000000;
            results{j}.Diff(i) = (Saccade-GO)/1000;% saccade time for trial
        end
        % GO signal time for trial
        % difference time between saccade and GO signal
        results{j}.GOsignalRow(i) = b;% GO signal row
        if isempty(c)
            results{j}.saccadeRow(i) = NaN;
        else
            results{j}.saccadeRow(i) = c;% saccade row
        end
        
        % use the furthestAway script to locate the saccade end point,
        % time of endpoint and row of endpoint
        if ~isnan(results{j}.saccadeRow(i)) && results{j}.saccadeRow(i) < size(trial,1)-10
            [results{j}.endPointSaccadeCoords{i},results{j}.endPointSaccadeRow{i}...
                results{j}.endPointSaccadeTime{i}] = furthestAway(results{j}.saccadeRow(i),trial);
        
            % obtain the saccade end point center between eyes
            [coordsX,coordsY] = RectCenter(results{j}.endPointSaccadeCoords{i});
        
            % check over the 4 target locations to see if the end point of
            % saccade fell between one of the 4 cue locations
            for q = 1:length(allTargetX)
               if isInCircle(coordsX, coordsY,[allTargetX{q}(1) allTargetX{q}(2)],threshold_radius)
                   saccadeR = q;
                   break
               else
                    saccadeR = NaN;
               end
            end
        


            % check whether this matches the cued location in the experiment
            % simply records a 1 if the correct location was attended
            if saccadeR == block{j}(i,6);
                results{j}.correct(i,1) = 1;
            else
                for t = c:size(trial)
                    % if the results saccade of this trial exists  but isnt at the endpoint
                    % then find the coordinates of this trial by looping through the
                    % remaining trials until finding/not finding trials that
                    % match the expected location
                    
                    % the four coordinates of the eye saccade at the point
                    % of saccade (1 row after the acknowledgement of the saccade)
                    saccadeCoords = [trial.PointofRegardLeftXpx(t),...
                        trial.PointofRegardLeftYpx(t),...
                        trial.PointofRegardRightXpx(t),...
                        trial.PointofRegardRightYpx(t)];
                    
                    % check if any of the locations in the trial match the
                    % target destination
                    [coordsX,coordsY] = RectCenter(saccadeCoords);
                    for q = 1:length(allTargetX)
                        if isInCircle(coordsX, coordsY,[allTargetX{q}(1) allTargetX{q}(2)],threshold_radius)
                            saccadeR = q;
                            break
                        else
                            saccadeR = NaN;
                        end
                    end
                    
                    if ~isnan(saccadeR)
                        results{j}.endPointSaccadeCoords{i} = saccadeCoords;
                        results{j}.endPointSaccadeRow{i} = t;
                        results{j}.endPointSaccadeTime{i} = trial.RecordingTimems(t);
                        results{j}.correct(i,1) = 1;
                        break
                    else
                        results{j}.endPointSaccadeCoords{i} = NaN;
                        results{j}.endPointSaccadeRow{i} = NaN;
                        results{j}.endPointSaccadeTime{i} = NaN;
                        results{j}.correct(i,1) = 0;
                    end
                end
            end
            
        % record the latency difference between saccade onset and offset
        % (just recorded for now as number of rows - indicating a rowNumber*60hz
        % frame measurement for exact time
        results{j}.saccadeLatency{i} = results{j}.endPointSaccadeRow{i} - results{j}.saccadeRow(i);
        else
            results{j}.endPointSaccadeCoords{i} = NaN;
            results{j}.endPointSaccadeRow{i} = NaN;
            results{j}.endPointSaccadeTime{i} = NaN;
            results{j}.correct(i,1) = 0;
        end

    end
    
end  
   
        
        
        





