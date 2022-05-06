function [Selected_Data] = Graphic_selection(Independant_data, Dependant_Data, varargin)
%% Input Parsing
Graphic_selection_InputParser = inputParser;

Required_Input_1_Validation_Function = @(x) isnumeric(x) && isvector(x);
addRequired(Graphic_selection_InputParser, ...
    "Independant_data", Required_Input_1_Validation_Function)

Required_Input_2_Validation_Function = @(x) isnumeric(x) && isvector(x);
addRequired(Graphic_selection_InputParser, ...
    "Dependant_data", Required_Input_2_Validation_Function)

Optional_Arg_1 = "Selection_Mode";
Optional_Arg_1_Default_Value = 1;
Optioanl_Arg_1_Valid_Val = [1, 2];
Optional_Arg_1_Validation_Function = @(x)...
    isnumeric(x) && isscalar(x) && any(strcmp(x,Optioanl_Arg_1_Valid_Val));
addOptional(Graphic_selection_InputParser,...
    Optional_Arg_1, Optional_Arg_1_Default_Value, ...
    Optional_Arg_1_Validation_Function)

parse(Graphic_selection_InputParser, Independant_data, Dependant_Data, ...
    varargin{:})


if numel(Graphic_selection_InputParser.Results.Independant_data) ~= ...
        numel(Graphic_selection_InputParser.Results.Dependant_data)
error("number of independant and dependant data values must be equal")

end

%% Operations
Independant_Variable = ...
    Graphic_selection_InputParser.Results.Independant_data;
Dependant_Variable = ...
    Graphic_selection_InputParser.Results.Dependant_data;

plot(Independant_Variable,Dependant_Variable)

title("Select Range")
xlabel("Independant Variable")
ylabel("Dependant Variable")

[X_input, Y_input] = ginput(2);

close gcf

if Graphic_selection_InputParser.Results.(Optional_Arg_1) == 1
    Method_1_Search_function = @(x) x > X_input(1) && x < X_input(2);
    Selection_Range = arrayfun(Method_1_Search_function, ...
        Independant_Variable);
    
elseif Graphic_selection_InputParser.Results.(Optional_Arg_1) == 2
     Method_2_Search_function = @(x) x > Y_input(1) && x < Y_input(2);
     Selection_Range = arrayfun(Method_2_Search_function, ...
         Dependant_Variable);
end

Selected_Data = zeros([sum(Selection_Range), 2]);

Selected_Data(:,1) = Independant_Variable(Selection_Range);
Selected_Data(:,2) = Dependant_Variable(Selection_Range);

end
