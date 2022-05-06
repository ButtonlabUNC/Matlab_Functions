function [Results, Debug_Struct] = Peel_Analysis(Data_Path, varargin)
%% Input Parsing
Peel_Analysis_InputParser = inputParser;

Require_Arg_1 = "Data_Path";
Require_Arg_1_Validation_Funcation = @(x) ischar(x) || isstring(x);
addRequired(Peel_Analysis_InputParser, ...
    Require_Arg_1, Require_Arg_1_Validation_Funcation)                      % required input input a path for xlsx data

Optional_Arg_1 = "Save_Figs";
Optoinal_Arg_1_Default_Val = false;
Optional_Arg_1_Validation_Function = @(x) islogical(x) && isscalar(x);
addParameter(Peel_Analysis_InputParser, Optional_Arg_1, ...
    Optoinal_Arg_1_Default_Val, Optional_Arg_1_Validation_Function)         % optional argument specifies if figures should be saved. must be a logical value

Optional_Arg_2 = "Save_Dir";
Optional_Arg_2_Default_val = pwd;
Optional_Arg_2_Validation_Function = @(x) (ischar(x) || isstring(x)) && ...
    isscalar(x);
addParameter(Peel_Analysis_InputParser, Optional_Arg_2, ...
    Optional_Arg_2_Default_val, Optional_Arg_2_Validation_Function)         % specifies the save directory defaults to current working directory

Optional_Arg_3 = "File_Name";
Optional_Arg_3_Default_val = ...
    strcat(datestr(now,'yyyymmdd'), " Peel_Analysis.xlsx");
Optional_Arg_3_Validation_Function = @(x) (ischar(x) || isstring(x)) && ...
    isscalar(x);                                                            
addParameter(Peel_Analysis_InputParser, Optional_Arg_3, ...
    Optional_Arg_3_Default_val, Optional_Arg_3_Validation_Function)         % specifies the filename for saving results to xlsx files

Optional_Arg_4 = "Save";
Optoinal_Arg_4_Default_Val = false;
Optional_Arg_4_Validation_Function = @(x) islogical(x) && isscalar(x);
addParameter(Peel_Analysis_InputParser, Optional_Arg_4, ...
    Optoinal_Arg_4_Default_Val, Optional_Arg_4_Validation_Function)         % specifies if results are saved to xlsx

parse(Peel_Analysis_InputParser, Data_Path, varargin{:})

%% Validate input
if Peel_Analysis_InputParser.Results.(Optional_Arg_4)
 if ~contains(Peel_Analysis_InputParser.Results.(Optional_Arg_3), ".xlsx", "IgnoreCase", true)
     Peel_Analysis_InputParser.Results.(Optional_Arg_3) = strcat(...
         Peel_Analysis_InputParser.Results.(Optional_Arg_3), ".xlsx");             % check user file name is a valid name
 end
end

%% Indexing xlsx
Sheet_Names = sheetnames(Peel_Analysis_InputParser.Results.(Require_Arg_1));      % extracts xlsx file sheet names
Sheet_Number = numel(Sheet_Names);                                          % counts number of sheets

Valid_sheets = false([Sheet_Number, 1]);                                    % preallocates variable for sheet validation

%% Valid Sheet Detection
for k1 = 1:Sheet_Number
[~, ~, Eval_Raw] = ...
    xlsread(Peel_Analysis_InputParser.Results.(Require_Arg_1), Sheet_Names(k1));  % inports raw data from one sheet of xlsx data

if numel(Eval_Raw) >= 42                                                    % if a sheet does not meet a minimum number of cells it is marked as invalid
    Valid_sheets(k1) = true;                    

else
    Valid_sheets(k1) = false;

end
end

%% Perallocation

Sample_Names = strings([Sheet_Number,1]);
Mean_Force = zeros([Sheet_Number,1]);
Median_Force = zeros([Sheet_Number,1]);
Force_SDV = zeros([Sheet_Number,1]);
Force_CV = zeros([Sheet_Number,1]);

Debug_Struct = struct;

%% plotting and calculations
% for the number of sheets in xlsx data checks if the sheet was validated
% then inports and analyzes the data

for k2 = 1:Sheet_Number             
    if Valid_sheets(k2)
    [Data_NUM, Data_TXT] = xlsread(...
        Peel_Analysis_InputParser.Results.(Require_Arg_1), Sheet_Names(k2));      % imports data from xlsx data

    Sample_Name = Data_TXT{1:1};                                            % extracts sample name
    if isempty(Sample_Name)
        Sample_Name = strcat("Sample", string(k2));
    end                                                                     % populates Sample Name if user did not fill the sample name during aquisition

    Displacement = Data_NUM(:,6);                                           % saves only Displacement Data to array
    Force = Data_NUM(:,4);                                                  % saves only force Data to array    

    plot(Displacement, Force);
        title(Sample_Name);
        xlabel("Displacement(mm)");
        ylabel("Force(um)");                                                % plots data for user to evaluate

    [x_range, y_range] = ginput(2);                                         % prompts user to select valid range

    if Peel_Analysis_InputParser.Results.(Optional_Arg_1)                   % saves figures if option is defined true
        hold on                                                             % allows for additional plotting on current figure

        scatter(x_range, y_range)                                           % plots user inputs onto displacement force data

        Fig_save_Path = strcat(...
            Peel_Analysis_InputParser.Results.(Optional_Arg_2), "\", ...
            Sample_Name, ".fig");                                           % generates valid save path for figures

        saveas(gcf, Fig_save_Path)                                          % saves figure with user inputs
        hold off
    end

    Debug_Struct_Field_name = matlab.lang.makeValidName(Sample_Name);       % confirms sample name is a valid field name

    Selected_Range = find(...
        (Displacement >  x_range(1)) && (Displacement <  x_range(2)));      % finds ranges of displacement data between user inputs

    Debug_Struct.(Debug_Struct_Field_name).User_Inputs = ...
        [x_range, y_range];
    Debug_Struct.(Debug_Struct_Field_name).Selected_Range = ...
        Selected_Range;
    Debug_Struct.(Debug_Struct_Field_name).Displacement = ...
        Displacement;
    Debug_Struct.(Debug_Struct_Field_name).Force = ...
        Force;                                                              % save intermidate data for debugging

    Sample_Names(k2) = Sample_Name;
    Mean_Force(k2) = mean(Force(Selected_Range));
    Median_Force(k2) = median(Force(Selected_Range));
    Force_SDV(k2) = std(Force(Selected_Range));
    Force_CV(k2) = ...
        std(Force(Selected_Range)) / mean(Force(Selected_Range));           % saves calculations

    close gcf
    end
end
%% Table Generation
Empty_Rows = cellfun("isempty", Sample_Names);

Sample_Names(Empty_Rows) = [];
Mean_Force(Empty_Rows) = [];
Median_Force(Empty_Rows) = [];
Force_SDV(Empty_Rows) = [];
Force_CV(Empty_Rows) = [];



Results = table( ...
    Sample_Names, Mean_Force, Median_Force, Force_SDV, Force_CV, ...
    "VariableNames", [...
    "Sample Name", "Mean Force", "Median Force", "SDV", "CV"]);             % generates table containg calculations

if Peel_Analysis_InputParser.Results.(Optional_Arg_4)
    xlsx_save_path = strcat(...
        Peel_Analysis_InputParser.Results.(Optional_Arg_2), "\", ...
        Peel_Analysis_InputParser.Results.(Optional_Arg_3));

    writetable(Results, xlsx_save_path)                                     % writes table to xlsx file
end

