%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Point of Subjective Simultaneity v2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO

% FIX stuff to make it the same as PSSv1

addpath('C:/toolbox/')
% Clear the workspace and the screen
sca;
close all;
clearvars;
loadVars = [];
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
% Turn off feedback or not
feedback = false;

% First side to be luminated (right, left or random)
firstProbeType = 'random';
probePos = 1;


% The number of "8" symbols that appear, for PSS is 2
positionChoices = [1 2 3 4];
numStimuli = length(positionChoices);
halfStimuli = numStimuli/2;

% Load the iViewX API library and connect to the server (in separate File)
if(eyetracker)
    InitAndConnectiViewXAPI;
end

% Load the information important for the keyboard inputs
keyboardInfo;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Load participant specific data, includes the trial sequence and requires
% participants input
participantInfo;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Create a subfolder for eye tracker data if turned on
if(eyetracker)
    eyeTrackerFolder = [ pwd '\eyeTrackerData\Participant_' num2str(exp.VPN)];
    mkdir(eyeTrackerFolder);
end
    

% Run the eye tracker calibration if it is connected
calibrationInfo;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Runs the helper file that gives the screen information directly
screenInfo;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Adding some counters to check it is looping properly, they should
% increase with every iteration
trialcounter = 0;
blockcounter = 0;

% Calculate the jitter
jitter = [0.800,0.900,1.000,1.100,1.200];
for i  = 1:numberoftrials
    exp.jitterPrep(i,:) = jitter(mod(i,6-1)+1);
end
exp.jitterPrep = Shuffle(repmat(exp.jitterPrep,1,numberofblocks));    



% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

topPriorityLevel = MaxPriority(w);
Priority(topPriorityLevel);

for block = output.currentblock:numberofblocks
    trialcounter = 1;
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
    end
    
    Screen('TextSize',w, 24);
    blocktext = ['Block: [', num2str(block), '] Press Any Key to Begin...'];
    DrawFormattedText(w, blocktext,'center', 'center', white);
    Screen('Flip',w);
    KbStrokeWait;
    
    if exp.phase(block) == 0 && countblockcue == 0
        Screen('TextSize',w, 24);
        blocktext = ['\n ----------------------------------------------------------'...
            '\n We are now entering the cued phase of the experiment!'...
            '\n You will now receive an arrow cue on every trial, please try your best to ignore it!'...
            '\n ----------------------------------------------------------'];
        DrawFormattedText(w, blocktext,'center', 'center', white);
        Screen('Flip',w);
        KbStrokeWait;
        countblockcue = 1;
    elseif exp.phase(block) == 1 && countblocknocue == 0
        Screen('TextSize',w, 24);
        blocktext = ['\n ----------------------------------------------------------'...
            '\n We are now entering the uncued phase of the experiment!'...
            '\n There will be no cue, please simply perform the task as instructed'...
            '\n ----------------------------------------------------------'];
        DrawFormattedText(w, blocktext,'center', 'center', white);
        Screen('Flip',w);
        KbStrokeWait;
        countblocknocue = 1;
    end
    
    if mod(block,2) == 1
        Screen('TextSize',w, 24);
        blocktext = ['Block: [', num2str(block), ']\n Please select the target that appears FIRST'];
        DrawFormattedText(w, blocktext,'center', 'center', white);
        Screen('Flip',w);
        KbStrokeWait;
    else
        Screen('TextSize',w, 24);
        blocktext = ['Block: [', num2str(block), ']\n Please select the target that appears SECOND'];
        DrawFormattedText(w, blocktext,'center', 'center', white);
        Screen('Flip',w);
        KbStrokeWait;
    end

  
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
    
    for trialnr = output.currenttrial:numberoftrials
        firstTarget = find(positionChoices == exp.bothProbe(trialnr, 1)); % Location of first probe
        secondTarget = find(positionChoices == exp.bothProbe(trialnr, 2)); % Location of second probe
        targets = [firstTarget,secondTarget];
        if exp.trialMatrix(trialnr,1) == 1
            movementTarget = firstTarget;
        elseif exp.trialMatrix(trialnr,1) == 2
            movementTarget = secondTarget;
        else
            idx = find(~ismember(positionChoices,exp.bothProbe(trialnr,:)));
            movementTarget = idx(randi(2));
        end
        trialType = mod(block,2);
        if trialType == 1
            trialVersion = firstTargetTrial;
        else
            trialVersion = secondTargetTrial;
        end
        duration = exp.timeSOA(trialnr,block); % time between probes
        if duration == 0
            duration = 0.001;
        end
        jitterTrial = exp.jitterPrep(trialnr,block);
        
        Screen('TextSize',w, 30);
      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fixation cross (jittered around 1 second)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Determines that: 
        % A: Participant is fixated for at least the length of the ~1s.
        % B: Eyes are actually on the fixation cross for this time
        % C: Pre-stimulus adaptation of monitor refresh rate.
        fixatedEyes = false; % True if eyes are looking at fixation cross
        dur = false; % True if the fixation reaches the time threshold
        clockStart = true; % Start the fixation timer only when fixated and clockStart is true
        trial = 0;
        fixation_tic = tic;
        while(~fixatedEyes || ~dur)
            for i = 1:round(jitterTrial)/0.05 % For about 1 s,...
                if(~fixatedEyes)
                    startTime = tic;
                end
                if fixatedEyes == true && clockStart == true
                    trial = tic;
                end
                % This draws the fixation cross
                Screen('DrawLines', w, allCoords, lineWidthPix, textColor, [circleXCenter yCenter], 2,2);
                DrawFormattedText(w, trialVersion,'center', yCenter - (yCenter/2), white);
                for a = 1:numStimuli
                    Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1}, 0, 0);
                end
                if(eyetracker)
                    iView.iV_GetSample(pSampleData); % Get an eye tracker sample at this time
                    Smp = libstruct('SampleStruct', pSampleData);
                    gazeX = (Smp.leftEye.gazeX + Smp.rightEye.gazeX) / 2; % Average of both eyes X axis
                    gazeY = (Smp.leftEye.gazeY + Smp.rightEye.gazeY) / 2; % Average of both eyes Y axis
                    % Determines if these gaze coords are in the fixation area
                    fixatedEyes = isInCircle(gazeX, gazeY, [xCenter yCenter], threshold_radius);
