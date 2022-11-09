function saccadeOnset = saccadeDetector(output,exp)
% Script to detect the start of the trial for coordinate data and then find
% the saccade point and extract the saccade speed

addpath('D:\new_experiment');

for q = 1:max(output.responses(:,1))
    data = output.responses((output.responses(:,1) == q),:);
    dataStream = data(:,20);
    cd('D:\new_experiment');
    load([pwd '\participantData\coords_' num2str(exp.VPN) '_' num2str(q) '.mat']); % load the exact coords file that has been saved
    coords = coords(any(coords,2),:);
    coords = coords(2:end,:);
    
    idx = zeros(length(exp.stimuli_time),1); % pre-assign to save computation time
    
    % find the corresponding points that trials begin using dataStream from the experiment code
    for i = 1:length(dataStream)
        a = coords(:,5)';
        n = dataStream(i);
        
        dist = abs (a - n);
        minDist = min (dist);
        idx(i) = find (dist == minDist);
    end
    
    clear a n dist minDist i
    
    % loop that extracts the velocity and acceleration of each trial, returns
    % onsetCoords of each trial, onsetRow of each trial, and the exact time of
    % each saccade in each trial
    for i = 1:length(exp.stimuli_time) % for the number of trials
        if i == length(idx)
            trial{i} = coords(idx(i):length(coords),:);
        else
            trial{i} = coords(idx(i):idx(i+1),:); % within that current trial
        end
        vel.coords(:,1) = trial{i}(:,3);
        vel.coords(:,2) = trial{i}(:,4);
        vel.coords(end+1,:) = NaN;
        
        % extract the time values of each row
        vel.time = trial{i}(:,5);
        
        % find the true distance between the coordinate values
        for j = 1:length(vel.coords)-1
            if ~isnan(vel.coords((j+1),1))
                vel.dist(j+1,1) = pdist([vel.coords(j,1:2);vel.coords(j+1,1:2)],'euclidean');
            end
        end
        
        % turn these time values into their respective difference between rows (all
        % should be roughly 16.5ms)
        sacc.timeGradient = gradient(vel.time);
        
        % quick check to make sure recording sequencing is actually sampling at
        % 60hz
        if mean(sacc.timeGradient) > 0.02 || mean(sacc.timeGradient) < 0.014
            disp('error with time gradient');
        end
        % calculate velocity
        sacc.velocity = vel.dist./sacc.timeGradient;
        
        % should also calculate the velocity gradient
        sacc.velGradient = gradient(sacc.velocity);
        
        % now calculate the acceleration
        sacc.acceleration = (sacc.velocity./sacc.timeGradient);
        
        timeVelAcc = [sacc.timeGradient,sacc.velocity,sacc.acceleration];
        
        velocityMax = 35*60; % literature says under 35 degrees /s is considered an endpoint of saccade but
        % we have a 60hz eyetracker so this needs to be accounted for
        accelerationMax = 9500*sqrt(60); % literature also says under 9500 degrees /s squared is the endpoint
        % for acceleration so we need to account for the 60hz eyetracker
        % finding the point at which the velocity and acceleration fall below the
        % threshold - this is considered the saccade end point
        
        % first we need to skip the fixation period for this search because
        % sometimes people's fixation returns slightly late. So better to wait
        % until after each fixation to find the correct index
        skipFixation = trial{i}(1,5) + sum(data(i,10:12));
        % takes the beginning of the trial and adds the time of fixation to it
        [minValue,closestIndex] = min(abs(bsxfun(@minus,trial{i}(:,5)',skipFixation')));
        % finds the index in the trial that this occurs at (closestIndex) which
        % will be used as the first number of the for-loop below
        
        
        
        for k = closestIndex:length(timeVelAcc)
            if timeVelAcc(k,2) > velocityMax & timeVelAcc(k,3) > accelerationMax
                onsetCoords{i} = trial{i}(k,3:4);
                onsetRow{i} = k;
                onsetTime{i} = vel.time(k);
                break
              
            else
                onsetCoords{i} = trial{i}(closestIndex,3:4);
                onsetRow{i} = closestIndex;
                onsetTime{i} = vel.time(closestIndex);
            end
        end
        clear vel sacc timeVelAcc minValue closestIndex skipFixation
    end
    
    %clear trial velocityMax onsetRow onsetCoords onsetTime accelerationMax i j k idx sacc vel
    
    % Now we need to figure out the trial timing of each saccade in relation to
    % the arrow cue and GO signal in order to develop our averaging probe
    % appearance function
    % the following cues make up the whole trial time = eyejitter fixation cueTime Gosignal SOAms response_time
    
    for i = 1:length(trial)
        
        trialLengthResponse = sum(data(i,10:14)) + data(i,3);
        % whole trial length including response
        
        trialLength = sum(data(i,10:14));
        % whole trial length not including response
        
        GOsignal = trial{i}(1,5) + sum(data(i,10:14));
        % trial length up until GO signal appears
        
        [minValue,closestIndex(i)] = min(abs(bsxfun(@minus,trial{i}(:,5)',GOsignal')));
        % find the closest index that matches the GO signal time in each trial
        
        saccadeOnset{q}(i) = trial{i}(onsetRow{i},5) - trial{i}(closestIndex(i),5);
        % output the difference between GO signal and saccade onset as
        % saccade speed
    end
    
    clear trial onsetRow onsetTime onsetCoords trialLength trialLengthResponse GOsignal data
    
end
    
end
    
    
    


