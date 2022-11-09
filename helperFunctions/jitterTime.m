function jitterTime = jitterTime(ifi,numberoftrials,numberofblocks)


closest = round(0.05/ifi);

% jitter can be altered here creates the variable jitterTime may wish to
% adjust the amount of jitter windows depending on the refresh rate
lower = round(0.2/ifi);
lower = lower*ifi;
jitter = [-lower:(ifi*closest):lower];

% avoid any numbers that are too close to zero or less than a frame
for i = 1:length(jitter)
    if jitter(i) > 0.007 || jitter(i) < -0.007
        jitterTime(i) = jitter(i);
    else jitterTime(i) = 0;
    end
end

jitterTime = jitterTime(jitterTime ~= 0);
exp.jitterPrep = randi([1 length(jitterTime)],numberoftrials,numberofblocks);
jitterTimeifi = jitterTime/ifi; % turn jitter times into frames
x = round(1/ifi); % find number closest to 1 in frames

x = x*ifi;

end