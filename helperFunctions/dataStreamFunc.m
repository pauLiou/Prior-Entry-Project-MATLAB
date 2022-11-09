%%%
% Function that launches in 2nd version of matlab and records the online
% coordinates of the eye-tracker data
dir = (['D:\new_experiment\participantData']);

load('test.mat')

count = 1

while ~exist([dir,'\participant_' num2str(exp.VPN)],2)
    
    ret_sam = iView.iV_GetSample(pSampleData);
    if (ret_sam == 1)
        Smp = libstruct('SampleStruct', pSampleData);
        coords(count) =	[int2str(count) '  ' int2str(Smp.timestamp) ' - GazeX: ' int2str(Smp.leftEye.gazeX) ' - GazeY: ' int2str(Smp.leftEye.gazeY)];
    else
        coords(count) = 'Unable to get gaze samples';
    end
    pause(0.0167);
    count = count+1;
    
end

save(([dir '\coords_' num2str(exp.VPN)]),'coords');
        