function alltargetLoc = targetsOnHalfCircle(circleRadius, xCenter, yCenter,...
    imgHeigth, imgWidth, numStimuli, positionChoices)
% Definition of the half circle for the targets
if numStimuli == 4
    % Defining 7 symmetric locations on the circle (central point respectively)
    % for stimuli presentation; starting clockwise at 9 o'clock (usual clock)
    
    % 7 Angles starting from pi
    %t = pi:-pi/3:0;
    
    t = flip(linspace(-0.25*pi,pi+(pi*0.25),4));% the 4 locations starting from the bottom left 

else
    % Defining 9 locations
    t = 7/6*pi:-pi/6:-pi/6;
end
% Calculate Coordinates for each angle 
x = cos(t) * circleRadius;
% Change sign of y coordinate to correlate to orientation
y = -sin(t) * circleRadius;

% Move the circle center to the fixation point (via addition)
x = x+xCenter;
y = y+yCenter;

% Create empty cell array for target locations
alltargetLoc = cell(numStimuli,1);

% Draw stimuli to backbuffer
b = 1;
for a = 1:length(x)
    % Save locations for stimuli in matrix/array
    if ~isempty(positionChoices(positionChoices == a))
        targetLoc = [x(a)-imgWidth/2,y(a)-imgHeigth/2,x(a)+imgWidth/2,y(a)+imgHeigth/2];
        alltargetLoc{b,1} = targetLoc;
        b = b + 1;
    end
end

end