%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Experiment v2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO List
%
% #1 Figure out how to utilise the new trial matrix to switch up the boxs
% for the 4 different box conditions


addpath('C:/toolbox/')
addpath('C:/toolbox/Psychtoolbox');
% Clear the workspace and the screen
sca;
close all;
clearvars;
RestrictKeysForKbCheck([]);
% Default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
% Add helper functions folder to the workspace
addpath('helperFunctions/');

% Add iView functions folder (all functions related to the Eye Tracker) to
% the workspace
addpath('iViewFunctions/');

% Add the experiment setup functions
addpath('experimentSetup/');

% Eyetracker attached or not
eyetracker = true;

probePos = 2;

% Check whether the experiment has been restarted
while(~exist('loadVars', 'var'))
    prompt = {'Do you want to start a new trial (n) or load configurations from the workspace (w)?','Participant Number?: '};
    dlg_title = 'User Input';
    num_lines = 1;
    str = inputdlg(prompt,dlg_title,num_lines);
    %str = inputdlg(sprintf('Do you want to start a new trial (n)\nor load configurations from the workspace (w)?','Participant number?'));
    loadVPN = str{2};
    if (str{1} == 'n')
        loadVars = false;
    elseif (str{1} == 'w')
        loadVars = true;
    end
end


fixationTime = 1.0; % Length of the fixation (non-jittered at this stage)
cueDisplayTime = 1; % Length of the cue display (non-jittered at this stage)
probeDisplayTime = 0.1; % Length of time (in secs) that probe is shown

% User input for all experiment variables
if(loadVars)
    load([pwd, '\participantData\participant_' num2str(loadVPN)]);
    probeMatrix = unique(sort(output.responses((output.responses(:,1) == output.currentblock-1),15))); 
    load(['D:\new_experiment\PSS\participantData\participant_' num2str(exp.VPN) '.mat'],'threshold')
    timeSOA = [0.00,round(threshold,3),0.08]';
    numberofblocks = 12; % How many total blocks 12 
    numberoftrials = 72; % How many total trials 72
else
    exp = userInput();
    if exp.practice == 'n'
        numberofblocks = 12; % How many total blocks 12 
        numberoftrials = 72; % How many total trials 72
    else
        numberofblocks = 1; % How many total blocks
        numberoftrials = 72; % How many total trials
        eyetracker = false;
    end
    probeMatrix = [0.05:0.005:0.08];
   
    % add the threshold from the PSS experiment 1 if it exists
    if exist(['D:\new_experiment\PSS\participantData\participant_' num2str(exp.VPN) '.mat'])
        load(['D:\new_experiment\PSS\participantData\participant_' num2str(exp.VPN) '.mat'],'threshold')
        timeSOA = [0.00,round(threshold,3),0.08]';
        clear output
    else
        timeSOA = [0.0,0.025,0.08]';
    end
    threshold_radius = 2; % Set radius for healthy participants (visual angle)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
end


% The number of "8" symbols that appear
positionChoices = [1 2 3 4];
numStimuli = 4;
halfStimuli = numStimuli/2;

% Load the information important for the keyboard inputs
 keyboardInfo;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Load participant specific data, includes the trial sequence and requires
% participants input
participantInfo;

% Load the iViewX API library and connect to the server (in separate File)
if(eyetracker)
    InitAndConnectiViewXAPI;
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Create a subfolder for eye tracker data if turned on
if(eyetracker)
    eyeTrackerFolder = [ pwd '\eyeTrackerData\Participant_' num2str(exp.VPN)];
    mkdir(eyeTrackerFolder);
end

% Run the eye tracker calibration if it is connected
calibrationInfo;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
workspace; 
% Runs the helper file that gives the screen information directly
screenInfo;
cd('D:\new_experiment');

% Runs the helper file that sets up the audio beep for GO signal
audioInfo;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Adding some counters to check it is looping properly, they should
% increase with every iteration
trialcounter = 0;
blockcounter = 0;
boxcounter = 0;
saccadeAccuracy = 0; 
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

