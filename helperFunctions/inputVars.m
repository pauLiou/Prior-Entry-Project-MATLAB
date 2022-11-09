function exp = inputVars()
% Bundle all user input and returns struct with user variables (VPN, Age,
% Gender, Diagnosis Parkinson, Trial run)

validInput = false;

% Loops until the user has given valid input
while (~validInput)
    
    % Create the dialog box
    prompt = {'VPN:','Age:', 'Gender(f or m):', 'Trial run(y or n):'};
    dlg_title = 'User Input';
    num_lines = 1;
    expCell = inputdlg(prompt,dlg_title,num_lines);
    
    % save input in struct instead of cell
    exp.VPN = expCell{1};
    exp.age = str2double(expCell{2});
    exp.gender = expCell{3};
    trial = expCell{4};
    if(trial == 'y')
        exp.trial = true;
    elseif(trial == 'n')
        exp.trial = false;
    end

    %check whether values are valid
    % VPN has to be filled out, age hast to be between 0 and 110
    validInput = ~isempty(exp.VPN) && ~isempty(exp.age) && (exp.age > 0) && (exp.age < 110);
    % Gender can be f for female or m for male
    validInput = validInput && (exp.gender == 'm' || exp.gender == 'f');
    % trial is either y -> true or n -> false
    validInput = validInput && (trial == 'y' || trial == 'n');
    
    if ~validInput
        msg = 'The entered information was not valid. Please repeat with valid values.';
        disp(msg)
    end
end

end