function [responsePress,correct] = responsePress(keyCode,firstTarget,secondTarget,upKey,downKey,leftKey,rightKey,trialType)

% left half first = left arrow = 1 in output file
if keyCode(leftKey) == 1
    press = 1;
    % right half first = right arrow = 2 in output file
elseif keyCode(rightKey) == 1
    press = 2;
    
elseif keyCode(upKey) == 1
    press = 3;
    
elseif keyCode(downKey) == 1
    press = 4;
else
    press = 0;
end

responsePress = press;

response = [firstTarget,secondTarget];
vertical = [1,2;2,1;3,4;4,3]; % the factorial of possible vertical positions


% decision tree to determine whether response key press matches the
% corresponding target location that would mean it was correctly
% discriminating the first target
if press == 1 && firstTarget < 3 && secondTarget > 2
    correct = 1;
elseif press == 2 && firstTarget > 2 && secondTarget < 3
    correct = 1;
elseif press == 3 && ismember(response,vertical,'rows') && ismember(secondTarget,1:3:4)
    correct = 1;
elseif press == 4 && ismember(response,vertical,'rows') && ismember(firstTarget,1:3:4)
    correct = 1;
else
    correct = 0;
end



% adjust the correct status for trials where you must select 2nd target by
% reversing the decision tree
if trialType == 0
    correct = not(correct);
end

    


        