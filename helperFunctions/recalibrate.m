
% Recalibrate the eyeTracker
inputValid = false;
recalEye = false;
recalMot = false;

while(~inputValid)
    msg = sprintf('Do you want to recalibrate the EyeTracker (y) or not (n)');
    str = inputdlg(msg);
    if (str{1} == 'y')
        recalEye = true;
        inputValid = true;
    elseif (str{1} == 'n')
        inputValid = true;
    end
end


if(recalEye)
    acceptedCalibration = false;
    
    if(eyetracker && recalEye)
        while(~acceptedCalibration)
            CalibrateiViewpaul;
            
            disp('Calibration complete. If the accuracy is sufficient press y. If not, press any key to recalibrate.');
            [~, keyCode] = KbWait;
            if(keyCode(accept_key) == 1)
                acceptedCalibration = true;
            end
        end
        
        % Save calibration data
        eyeCal.trial = output.currenttrial;
        eyeCal.block = output.currentblock;
        acc = libstruct('AccuracyStruct', pAccuracyData);
        eyeCal.lx = acc.deviationLX;
        eyeCal.ly = acc.deviationLY;
        eyeCal.rx = acc.deviationRX;
        eyeCal.ry = acc.deviationRY;
        info = libstruct('SystemInfoStruct', pSystemInfoData);
        eyeCal.sampleRate = info.samplerate;
        eyeCal.device = info.iV_ETDevice;
        eyeCal.reason = 'Pause';
        
        output.eyeCalibration = [output.eyeCalibration; eyeCal];
        
    end
    
else
    eyeCal = output.eyeCalibration(end);
end