%                     if gazeX == 0.0 || gazeY == 0.0
%                         fixatedEyes = true;
%                     end
                else
                    fixatedEyes = true;
                end
                Screen('Flip',w);
                % Wait period to adapt monitor refresh rate
                myWait(duration);
                if trial == 0
                    clockStart = true;
                else
                    clockStart = false;
                end
                
                if(fixatedEyes)
                    dur = toc(startTime) > jitterTrial/2;
                end

            end
        end
        
        fixation_clock = toc(fixation_tic);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 1: Draw the Movement Cue
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Draw 8 on target locations to backbuffer
        if exp.phase(block) == 0
            for i = 1:round(1/0.02) % loops for approx 500ms and additional is added after the loop in order to adapt refresh rate
                for a = 1:numStimuli
                    Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1},0,0);
                end
                DrawFormattedText(w, trialVersion,'center', yCenter - (yCenter/2), white);
                % Draw cue for movementTarget to backbuffer and flip screen
                AssertOpenGL;
                Screen('DrawTexture',w,arrowCue,[],[circleXCenter-12, yCenter-12,circleXCenter+12,yCenter+12],cueAngle(movementTarget,1),2,2);
                Screen('Flip', w);
            end
            myWait(jitterTrial/8);
        end
 %       myWait(jitterCue-(ifi*140)); % number found through pure trial and error and tested with the tic/tic down to 1ms accurate
        cueTime = toc(trial);
        trial = tic;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Simultaneous probes appears
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        count = tic;
        if exp.timeSOA(trialnr,block) == 0 %simultaneous
            if exp.phase(block) == 0
                % Draw cue for movementTarget to backbuffer and flip screen
                AssertOpenGL;
                Screen('DrawTexture',w,arrowCue,[],[circleXCenter-12, yCenter-12,circleXCenter+12,yCenter+12],cueAngle(movementTarget,1),2,2);
            else
                Screen('DrawLines', w, allCoords, lineWidthPix, textColor, [circleXCenter yCenter],2, 2);
            end
            
            % Draws the default stimuli except the first target probe
            for a = 1:numStimuli
                Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1}, 0, 0);
            end
            DrawFormattedText(w, trialVersion,'center', yCenter - (yCenter/2), white);
            % Draws the probe target
            Screen('DrawTexture',w,probeStimulus,[],alltargetLoc{firstTarget,1}, 0, 0);
            Screen('DrawTexture',w,probeStimulus,[],alltargetLoc{secondTarget,1}, 0, 0);
            Screen('Flip', w);
            
            SOAms = toc(count);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % first probe appears
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        else % not simultaneous
            if exp.phase(block) == 0
                % Draw cue for movementTarget to backbuffer and flip screen
                AssertOpenGL;
                Screen('DrawTexture',w,arrowCue,[],[circleXCenter-12, yCenter-12,circleXCenter+12,yCenter+12],cueAngle(movementTarget,1),2,2);
            else
                Screen('DrawLines', w, allCoords, lineWidthPix, textColor, [circleXCenter yCenter],2, 2);
            end
            % Draws the default stimuli except the first target probe
            for a = 1:numStimuli
                Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1}, 0, 0);
            end
            DrawFormattedText(w, trialVersion,'center', yCenter - (yCenter/2), white);
            % Draws the probe target
            Screen('DrawTexture',w,probeStimulus,[],alltargetLoc{firstTarget,1}, 0, 0);
            Screen('Flip', w);
            myWait(duration-0.0026); % This is essential pay attention to if this is working
            SOAms = toc(count);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Second probe appears
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for a = 1:numStimuli
                Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1}, 0, 0);
            end
            DrawFormattedText(w, trialVersion,'center', yCenter - (yCenter/2), white);
            Screen('DrawTexture',w,probeStimulus,[],alltargetLoc{firstTarget,1}, 0, 0);
            Screen('DrawTexture',w,probeStimulus,[],alltargetLoc{secondTarget,1}, 0, 0);
            if exp.phase(block) == 0
                % Draw cue for movementTarget to backbuffer and flip screen
                AssertOpenGL;
                Screen('DrawTexture',w,arrowCue,[],[circleXCenter-12, yCenter-12,circleXCenter+12,yCenter+12],cueAngle(movementTarget,1),2,2);
            else
                Screen('DrawLines', w, allCoords, lineWidthPix, textColor, [circleXCenter yCenter],2, 2);
            end
            
            Screen('Flip',w);
        end
        
        SOAms = toc(count);
        if exp.timeSOA(trialnr,block) == 0
            SOAms = 0;
        end
        
        % Output response and RT
        probe_response = tic;
        
        if ismember(targets,vertical,'rows')
            RestrictKeysForKbCheck([upKey,downKey]);
        else
            RestrictKeysForKbCheck([leftKey,rightKey]);
        end
        [secs,keyCode] = KbWait;
        response_time = toc(probe_response);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Try to trim this down or put it into a function later
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        

        [responsePress,correct] = responsePress_PSS(keyCode,firstTarget,secondTarget,upKey,downKey,leftKey,rightKey,trialType);
        RestrictKeysForKbCheck([]);        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Feedback
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This draws the fixation cross
        if(feedback)
            
            if correct == 1
                feedbackColor = green;
            else
                feedbackColor = red;
            end
            
            Screen('DrawLines', w, allCoords, lineWidthPix, feedbackColor, [circleXCenter yCenter], 2);
            for a = 1:numStimuli
                Screen('DrawTexture',w,defaultStimulus,[],alltargetLoc{a,1}, 0, 0);
            end
            DrawFormattedText(w, trialVersion,'center', yCenter - (yCenter/2), white);
            Screen('Flip',w);
        end

        %create the output file detailing the block, trial, which side
        %had the probe first, RT, correct answers, SOA details
        output.responses((block-1)*numberoftrials+trialnr,1) = block; % The current block
        output.responses((block-1)*numberoftrials+trialnr,2) = trialnr; % The current trial
        output.responses((block-1)*numberoftrials+trialnr,3) = response_time; % The RT of participants reponse
        output.responses((block-1)*numberoftrials+trialnr,4) = firstTarget; % The first probe location
        output.responses((block-1)*numberoftrials+trialnr,5) = correct; % Trial accuracy
        output.responses((block-1)*numberoftrials+trialnr,6) = secondTarget; % The second probe location
        output.responses((block-1)*numberoftrials+trialnr,7) = exp.timeSOA(trialnr, block); % The estimated time between probes
        output.responses((block-1)*numberoftrials+trialnr,8) = round(SOAms,3); % The actual recorded time between probes
        output.responses((block-1)*numberoftrials+trialnr,9) = exp.timeSOA(trialnr,block)-SOAms; % diff between SOA and expected SOA
        output.responses((block-1)*numberoftrials+trialnr,10) = jitterTrial; % /2 is fixation /8 is arrowCue
        output.responses((block-1)*numberoftrials+trialnr,11) = trialType; % first probe or second
        output.responses((block-1)*numberoftrials+trialnr,12) = isequal(movementTarget,firstTarget);
        output.responses((block-1)*numberoftrials+trialnr,13) = isequal(movementTarget,secondTarget);
        output.responses((block-1)*numberoftrials+trialnr,14) = fixation_clock; % exact fixation length
        output.responses((block-1)*numberoftrials+trialnr,15) = exp.phase(block);
        if(eyetracker)
            iView.iV_SendImageMessage(['End of Block: ' num2str(block) ',Trial: ' num2str(trialnr)]); 
        end
        output.currenttrial = output.currenttrial + 1;
        trialcounter = trialcounter+1;
        %save('output.mat', 'output');
        
        % Haven't fully figured this out yet, but this myWait is essential
        % for this to work, it seems to need to be less than the fixation
        % cross loop time
        myWait(ifi*24);
%         if(feedback)
%             myWait(ifi*24);
%         end
    end
       
    %---------------------------------------------------------------------
    % Stop recording and Save recorded EyeTracker Data
    %---------------------------------------------------------------------

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
    
end


sca;

%threshold = PSSthreshold(output.responses);
% create output file in excel
%exp.threshold = threshold;
createOutputFilePSS2(exp, output);
save([pwd,'\participantData\participant_' num2str(exp.VPN)],'output','exp');

clear acc info protofile Smp pAccuracyData pCalibrationData pEventData pSampleData pSystemInfoData

if eyetracker == true;
    %Unload the iViewX API library and disconnect from the server
    UnloadiViewXAPI;
end

PSS2threshold(output.responses);

% Paul Fisher 20191

    
        

        
        
