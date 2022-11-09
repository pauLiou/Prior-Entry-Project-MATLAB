function createOutputFile( exp, output )
%CREATEOUTPUTFILE Create an excel file with the output data

% Select folder for saving output
directory = [pwd '\participantData'];

% Saving the values saved in exp that describe the participant
titles = cell(1, 7);
values = cell(1, 7);
titles{1,1} = 'VPN';
values{1,1} = exp.VPN;
titles{1,2} = 'Age';
values{1,2} = exp.age;
titles{1,3} = 'Gender (f or m)';
values{1,3} = exp.gender;
titles{1,4} = 'Frame Rate';
values{1,4} = exp.ifi;
titles{1,5} = 'Display Resolution x';
values{1,5} = exp.res(1);
titles{1,6} = 'Display Resolution y';
values{1,6} = exp.res(2);
titles{1,7} = 'Fixpoint X';
values{1,7} = exp.fixpointX;

% Write in excel file with specified worksheet
xlswrite([directory '\' exp.VPN], titles, exp.VPN,'A1');
xlswrite([directory '\' exp.VPN], values, exp.VPN,'A2');

% Saving the Calibration data in specified worksheet
% For the eyetracker
titles = cell(1, 9);
titles{1,1} = 'Trial';
titles{2,1} = 'Block';
titles{3,1} = 'Standard deviation LX';
titles{4,1} = 'Standard deviation LY';
titles{5,1} = 'Standard deviation RX';
titles{6,1} = 'Standard deviation RY';
titles{7,1} = 'Sample rate';
titles{8,1} = 'Device';
titles{9,1} = 'Reason';

% Write in excel file with specified worksheet
xlswrite([directory '\' exp.VPN], titles, 'EyeTracker Calibration', 'A1');
xlswrite([directory '\' exp.VPN], struct2cell(output.eyeCalibration), 'EyeTracker Calibration', 'B1');

        % output.responses - further divided into 15 variables:
    % responses=[1.Position movementTarget, 2.Position first probe, 3.
    % Position second probe, 4. key answer participant, 5. response time (in
    % sec), 6. time to first probe 7. time to second probe 7. block,
    % 8.trial 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Column description for excel output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

titles = cell(1,19);
titles{1,1} = 'Block';
titles{1,2} = 'Trial';
titles{1,3} = 'Reaction Time (RT)';
titles{1,4} = 'Reponse Key (1=left,2=right,3=up,4=down';
titles{1,5} = 'Accuracy (1 = correct, 0 = incorrect)';
titles{1,6} = 'Arrow cue pointing location';
titles{1,7} = 'First Probe Location';
titles{1,8} = '';
titles{1,9} = 'Second Probe Location';
titles{1,10} = 'Beginning trial jitter';
titles{1,11} = 'length of fixation';
titles{1,12} = 'length of arrow cue';
titles{1,13} = 'time after GO sound before probe appears';
titles{1,14} = 'SOA';
titles{1,15} = 'programmed time after GO';
titles{1,16} = 'length of arrow cue jitter';
titles{1,17} = 'fixation';
titles{1,18} = 'programmed SOA';
titles{1,19} = 'trial length up to (but not including) probe';

% Write in excel file with specified worksheet
xlswrite([directory '\' exp.VPN], titles, exp.VPN,'A4');
xlswrite([directory '\' exp.VPN], output.responses, exp.VPN,'A5');

end

