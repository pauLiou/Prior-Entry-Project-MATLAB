function [endPointCoords endPointRow endPointTime] = furthestAway(coords,trial)
% function that extracts the distance from fixation, then extrapolates the
% velocity & acceleration of saccade using time. It then generates three
% variables, the end point coordinates based on literature suggesting that
% 30°/s velocity and 9500°/s acceleration are the upper thresholds for an
% end point. It also generates the row this occured on (from the whole
% trial) and the Time it happened (from the whole database).

vel.trial = trial(coords:end,:);

% transform the 4 coordinates (XY left and XY right) onto an array
vel.coordsFull = table2array([vel.trial(:,15),vel.trial(:,16),vel.trial(:,17),vel.trial(:,18)]);

% average between the two eye coordinates
vel.coords(:,1) = (vel.coordsFull(:,1) + vel.coordsFull(:,3)) / 2;
vel.coords(:,2) = (vel.coordsFull(:,2) + vel.coordsFull(:,4)) / 2;
vel.coords(end+1,:) = NaN;

% extract the time values of each row
vel.time = table2array(vel.trial(:,1));

% find the true distance between the coordinate values
for i = 1:length(vel.coords)-1
    if ~isnan(vel.coords((i+1),1))
        vel.dist(i+1,1) = pdist([vel.coords(i,1:2);vel.coords(i+1,1:2)],'euclidean');
    end
end

% turn these time values into their respective difference between rows (all
% should be roughly 16.5ms)
endPoint.timeGradient = gradient(vel.time)/1000;

% calculate velocity
endPoint.velocity = vel.dist./endPoint.timeGradient;

% should also calculate the velocity gradient
endPoint.velGradient = gradient(endPoint.velocity);


% now calculate the acceleration
endPoint.acceleration = (endPoint.velocity./endPoint.timeGradient);

timeVelAcc = [endPoint.timeGradient,endPoint.velocity,endPoint.acceleration];

velocityMax = 35*60; % literature says under 35 degrees /s is considered an endpoint of saccade but
% we have a 60hz eyetracker so this needs to be accounted for
accelerationMax = 9500*sqrt(60); % literature also says under 9500 degrees /s squared is the endpoint
% for acceleration so we need to account for the 60hz eyetracker

% finding the point at which the velocity and acceleration fall below the
% threshold - this is considered the saccade end point 
for i = 2:length(timeVelAcc)
    if timeVelAcc(i,2) < velocityMax & timeVelAcc(i,3) < accelerationMax
        endPointCoords = vel.coordsFull(i,:);
        endPointRow = i+coords;
        endPointTime = vel.time(i);
        break       
    end
end
        