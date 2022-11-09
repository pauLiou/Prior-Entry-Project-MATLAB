% Open an on screen window
[w, windowRect] = PsychImaging('OpenWindow', screenNumber, bkgdColor);
HideCursor(w);


% Make images to textures
probeStimulus = Screen('MakeTexture',w,imgTest,1,1);
defaultStimulus = Screen('MakeTexture', w, img8,1,1);
arrowCue = Screen('MakeTexture',w,imgCue,1,1);
instructionStimulus = Screen('MakeTexture',w,instructions);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');