for block = output.currentblock:numberofblocks
    trialcounter = 1;
    boxcounter = 1;
    
    % If this is the first trial we present the start screens and instructions
    % and wait for key-presses
    if block == 1
        DrawFormattedText(w, '\n Welcome to the Experiment',...
            'center', 'center', white);
        Screen('Flip',w);
        KbStrokeWait;
        if exp.practice == 'y'
            Screen('DrawTexture',w,instructionStimulus);
            Screen('Flip',w);
            KbStrokeWait;
        end
        DrawFormattedText(w, '\n Press Any Key To Begin...',...
            'center', 'center', white);
        Screen('Flip',w);
        KbStrokeWait;
        
    end
    
    if block == (numberofblocks/2)+1;
       Screen('Close', w);
       % Option to ReCalibrate the Eye and the Motion Tracker
       recalibrate;
       screens = Screen('Screens');
       screenNumber = max(screens);
       openNewWindow;
    end
    
    Screen('TextSize',w, 24);
    blocktext = ['Block: [', num2str(block), '] Press Any Key to Begin...'];
    DrawFormattedText(w, blocktext,'center', 'center', white);
    Screen('Flip',w);
    KbStrokeWait;
        
    Screen('TextSize',w, 24);
    if mod(block,2) == 1
        blocktext = ['Block: [', num2str(block), ']\n Please select the target that appears FIRST'];
    else
        blocktext = ['Block: [', num2str(block), ']\n Please select the target that appears SECOND'];
    end
    DrawFormattedText(w, blocktext,'center', 'center', white);
    Screen('Flip',w);
    KbStrokeWait;

    % Start eyetracker recording for this block
    % Clear eyetracker buffer and start recording
    if(eyetracker)
        ret_clr = iView.iV_ClearRecordingBuffer();
        ret_str = iView.iV_StartRecording();
        
        if (ret_str ~= 1 || (ret_clr ~= 1 && ret_clr ~= 191))
            if(loadVars)
                disp('no new recording');
            else
                error('Recording could not be set up');
            end
        end
    end
    
    % launch 2nd matlab that collects the eye-tracking data online and then
    % closes afterwards creating the "coords" file in the participantData
    % folder
    
% 
%     if block == 1 && exp.practice == 'n'
%         if(~loadVars)
%             save('test');
%         end
%         if(eyetracker)
%             
%             !matlab -nosplash -r dataStreamFunc &
%             pause(8);
%         end
%     elseif exp.practice == 'n'
%         if(eyetracker)
%             saccadeBegin = saccadeDetector(output,exp);
%         end
%     end
    
    
    for trialnr = output.currenttrial:numberoftrials
              
        
        jitterCue = exp.jitterPrep(trialnr,block); % Minimum time participant must fixate
