%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%            userInput function edited for PSS
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function exp = userInput()
% Bundle all user input and returns struct with user variables (VPN, Age,
% Gender, Diagnosis Parkinson, Trial run)

validInput = false;

% Loops until the user has given valid input
while (~validInput)
    
    % Create the dialog box
    prompt = {'Participant Number:','Age:', 'Gender(f or m):','practice'};
    dlg_title = 'User Input';
    num_lines = 1;
    expCell = inputdlg(prompt,dlg_title,num_lines);
    
    % save input in struct instead of cell
    exp.VPN = expCell{1};
    exp.age = str2double(expCell{2});
    exp.gender = expCell{3};
    exp.practice = expCell{4};  
    

    %check whether values are valid
    % VPN has to be filled out, age hast to be between 0 and 110
    validInput = ~isempty(exp.VPN) && ~isempty(exp.age) && (exp.age > 0) && (exp.age < 110);
    % Gender can be f for female or m for male
    validInput = validInput && (exp.gender == 'm' || exp.gender == 'f');
    validInput = validInput && (exp.practice == 'y' || exp.practice == 'n');
    

    
    
    if ~validInput
        msg = 'The entered information was not valid. Please repeat with valid values.';
        disp(msg)
    end
end

end