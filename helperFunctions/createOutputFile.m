function createOutputFile( exp, output )
%CREATEOUTPUTFILE Create an excel file with the output data

% Select folder for saving output
if(exp.trial)
    directory = [pwd '\participantData_trial'];
else
    directory = [pwd '\participantData'];
end

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
titles = cell(1, 8);
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

titles = cell(1,11);
titles{1,1} = 'Position movement target (1 - 4/9)';
titles{1,2} = 'Position first Probe';
titles{1,3} = 'Position second Probe';
titles{1,4} = 'First side (1 = left, 2 = right)';
titles{1,5} = 'Answer participant (1 = left, 2 = right, 3 = faulty)';
titles{1,6} = 'Response Time (sec)';
titles{1,7} = 'Time to Movement cue (in frames)';
titles{1,8} = 'Time to first Probe (in frames)';
titles{1,9} = 'Time to second Probe (in frames)';
titles{1,10} = 'Block';
titles{1,11} = 'Trial';

% Write in excel file with specified worksheet
xlswrite([directory '\' exp.VPN], titles, exp.VPN,'A4');
xlswrite([directory '\' exp.VPN], output.responses, exp.VPN,'A5');

end