%         if block == 1
%             stim = exp.stimuli_time(trialnr,block); % How long the GO signal is displayed before probe
%         else
%             if trialnr == 1 && exp.practice == 'n' && eyetracker == 1
%                 try
%                     [exp.stimuli_time_adjusted(:,block),exp.timeDiff(:,block)] = saccadeProbeDiff(saccadeBegin,output,exp.stimuli_time,probeMatrix,block);
%                     saccadeAccuracy = saccadeAccuracy+1;
%                     fprintf('try \n');
%                 catch
%                     exp.stimuli_time_adjusted(trialnr,block) = exp.stimuli_time(trialnr,block);
%                     exp.timeDiff(:,block) = 0;
%                     saccadeAccuracy = saccadeAccuracy;
%                     fprintf('catch \n');
%                 end
%             end
%             if exp.practice == 'n' && eyetracker == 1
%                 stim = exp.stimuli_time_adjusted(trialnr,block);
%             end
%         end
        stim = exp.stimuli_time(trialnr,block);
        firstTarget = exp.bothProbe(trialnr, 1); % Location of first probe
        secondTarget = exp.bothProbe(trialnr, 2); % Location of second probe
        targets = [firstTarget,secondTarget];
        if exp.trialMatrix(trialnr,1) == 1
            movementTarget = firstTarget;
        elseif exp.trialMatrix(trialnr,1) == 2
            movementTarget = secondTarget;
        else
            idx = find(~ismember(positionChoices,exp.bothProbe(trialnr,:)));
            movementTarget = idx(randi(2));
        end

        duration = exp.timeSOA(trialnr);
        trialType = mod(block,2);
        Screen('TextSize',w, 30);
        
        if trialType == 1
            trialVersion = firstTargetTrial;
        else
            trialVersion = secondTargetTrial;
        end
        
        % trying to add the rectangles (switching between vertical and
        % horizontal) in a manner that isn't interfering with the other
        % condition types (perhaps every other 2)
        if mod(boxcounter,3) == 0 || mod(boxcounter,4) == 0
            rectangle = allRectsVert;
            rectOutput = 1; % Vertical
        else
            rectangle = allRects;
            rectOutput = 0; % Horizontal
        end
        
        if boxcounter == 4
            boxcounter = 0;
        end
        % Using a script to decompile which location is the first probe and
        % which location both probes appear at
       
        
        % While loop below determines that:
        % A: Participant is fixated for at least the length of the jitterCue.
        % B: Eyes are actually on the fixation cross for this time
        % C: Pre-stimulus adaptation of monitor refresh rate.
        fixatedEyes = false; % True if eyes are looking at fixation cross
        dur = false; % True if the fixation reaches the time threshold
        clockStart = true; % Start the fixation timer only when fixated and clockStart is true
        trial = 0;
        eye = tic;
        dataStream = GetSecs;
        
        % Send message to eyetracker for start of trial
        if(eyetracker)
        iView.iV_SendImageMessage(['Block:' num2str(block) '-Trial:' num2str(trialnr) '.jpg']);
        end
        test = tic; 
        startjitter = toc(eye);
        while(~fixatedEyes || ~dur)
            for i = 1:round(jitterCue/0.01) % For about 1 s,...
                [keyIsDown, ~, keyCode] = KbCheck();
                if(keyIsDown == 1 && keyCode(pause_key) == 1)
                    
                    % Render pause on the screen and wait for any key press to
                    % resume execution
                    DrawFormattedText(w,'Pause','center','center',textColor);
                    Screen('Flip',w);
                    KbPressWait;
                end
                
                if(~fixatedEyes)
                    startTime = tic;
                end
                if fixatedEyes == true && clockStart == true
                    trial = tic;
                end
                % This draws the fixation cross
                Screen('DrawLines', w, allCoords, lineWidthPix, textColor, [circleXCenter yCenter], 2);
                %Screen('FrameRect',w, allColors, rectangle, 6);
                for a = 1:numStimuli
                    Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1}, 0, 0);
                end
                DrawFormattedText(w, trialVersion,'center', yCenter * 0.25, white);
                if(eyetracker)
                    iView.iV_GetSample(pSampleData); % Get an eye tracker sample at this time
                    Smp = libstruct('SampleStruct', pSampleData);
                    gazeX = (Smp.leftEye.gazeX + Smp.rightEye.gazeX) / 2; % Average of both eyes X axis
                    gazeY = (Smp.leftEye.gazeY + Smp.rightEye.gazeY) / 2; % Average of both eyes Y axis
                    % Determines if these gaze coords are in the fixation area
                    fixatedEyes = isInCircle(gazeX, gazeY, [xCenter yCenter], threshold_radius);
                else
                    fixatedEyes = true;
                end
                
                if trial == 0
                    clockStart = true;
                else
                    clockStart = false;
                end
                
                if(fixatedEyes)
                    dur = toc(startTime) > jitterCue/2;
                end
                Screen('Flip',w);
                % Wait period to adapt monitor refresh rate
                myWait(0.01);
                
                
            end
        end
        fixation_while = toc(test);
        fixation = toc(trial);
        trial = tic;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 1: Draw the Movement Cue
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Draw 8 on target locations to backbuffer
        for i = 1:round(1/0.02) % loops for approx 500ms and additional is added after the loop in order to adapt refresh rate
            %Screen('FrameRect',w, allColors, rectangle, 6);
            for a = 1:numStimuli
                Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1},0,0);
            end
            DrawFormattedText(w, trialVersion,'center', yCenter * 0.25, white);
            % Draw cue for movementTarget to backbuffer and flip screen
            Screen('DrawTexture',w,arrowCue,[],[circleXCenter-12, yCenter-12,circleXCenter+12,yCenter+12],cueAngle(movementTarget,1),2,2);
            Screen('Flip', w);
            myWait(0.01);

        end
        myWait(jitterCue-(ifi*140)); % number found through pure trial and error and tested with the tic/tic down to 1ms accurate
        cueTime = toc(trial);
        trial = tic;
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 2: Draw the Go Signal
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Screen('FrameRect',w, allColors, rectangle, 6);
        for a = 1:numStimuli
            Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1}, 0, 0);
        end
        DrawFormattedText(w, trialVersion,'center', yCenter * 0.25, white);
        
        % The GO Signal (audio)
        Screen('DrawTexture',w,arrowCue,[],[circleXCenter-12, yCenter-12,circleXCenter+12,yCenter+12],cueAngle(movementTarget,1),2,2);
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
        Screen('Flip', w);
        myWait(stim-0.02);
        
        Gosignal = toc(trial);
        trial = tic;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 3v1: Simultaneous Probes appear
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if(exp.trialMatrix(trialnr,2)) == 1
            %Screen('FrameRect',w, allColors, rectangle, 6);
            Screen('DrawTexture',w,arrowCue,[],[circleXCenter-12, yCenter-12,circleXCenter+12,yCenter+12],cueAngle(movementTarget,1),2,2);
            for a = 1:numStimuli
                Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1}, 0, 0);
            end
            DrawFormattedText(w, trialVersion,'center', yCenter * 0.25, white);
            Screen('DrawTexture',w,probeStimulus,[],alltargetLoc{firstTarget,1}, 0, 0);
            Screen('DrawTexture',w,probeStimulus,[],alltargetLoc{secondTarget,1}, 0, 0);

            Screen('Flip',w);
            SOAms = toc(trial);
        else    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Stage 3v2: First probe appears
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Screen('FrameRect',w, allColors, rectangle, 6);

            % Draws the default stimuli except the first target probe
            Screen('DrawTexture',w,arrowCue,[],[circleXCenter-12, yCenter-12,circleXCenter+12,yCenter+12],cueAngle(movementTarget,1),2,2);
            for a = 1:numStimuli
                Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1}, 0, 0);
            end
            DrawFormattedText(w, trialVersion,'center', yCenter * 0.25, white);
            % Draws the probe target
            Screen('DrawTexture',w,probeStimulus,[],alltargetLoc{firstTarget,1}, 0, 0);
            Screen('Flip', w);
            myWait(duration-0.0022); % This is essential pay attention to if this is working
            
            

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Stage 4: Second probe appears
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Screen('FrameRect',w, allColors, rectangle, 6);


            for a = 1:numStimuli
                Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1}, 0, 0);
            end
            DrawFormattedText(w, trialVersion,'center', yCenter * 0.25, white);
            Screen('DrawTexture',w,arrowCue,[],[circleXCenter-12, yCenter-12,circleXCenter+12,yCenter+12],cueAngle(movementTarget,1),2,2);
            Screen('DrawTexture',w,probeStimulus,[],alltargetLoc{firstTarget,1}, 0, 0);
            Screen('DrawTexture',w,probeStimulus,[],alltargetLoc{secondTarget,1}, 0, 0);

            Screen('Flip',w);
            SOAms = toc(trial);
        end
          
         % Output response and RT
        workspace;
        probe_response = tic;
        
        if ismember(targets,vertical,'rows')
            RestrictKeysForKbCheck([upKey,downKey]);
        else
            RestrictKeysForKbCheck([leftKey,rightKey]);
        end
                   
            
        [secs,keyCode] = KbWait;
        response_time = toc(probe_response);
        
        RestrictKeysForKbCheck([]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Try to trim this down or put it into a function later
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        [responsePress,correct] = responsePress(keyCode,firstTarget,secondTarget,upKey,downKey,leftKey,rightKey,trialType);
        PsychPortAudio('Stop', pahandle);
        % Save movementTarget, block and trial number in response matrix
        
        output.responses((block-1)*numberoftrials+trialnr,1) = block; % Current block
        output.responses((block-1)*numberoftrials+trialnr,2) = trialnr; % Current trial
        output.responses((block-1)*numberoftrials+trialnr,3) = response_time; % Reaction time of response
        output.responses((block-1)*numberoftrials+trialnr,4) = responsePress; % The button pressed (1-left, 2-right, 3-up, 4-down)
        output.responses((block-1)*numberoftrials+trialnr,5) = correct;
        output.responses((block-1)*numberoftrials+trialnr,6) = movementTarget; % Where the arrow points for this trial
        output.responses((block-1)*numberoftrials+trialnr,7) = firstTarget; % Where the first probe appears
        output.responses((block-1)*numberoftrials+trialnr,9) = secondTarget; % Where the second probe appears
        output.responses((block-1)*numberoftrials+trialnr,10) = startjitter; % Time at the beginning that could cause lag
        output.responses((block-1)*numberoftrials+trialnr,11) = fixation_while; % Length of fixation loop
        output.responses((block-1)*numberoftrials+trialnr,12) = cueTime; % Length of cue arrow
        output.responses((block-1)*numberoftrials+trialnr,13) = Gosignal; % Length of GO signal before stimuli appears
        output.responses((block-1)*numberoftrials+trialnr,14) = round(SOAms,3); % The actual recorded time between probes
        output.responses((block-1)*numberoftrials+trialnr,15) = stim; % Time from GO signal to first probe
        output.responses((block-1)*numberoftrials+trialnr,16) = jitterCue; % Length of the cue jitter
        output.responses((block-1)*numberoftrials+trialnr,17) = fixation; % exact length of time fixated before continuing
        output.responses((block-1)*numberoftrials+trialnr,18) = exp.timeSOA(trialnr); % The estimated time between probes
        output.responses((block-1)*numberoftrials+trialnr,19) = startjitter+fixation_while+cueTime+Gosignal;
        output.responses((block-1)*numberoftrials+trialnr,20) = dataStream;
        output.responses((block-1)*numberoftrials+trialnr,21) = exp.trialMatrix(trialnr,1);
        output.responses((block-1)*numberoftrials+trialnr,22) = exp.trialMatrix(trialnr,2); % 1 = simultaneous, 2 = PSS, 3 = 60ms
        output.responses((block-1)*numberoftrials+trialnr,23) = exp.trialMatrix(trialnr,3);
        %output.responses((block-1)*numberoftrials+trialnr,25) = rectOutput; % (1 = Vertical & 0 = Horizontal)
        
        output.currenttrial = output.currenttrial + 1;
        trialcounter = trialcounter+1;
        boxcounter = boxcounter+1;
        
        PsychPortAudio('Stop', pahandle);
        clear responsePress correct
   %     myWait(ifi*35);
    end
    
    if(eyetracker)
        ret_stop = iView.iV_StopRecording();
        if(ret_stop ~= 1)
            msg = 'Recording could not be stopped correctly';
            disp(msg);
        end
        
        filename = fullfile(eyeTrackerFolder,['Block_', num2str(block) '.idf']);
        
        ret_save = iView.iV_SaveData(filename, 'new Experiment', exp.VPN, int32(1));
        disp('Recording saved');
        
        if(ret_save ~= 1)
            disp('Recording data could not be saved')
        end
    end
    
    output.currentblock = output.currentblock + 1;
    output.currenttrial = 1;
    blockcounter = blockcounter+1;
    exp.trialMatrix = Shuffle(exp.trialMatrix,2);
    exp.bothProbe = Shuffle(exp.bothProbe,2);
    exp.timeSOA = timeSOA(exp.trialMatrix(:,2));
    % shuffle the conditions in every block
    save([pwd,'\participantData\participant_' num2str(exp.VPN)],'output','exp');
    save([pwd,'\participantData\block_' num2str(block)],'block');
    
end

createOutputFilepaul(exp, output);

save([pwd,'\participantData\participant_' num2str(exp.VPN)],'output','exp');

clear acc info protofile Smp pAccuracyData pCalibrationData pEventData pSampleData pSystemInfoData
if(eyetracker)
    %Unload the iViewX API library and disconnect from the server
    UnloadiViewXAPI;
end
sca;
for i=1:numberofblocks
    delete([pwd,'\participantData\block_' num2str(i) '.mat'])%allColors
end
t(:,1) = output.responses(:,11)-output.responses(:,17); % fixation setup vs actual fixation
t(:,2) = output.responses(:,13)-output.responses(:,15); % time after GO vs actual time after GO
t(:,3) = output.responses(:,12)-output.responses(:,16); % cue length setup vs actual cue length
t(:,4) = output.responses(:,14)-output.responses(:,18); % SOA setup vs actual SOA
helpVec =  output.responses(:,17);
for i = 1:length(t)
    if helpVec(i)
        t(i,3) = 0;
    end
end


% move all the data into its own participant folder
cd ('D:\new_experiment\participantData\');
mkdir (['D:\new_experiment\participantData\data_' num2str(exp.VPN)]);
%movefile ((['coords_' num2str(exp.VPN) '_*' '.mat']),['data_' num2str(exp.VPN)]);
movefile ((['participant_' num2str(exp.VPN) '.mat']),['data_' num2str(exp.VPN)]);
movefile ([num2str(exp.VPN) '.xls'],['data_' num2str(exp.VPN)]);
cd('D:\new_experiment\');


%MAINthreshold(output.responses,struct2array(load([pwd,'\PSS\participantData\participant_' num2str(exp.VPN)'],'threshold')))
% Paul Fisher 2019

        
        